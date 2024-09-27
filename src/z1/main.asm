namespace z1
sa1rom 0,0,6,7

!BASE_BANK = $80

; Temp code that incbins the ROM in the right places
incsrc "rom.asm"

; Include hooks
incsrc "hooks.asm"

; Include common code (will be copied to WRAM $1000-$1FFF when switching to M1)
; The reason for this is that the main "common" MMC1 bank at $C000-$FFFF is more or less full
; so instead we use this free space in WRAM for code accessible from all banks
org $878000
base $7E1000
incsrc "common.asm"
warnpc $879000

; Include SNES port functions that doesn't have to be in the common code area
org $888000
incsrc "labels.asm"
incsrc "init.asm"
incsrc "snes.asm"

; Include randomizer additions
incsrc "randomizer/main.asm"
incsrc "dpcm.asm"

;  DPCM audio
org $898000
brr:
.swordbeam:
incbin "audio/sword-beam.brr"
.swordbeamend:
db $00
warnpc $89ffff

namespace off
