#!/bin/bash

#exec compton &
exec picom -b -f -i 0.8 -e 1 &
#exec dwmstatus 2>&1 >/dev/null &
exec guake &
exec slstatus &
