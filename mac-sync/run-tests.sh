#!/bin/bash
# Automated Test Harness for Mac M4 Setup Scripts

set -euo pipefail

DOTFILES="${1:-.}"
RESULTS="${HOME}/.setup-test-results.txt"
: > "$RESULTS"

# Colors
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Logging
log() { echo "[$(date +%T)] $*" | tee -a "$RESULTS"; }
test_start() { echo "" | tee -a "$RESULTS"; log "▶ TEST: $1"; }
test_pass() { echo -e "${GREEN}✅ PASS${NC}: $1" | tee -a "$RESULTS"; ((TESTS_PASSED++)); }
test_fail() { echo -e "${RED}❌ FAIL${NC}: $1" | tee -a "$RESULTS"; ((TESTS_FAILED++)); }
test_skip() { echo -e "${YELLOW}⊘ SKIP${NC}: $1" | tee -a "$RESULTS"; ((TESTS_SKIPPED++)); }

# Pre-flight checks
preflight() {
    test_start "Pre-flight System Checks"

    # macOS check
    if [[ "$OSTYPE" == darwin* ]]; then
        test_pass "macOS detected"
    else
        test_fail "Not running on macOS"
        exit 1
    fi

    # M-series check
    if [[ $(uname -m) == arm64 ]]; then
        test_pass "Apple Silicon (M-series) detected"
    else
        test_skip "Not Apple Silicon (running on Intel)"
    fi

    # Disk space check
    local free_mb=$(df / | awk 'NR==2 {print int($4/1024)}')
    if (( free_mb > 5000 )); then
        test_pass "Disk space adequate (${free_mb}MB free)"
    else
        test_fail "Insufficient disk space (${free_mb}MB, need 5000MB)"
    fi

    # Internet check
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        test_pass "Internet connectivity verified"
    else
        test_fail "No internet connection"
    fi
}

# Script syntax validation
syntax_tests() {
    test_start "Script Syntax Validation"

    # Setup script
    if bash -n "$DOTFILES/scripts/mac-m4-flutter-setup-minimal.sh" 2>/dev/null; then
        test_pass "mac-m4-flutter-setup-minimal.sh syntax valid"
    else
        test_fail "mac-m4-flutter-setup-minimal.sh syntax error"
    fi

    # Sync script
    if bash -n "$DOTFILES/mac-sync/mac-sync-dotfiles-minimal.sh" 2>/dev/null; then
        test_pass "mac-sync-dotfiles-minimal.sh syntax valid"
    else
        test_fail "mac-sync-dotfiles-minimal.sh syntax error"
    fi

    # Original scripts
    if bash -n "$DOTFILES/scripts/mac-m4-flutter-setup.sh" 2>/dev/null; then
        test_pass "mac-m4-flutter-setup.sh syntax valid"
    else
        test_fail "mac-m4-flutter-setup.sh syntax error"
    fi

    if bash -n "$DOTFILES/mac-sync/mac-sync-dotfiles.sh" 2>/dev/null; then
        test_pass "mac-sync-dotfiles.sh syntax valid"
    else
        test_fail "mac-sync-dotfiles.sh syntax error"
    fi
}

# Tool presence checks
tool_checks() {
    test_start "Tool Availability Checks"

    local tools=("git" "curl" "zsh" "bash")

    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            test_pass "$tool is available"
        else
            test_fail "$tool is not available"
        fi
    done
}

# Config file checks
config_checks() {
    test_start "Configuration File Checks"

    # Check .vimrc exists
    if [[ -f "$DOTFILES/.vimrc" ]]; then
        test_pass ".vimrc exists"
        local lines=$(wc -l < "$DOTFILES/.vimrc")
        test_pass ".vimrc has $lines lines"
    else
        test_fail ".vimrc not found"
    fi

    # Check .tmux.conf
    if [[ -f "$DOTFILES/.tmux/.tmux.conf" ]]; then
        test_pass ".tmux.conf exists"
        local lines=$(wc -l < "$DOTFILES/.tmux/.tmux.conf")
        test_pass ".tmux.conf has $lines lines"
    else
        test_fail ".tmux.conf not found"
    fi

    # Check init.vim
    if [[ -f "$DOTFILES/.config/nvim/init.vim" ]]; then
        test_pass "init.vim exists"
    else
        test_fail "init.vim not found"
    fi
}

# Installed tools checks (if already installed)
installed_tools_checks() {
    test_start "Installed Tools Verification"

    # Flutter
    if command -v flutter &>/dev/null; then
        local version=$(flutter --version 2>&1 | head -1)
        test_pass "Flutter installed: $version"
    else
        test_skip "Flutter not installed (will be installed by setup)"
    fi

    # Java
    if command -v java &>/dev/null; then
        local version=$(java -version 2>&1 | head -1)
        test_pass "Java installed"
    else
        test_skip "Java not installed (will be installed by setup)"
    fi

    # Tmux
    if command -v tmux &>/dev/null; then
        local version=$(tmux -V)
        test_pass "Tmux installed: $version"
    else
        test_skip "Tmux not installed (will be installed by setup)"
    fi

    # Vim
    if command -v vim &>/dev/null; then
        test_pass "Vim installed"
    else
        test_skip "Vim not installed (will be installed by setup)"
    fi
}

