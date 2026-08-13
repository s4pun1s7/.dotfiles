#!/bin/bash
# Gaming readiness check for this box (MacPro6,1, dual FirePro D300 / Pitcairn).
#
# Reports driver, Mesa/Vulkan, 32-bit userspace, CPU and GPU power state, and
# the compositor settings that actually cost frames. Read-only: it never
# changes anything, it just tells you what to change.
#
#   gamecheck.sh          full report
#   gamecheck.sh -q       only WARN/FAIL lines

set -u

QUIET=0
[ "${1:-}" = "-q" ] && QUIET=1

if [ -t 1 ]; then
	R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[1m' N=$'\e[0m'
else
	R="" G="" Y="" B="" N=""
fi

fails=0
warns=0

section() { [ "$QUIET" = 1 ] || printf '\n%s== %s ==%s\n' "$B" "$1" "$N"; }
pass() { [ "$QUIET" = 1 ] || printf '  %sPASS%s %s\n' "$G" "$N" "$1"; }
info() { [ "$QUIET" = 1 ] || printf '       %s\n' "$1"; }
warn() {
	warns=$((warns + 1))
	printf '  %sWARN%s %s\n' "$Y" "$N" "$1"
	[ $# -gt 1 ] && printf '       -> %s\n' "$2"
}
fail() {
	fails=$((fails + 1))
	printf '  %sFAIL%s %s\n' "$R" "$N" "$1"
	[ $# -gt 1 ] && printf '       -> %s\n' "$2"
}

# --- hardware -----------------------------------------------------------------
section "Hardware"
info "$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null) | kernel $(uname -r)"
info "$(lscpu | awk -F: '/Model name/{gsub(/^ +/,"",$2); print $2; exit}')"

gpus=$(lspci -nnk | grep -c "VGA compatible controller")
info "$gpus GPU(s):"
if [ "$QUIET" = 0 ]; then
	lspci -nnk | grep -A2 "VGA compatible controller" | grep -E "VGA|Kernel driver" |
		sed 's/^/       /'
fi

# --- driver -------------------------------------------------------------------
section "Driver"
if lspci -nnk | grep -A3 "VGA compatible" | grep -q "Kernel driver in use: amdgpu"; then
	pass "amdgpu in use (not the legacy radeon driver)"
elif lspci -nnk | grep -A3 "VGA compatible" | grep -q "Kernel driver in use: radeon"; then
	warn "legacy radeon driver in use" \
		"amdgpu is faster and is what RADV/Vulkan needs; boot with radeon.si_support=0 amdgpu.si_support=1"
else
	fail "no amdgpu/radeon driver bound to the GPU"
fi

if journalctl -k -b 2>/dev/null | grep -qiE "amdgpu.*(firmware.*(fail|missing)|ring.*timeout|GPU reset)"; then
	warn "amdgpu errors in this boot's kernel log" \
		"journalctl -k -b | grep -i amdgpu"
else
	pass "no amdgpu firmware/reset errors this boot"
fi

# --- render vs display --------------------------------------------------------
section "GPU topology"
# Which card actually has the monitors attached.
display_card=""
for s in /sys/class/drm/card*-*/status; do
	[ "$(cat "$s" 2>/dev/null)" = "connected" ] || continue
	display_card=$(basename "$(dirname "$s")" | cut -d- -f1)
	break
done
# The GPU Xorg picked is marked with * in its PCI listing.
xorg_pci=$(grep -oP 'PCI:\*\(\K[0-9]+' /var/log/Xorg.0.log 2>/dev/null | head -1)
if [ -n "$display_card" ]; then
	card_pci=$(readlink -f "/sys/class/drm/$display_card/device" | xargs basename)
	info "monitors are on $display_card ($card_pci)"
	if [ -n "$xorg_pci" ] && [ "$((16#$(echo "$card_pci" | cut -d: -f2)))" = "$xorg_pci" ]; then
		pass "Xorg renders on the same GPU that drives the monitors"
	else
		info "Xorg primary PCI bus: ${xorg_pci:-unknown}"
	fi
	idle=$(ls -d /sys/class/drm/card? 2>/dev/null | grep -v "$display_card" | wc -l)
	[ "$idle" -gt 0 ] && info "$idle other GPU(s) idle - normal here, the second D300 has no outputs wired"
else
	warn "could not determine which card drives the monitors"
fi

# --- mesa / vulkan ------------------------------------------------------------
section "Mesa / Vulkan"
if command -v glxinfo >/dev/null; then
	renderer=$(glxinfo -B 2>/dev/null | awk -F': ' '/OpenGL renderer/{print $2}')
	glver=$(glxinfo -B 2>/dev/null | awk -F': ' '/OpenGL version/{print $2}')
	accel=$(glxinfo -B 2>/dev/null | awk -F': ' '/Accelerated/{gsub(/ /,"",$2); print $2}')
	info "$renderer"
	if [ "$accel" = "yes" ]; then
		pass "hardware accelerated GL ($glver)"
	else
		fail "GL is NOT accelerated - running on llvmpipe (software)" \
			"check the amdgpu driver bound above"
	fi
else
	warn "glxinfo missing, cannot verify GL acceleration" "sudo dnf install glx-utils"
fi

if [ -e /usr/share/vulkan/icd.d/radeon_icd.x86_64.json ]; then
	pass "RADV Vulkan driver present (64-bit)"
else
	fail "RADV Vulkan ICD missing" "sudo dnf install mesa-vulkan-drivers"
fi

if command -v vulkaninfo >/dev/null; then
	vk=$(vulkaninfo --summary 2>/dev/null)
	if [ -n "$vk" ]; then
		pass "Vulkan initialises: $(echo "$vk" | awk -F'= ' '/deviceName/{print $2; exit}')"

		# DXVK 2.x - what current Proton ships - refuses to start below 1.3.
		api=$(echo "$vk" | awk -F'= ' '/apiVersion/{gsub(/ /,"",$2); print $2; exit}')
		apimm=$(echo "$api" | cut -d. -f1,2)
		if [ "$(printf '%s\n1.3\n' "$apimm" | sort -V | head -1)" = "1.3" ]; then
			pass "Vulkan $api - DXVK 2.x / current Proton supported"
		else
			warn "Vulkan $api is below 1.3" \
				"DXVK 2.x needs 1.3; games would need an older Proton with DXVK 1.10"
		fi

		# Both D300s and lavapipe (software) all enumerate. Device 0 is what an
		# app gets by default, and it must be the card driving the monitors.
		gpu0_bus=$(echo "$vk" | awk '/^GPU0:/{f=1} f && /deviceUUID/{split($3,u,"-"); print substr(u[2],1,2); exit}')
		want_bus=${card_pci#*:}
		want_bus=${want_bus%%:*}
		count=$(echo "$vk" | grep -c '^GPU[0-9]')
		if [ -n "$gpu0_bus" ] && [ "$gpu0_bus" = "$want_bus" ]; then
			pass "Vulkan device 0 is the GPU driving your monitors (bus $want_bus)"
			[ "$count" -gt 1 ] &&
				info "$count Vulkan devices total - the idle D300 and lavapipe (software) also enumerate"
		elif [ -n "$gpu0_bus" ]; then
			warn "Vulkan device 0 is on bus $gpu0_bus, but the monitors are on bus $want_bus" \
				"a game would render on the idle card and copy across PCIe; force it with MESA_VK_DEVICE_SELECT=1002:6810!"
		fi
	else
		fail "Vulkan ICD present but fails to initialise" "vulkaninfo 2>&1 | head"
	fi
else
	warn "vulkan-tools missing, cannot confirm Vulkan actually works" \
		"sudo dnf install vulkan-tools  # then: vulkaninfo --summary"
fi

# --- 32-bit -------------------------------------------------------------------
section "32-bit userspace (Steam / older titles)"
for p in mesa-dri-drivers mesa-vulkan-drivers; do
	if rpm -q "$p.i686" >/dev/null 2>&1; then
		pass "$p.i686"
	else
		fail "$p.i686 missing" "sudo dnf install $p.i686"
	fi
done

# --- power --------------------------------------------------------------------
section "Power / clocks"
gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
if [ "$gov" = "performance" ]; then
	pass "CPU governor: performance"
else
	warn "CPU governor: ${gov:-unknown}" \
		"sudo cpupower frequency-set -g performance  (or let gamemode do it per-game)"
fi

grep -q "mitigations=off" /proc/cmdline &&
	pass "CPU mitigations off (worth real frames on this Xeon)" ||
	info "CPU mitigations on - mitigations=off in the kernel cmdline buys a few percent"

for d in /sys/class/drm/card?/device/power_dpm_force_performance_level; do
	[ -r "$d" ] || continue
	lvl=$(cat "$d")
	c=$(echo "$d" | cut -d/ -f5)
	if [ "$lvl" = "auto" ]; then
		info "$c DPM: auto (fine; 'high' pins max clocks if a game clocks down)"
	else
		info "$c DPM: $lvl"
	fi
done

# --- compositor ---------------------------------------------------------------
section "Compositor"
conf="${XDG_CONFIG_HOME:-$HOME/.config}/picom/picom.conf"
if pgrep -x picom >/dev/null; then
	info "picom is running ($conf)"
	if grep -qE '^\s*unredir-if-possible\s*=\s*true' "$conf" 2>/dev/null; then
		pass "unredir-if-possible = true (fullscreen games bypass the compositor)"
	else
		fail "unredir-if-possible is not enabled" \
			"picom defaults it to false, so fullscreen games are composited: extra latency and a hard vsync cap. Add 'unredir-if-possible = true;' to picom.conf"
	fi
	backend=$(grep -oP '^\s*backend\s*=\s*"\K[^"]+' "$conf" 2>/dev/null)
	if [ "$backend" = "xrender" ]; then
		info "backend = xrender - fine once unredirect is on, since games bypass it entirely"
	else
		info "backend = ${backend:-default}"
	fi
else
	pass "no compositor running - nothing between games and the screen"
fi

# --- tooling ------------------------------------------------------------------
section "Tooling"
for t in steam gamemoded mangohud; do
	if command -v "$t" >/dev/null; then
		pass "$t"
	else
		warn "$t not installed" "sudo dnf install ${t/gamemoded/gamemode}"
	fi
done
if command -v gamemoded >/dev/null; then
	info "run games as: gamemoderun %command%   (Steam launch options)"
fi

# --- summary ------------------------------------------------------------------
printf '\n%s== Summary ==%s\n' "$B" "$N"
if [ "$fails" -eq 0 ] && [ "$warns" -eq 0 ]; then
	printf '  %sall checks passed%s\n' "$G" "$N"
else
	printf '  %s%d fail%s, %s%d warn%s\n' "$R" "$fails" "$N" "$Y" "$warns" "$N"
fi
[ "$fails" -gt 0 ] && exit 1
exit 0
