; Common code/data that's always mapped in for a set of games or other things

; Common NES code/data
sa1rom 0,0,6,7
namespace nes
org $9F8000
incsrc "nes/overlay.asm"
warnpc $9FFFFF

; FB0000-FB7FFFF (free)
; Align data to $8000 to match pointers
org $FF8000
incsrc "nes/data.asm"
warnpc $FFE000