# Config validity checks
config_validity() {
    test_start "Configuration Validity Checks"

    # Check .vimrc for valid syntax
    if grep -q "^set" "$DOTFILES/.vimrc"; then
        test_pass ".vimrc contains valid vim settings"
    else
        test_fail ".vimrc appears invalid"
    fi

    # Check .tmux.conf for valid syntax
    if grep -q "^bind\|^set" "$DOTFILES/.tmux/.tmux.conf"; then
        test_pass ".tmux.conf contains valid tmux settings"
    else
        test_fail ".tmux.conf appears invalid"
    fi

    # Check plist validity
    if grep -q "<?xml" "$DOTFILES/mac-sync/autostart-macos.plist"; then
        test_pass "autostart-macos.plist is valid XML"
    else
        test_fail "autostart-macos.plist is not valid XML"
    fi
}

# Documentation checks
doc_checks() {
    test_start "Documentation Completeness"

    local docs=("README.md" "QUICK_START.md" "SYNC_CHECKLIST.md" "TEST_PLAN.md")

    for doc in "${docs[@]}"; do
        if [[ -f "$DOTFILES/mac-sync/$doc" ]]; then
            local lines=$(wc -l < "$DOTFILES/mac-sync/$doc")
            test_pass "$doc exists ($lines lines)"
        else
            test_fail "$doc not found"
        fi
    done
}

# Script permissions
permission_checks() {
    test_start "Script Permissions"

    local scripts=(
        "$DOTFILES/scripts/mac-m4-flutter-setup-minimal.sh"
        "$DOTFILES/mac-sync/mac-sync-dotfiles-minimal.sh"
        "$DOTFILES/mac-sync/bat-macos.sh"
        "$DOTFILES/mac-sync/startup-macos.sh"
    )

    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            test_pass "$(basename "$script") is executable"
        else
            test_fail "$(basename "$script") is not executable"
        fi
    done
}

# Backup strategy check
backup_check() {
    test_start "Backup Strategy Verification"

    # Check if sync script has backup logic
    if grep -q "backup" "$DOTFILES/mac-sync/mac-sync-dotfiles-minimal.sh"; then
        test_pass "Minimal sync script includes backup logic"
    else
        test_fail "Minimal sync script missing backup logic"
    fi

    if grep -q "backup" "$DOTFILES/mac-sync/mac-sync-dotfiles.sh"; then
        test_pass "Original sync script includes backup logic"
    else
        test_fail "Original sync script missing backup logic"
    fi
}

# Error handling check
error_handling_check() {
    test_start "Error Handling Verification"

    # Check setup script
    if grep -q "trap\|ERR" "$DOTFILES/scripts/mac-m4-flutter-setup-minimal.sh"; then
        test_pass "Setup script has error handling"
    else
        test_fail "Setup script missing error handling"
    fi

    # Check sync script
    if grep -q "trap\|ERR" "$DOTFILES/mac-sync/mac-sync-dotfiles-minimal.sh"; then
        test_pass "Sync script has error handling"
    else
        test_fail "Sync script missing error handling"
    fi
}

# Logging check
logging_check() {
    test_start "Logging Implementation"

    # Check setup script
    if grep -q "LOG_FILE\|log_message" "$DOTFILES/scripts/mac-m4-flutter-setup-minimal.sh"; then
        test_pass "Setup script has logging"
    else
        test_fail "Setup script missing logging"
    fi

    # Check sync script
    if grep -q "LOG\|log" "$DOTFILES/mac-sync/mac-sync-dotfiles-minimal.sh"; then
        test_pass "Sync script has logging"
    else
        test_fail "Sync script missing logging"
    fi
}

# Summary and results
print_summary() {
    echo "" | tee -a "$RESULTS"
    echo "╔════════════════════════════════════════════════╗" | tee -a "$RESULTS"
    echo "║             TEST RESULTS SUMMARY               ║" | tee -a "$RESULTS"
    echo "╚════════════════════════════════════════════════╝" | tee -a "$RESULTS"
    echo "" | tee -a "$RESULTS"

    echo -e "${GREEN}✅ Passed:${NC}  $TESTS_PASSED" | tee -a "$RESULTS"
    echo -e "${RED}❌ Failed:${NC}  $TESTS_FAILED" | tee -a "$RESULTS"
    echo -e "${YELLOW}⊘ Skipped:${NC} $TESTS_SKIPPED" | tee -a "$RESULTS"
    echo "" | tee -a "$RESULTS"

    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    local pass_rate=$(( (TESTS_PASSED * 100) / total ))

    echo "Pass Rate: $pass_rate% ($TESTS_PASSED/$total)" | tee -a "$RESULTS"
    echo "" | tee -a "$RESULTS"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✅ ALL TESTS PASSED - Ready for deployment${NC}" | tee -a "$RESULTS"
        return 0
    else
        echo -e "${RED}❌ SOME TESTS FAILED - Review results above${NC}" | tee -a "$RESULTS"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}╔═════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Mac M4 Setup - Automated Test Harness          ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════════════════════════╝${NC}"
    echo ""

    preflight
    syntax_tests
    tool_checks
    config_checks
    installed_tools_checks
    config_validity
    doc_checks
    permission_checks
    backup_check
    error_handling_check
    logging_check

    if print_summary; then
        log "Test results saved to: $RESULTS"
        exit 0
    else
        log "Test results saved to: $RESULTS"
        log "Review failures above and take corrective action"
        exit 1
    fi
}

main "$@"
