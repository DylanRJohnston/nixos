#!/run/current-system/sw/bin/nix-shell
#!nix-shell -i bash -p bash i3lock-color

invisible='#00000000'
prominent='fdf6e3dd'
background='#fdf6e311'

i3lock-color \
  --insidever-color=$invisible \
  --insidewrong-color=$invisible \
  --inside-color=$invisible \
  --ringver-color=$prominent \
  --ringwrong-color=$prominent \
  --ring-color=$background \
  --line-color=$invisible \
  --keyhl-color=$prominent \
  --bshl-color=$prominent \
  --separator-color=$invisible \
  --verif-color=$prominent \
  --wrong-color=$prominent \
  --layout-color=$prominent \
  --date-color=$prominent \
  --time-color=$prominent \
  --screen 1 \
  --image $HOME/Pictures/background.png \
  --clock \
  --indicator \
  --time-str="%H:%M:%S" \
  --date-str="%a %b %e %Y" \
  --verif-text="Verifying..." \
  --wrong-text="Failed" \
  --noinput="No Input" \
  --lock-text="Locking..." \
  --lockfailed="Lock Failed" \
  --time-font="Helvetica" \
  --date-font="Helvetica" \
  --layout-font="Helvetica" \
  --verif-font="Helvetica" \
  --wrong-font="Helvetica" \
  --radius=100 \
  --ring-width=20 \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys \