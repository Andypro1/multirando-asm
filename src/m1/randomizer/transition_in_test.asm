; BlueBrinstarDoorExit.asm
; --------------------------
; SNES/65816 helper for dropping directly into the tail end of a Metroid
; door transition.  This initializes the restored NES work RAM to show Samus
; emerging from the left door into the blue Brinstar vertical shaft at world
; map position X=$0B, Y=$0C.
;
; This file is written for Asar-style syntax.
;
; Important placement rule:
;   The embedded NES routines end in RTS, not RTL.  Assemble this routine into
;   SNES bank $91, the bank that contains NES Bank01 at $918000-$91BFFF and
;   the fixed NES bank at $91C000-$91FFFF.  Then same-bank JSR calls work and
;   all absolute ROM reads use DBR=$91.
;
; If this routine must live in another SNES bank, add bank-local shims in $91
; that JSR the NES routines here and RTL back to your caller.
;
; Expected NES PRG layout in SNES ROM:
;   $918000-$91BFFF = NES Bank01, Brinstar area bank
;   $91C000-$91FFFF = NES Bank07, fixed bank mirror
;
; Entry:
;   JML BlueBrinstarDoorExit
;
; Exit:
;   JML $91C0BC, the NES main loop.  This routine does not return.

; Uncomment or set an org in the including file before incsrc'ing this file.
; org $91F000

; -------------------------------
; Config
; -------------------------------

!BRINSTAR_BANK        = $91

!TARGET_MAP_X         = $0B
!TARGET_MAP_Y         = $0C

; Left door of the destination room.  For map X+Y=$17, LoadDoor puts:
;   left-side door  in object slot $90, X=$10
;   right-side door in object slot $A0, X=$F0
!EXIT_DOOR_SLOT       = $90
!EXIT_DOOR_X          = $10
!EXIT_DOOR_Y          = $68
!EXIT_DOOR_HI         = $00

; "Left-to-right door" means Samus exits to the right.
; Change to $01 if you want the opposite/right-to-left exit behavior.
!SAMUS_EXIT_DIR       = $00
!SAMUS_EXIT_ACTION    = $01       ; sa_Run, restored when DoorDelay expires.

; A left-to-right horizontal door toggles horizontal scrolling to vertical-up
; scrolling.  Change to $01 if the destination should continue vertical-down.
!DEST_SCROLL_DIR      = $00
!DEST_MIRROR_CNTRL    = $2F       ; bit 3 set = horizontal mirroring / vertical scroll.

; Destination door state normally created by the source door object when
; DoorStatus reaches 5 at the end of scrolling.
!DOOR_EXIT_ACTION     = $06
!DOOR_EXIT_ANIM       = $29
!DOOR_EXIT_ANIM_RESET = $2C

; Optional actual SNES NMI enable.  The NES routine NmiOn updates the NES PPU
; control shadow/registers; this write enables the SNES CPU NMI line too.
!SNES_NMITIMEN        = $004200
!SNES_NMI_ENABLE      = $81       ; NMI enable + joypad auto-read.

; -------------------------------
; NES RAM aliases
; -------------------------------

!GameMode             = $001D
!MainRoutine          = $001E
!CurrentBank          = $0023
!SwitchPending        = $0024
!NMIStatus            = $001A
!PPUDataPending       = $001B
!FrameCount           = $002D

!RoomPtr              = $0033
!CartRAMPtrLB         = $0039
!CartRAMPtrUB         = $003A
!RoomPtrTable         = $003B
!PageIndex            = $004B
!ScrollDir            = $0049
!TempScrollDir        = $004A
!SamusDir             = $004D
!SamusDoorDir         = $004E
!MapPosY              = $004F
!MapPosX              = $0050
!SamusScrX            = $0051
!SamusScrY            = $0052
!DoorStatus           = $0056
!DoorScrollStatus     = $0057
!SamusDoorData        = $0058
!DoorDelay            = $0059
!RoomNumber           = $005A
!DoorOnNameTable3     = $006C
!DoorOnNameTable0     = $006D
!InArea               = $0074
!ItemRmMusicSts       = $0079
!MirrorCntrl          = $00FA
!ScrollY              = $00FC
!ScrollX              = $00FD
!PPUCNT1ZP            = $00FE
!PPUCNT0ZP            = $00FF

!ObjAction            = $0300
!AnimDelay            = $0304
!AnimResetIndex       = $0305
!AnimIndex            = $0306
!ObjectOnScreen       = $030B
!ObjectHi             = $030C
!ObjectY              = $030D
!ObjectX              = $030E
!ObjVertSpeed         = $0308
!ObjHorzSpeed         = $0309
!VertCntrNonLinr      = $0310
!HorzCntrNonLinr      = $0311
!VertCntrLinear       = $0312
!HorzCntrLinear       = $0313
!SamusGravity         = $0314

!PPUStrIndex          = $07A0

; NES hardware-register aliases used by the embedded code.  These are the
; original NES addresses; your SNES-side NES runtime must already handle them.
!PPUControl0          = $2000
!PPUControl1          = $2001
!PPUStatus            = $2002
!PPUAddress           = $2006
!PPUIOReg             = $2007

; -------------------------------
; NES routine addresses in bank $91
; -------------------------------

!NES_MainLoopLong     = $91C0BC
!NES_WritePPUCtrl     = $C44D
!NES_NmiOn            = $C487
!NES_CopyPtrs         = $C8B5
!NES_DestroyEnemies   = $C8BB
!NES_GetRoomNum       = $E720
!NES_SetupRoom        = $EA2B
!NES_OpenDoorTiles    = $8CFB     ; Writes the open-door tile column into RoomRAM.

; -------------------------------
; Public entry
; -------------------------------

BlueBrinstarDoorExit:
    sei
    clc
    xce                         ; native mode if caller arrived in emulation mode.
    sep #$30                    ; NES code expects 8-bit A/X/Y.

    lda #!BRINSTAR_BANK
    pha
    plb                         ; DBR=$91 for absolute ROM reads.

    rep #$20
    lda #$0000
    tcd                         ; direct page = NES zero page.
    sep #$30

    jsr InitCoreState
    jsr LoadDestinationRoom
    jsr SeedOpenExitDoor
    jsr CopyCurrentRoomRamToNameTable0
    jsr ArmDoorExitState
    jsr EnableNmiAndDisplay

    cli
    jml !NES_MainLoopLong

; -------------------------------
; State setup
; -------------------------------

InitCoreState:
    stz !GameMode               ; gameplay mode.
    lda #$03
    sta !MainRoutine            ; run GameEngine.
    lda #$01
    sta !CurrentBank            ; Brinstar area bank.
    stz !SwitchPending

    lda #$10
    sta !InArea                 ; Brinstar.

    lda #!TARGET_MAP_Y
    sta !MapPosY
    lda #!TARGET_MAP_X
    sta !MapPosX

    lda #!DEST_SCROLL_DIR
    sta !ScrollDir
    sta !TempScrollDir
    stz !ScrollX
    stz !ScrollY

    ; Use nametable 0 as the visible, non-scrolling screen.
    lda !PPUCNT0ZP
    and #$78                    ; preserve non-nametable/non-increment bits, clear NMI.
    sta !PPUCNT0ZP
    sta !PPUControl0

    lda !PPUCNT1ZP
    and #$E7                    ; display off while we build/copy the room.
    sta !PPUCNT1ZP
    sta !PPUControl1

    lda #!DEST_MIRROR_CNTRL
    sta !MirrorCntrl

    stz !DoorOnNameTable3
    stz !DoorOnNameTable0
    stz !PPUDataPending
    stz !PPUStrIndex
    stz !ItemRmMusicSts

    ; jsr !NES_CopyPtrs           ; Brinstar room/struct/macro/enemy pointer tables.
    jsl $911000 : dw !NES_CopyPtrs
    ; jsr !NES_DestroyEnemies     ; Clear stale enemies/room objects.
    jsl $911000 : dw !NES_DestroyEnemies
    rts

LoadDestinationRoom:
    lda #$FF
    sta !RoomNumber
    ; jsr !NES_GetRoomNum         ; RoomNumber = WorldMapRAM[$718B].
    jsl $911000 : dw !NES_GetRoomNum

.setupLoop:
    ; jsr !NES_SetupRoom          ; Loads room structures/enemies/doors into RoomRAM.
    jsl $911000 : dw !NES_SetupRoom
    ldy !RoomNumber
    iny
    bne .setupLoop

    ; Full RoomRAM copy below makes the incremental PPU strings redundant.
    stz !PPUDataPending
    stz !PPUStrIndex
    rts

SeedOpenExitDoor:
    ; Force/fix the destination door object in case the loaded room's door
    ; object has not advanced to the open state yet.  The RoomRAM door column
    ; is opened before the full nametable copy, so the door bubble is visibly
    ; open immediately.
    ldx #!EXIT_DOOR_SLOT
    stx !PageIndex

    lda #!EXIT_DOOR_HI
    sta !ObjectHi+!EXIT_DOOR_SLOT
    lda #!EXIT_DOOR_X
    sta !ObjectX+!EXIT_DOOR_SLOT
    lda #!EXIT_DOOR_Y
    sta !ObjectY+!EXIT_DOOR_SLOT
    lda #$01
    sta !ObjectOnScreen+!EXIT_DOOR_SLOT

    ; jsr !NES_OpenDoorTiles      ; Uses X/PageIndex and door object position.
    jsl $911000 : dw !NES_OpenDoorTiles

    lda #!DOOR_EXIT_ACTION
    sta !ObjAction+!EXIT_DOOR_SLOT
    lda #!DOOR_EXIT_ANIM_RESET
    sta !AnimResetIndex+!EXIT_DOOR_SLOT
    lda #!DOOR_EXIT_ANIM
    sta !AnimIndex+!EXIT_DOOR_SLOT
    stz !AnimDelay+!EXIT_DOOR_SLOT
    rts

CopyCurrentRoomRamToNameTable0:
    ; Matches the direct copy used by AreaInit after SetupRoom finishes.
    ldy !CartRAMPtrUB
    sty $01
    ldy !CartRAMPtrLB
    sty $00

    lda !PPUCNT0ZP
    and #$FB                    ; PPU increment = 1.
    sta !PPUCNT0ZP
    sta !PPUControl0

    ldy !PPUStatus              ; reset PPU address latch.
    ldy #$20
    sty !PPUAddress
    ldy #$00
    sty !PPUAddress

    ldx #$04                    ; 4 pages = 1 nametable + attributes.
.pageLoop:
    lda ($00),y
    sta !PPUIOReg
    iny
    bne .pageLoop
    inc $01
    dex
    bne .pageLoop
    rts

ArmDoorExitState:
    ; This is the state immediately after DoOneDoorScroll in the original
    ; door transition, i.e. the screen is already in the destination room and
    ; Samus is about to be moved out of the door by SamusDoor.
    lda #$05
    sta !DoorStatus             ; exit-door phase.
    lda #$04
    sta !DoorScrollStatus       ; vertical destination already centered.
    lda #$10|!SAMUS_EXIT_ACTION
    sta !SamusDoorData          ; normal door, restore running/walking.
    lda #$20
    sta !DoorDelay              ; normal exit-door delay.
    lda #$05
    sta !ObjAction              ; sa_Door.

    lda #!SAMUS_EXIT_DIR
    sta !SamusDoorDir
    sta !SamusDir

    lda #!EXIT_DOOR_HI
    sta !ObjectHi
    lda #!EXIT_DOOR_X
    sta !ObjectX
    sta !SamusScrX
    lda #!EXIT_DOOR_Y
    sta !ObjectY
    sta !SamusScrY

    stz !ObjVertSpeed
    stz !ObjHorzSpeed
    stz !VertCntrNonLinr
    stz !HorzCntrNonLinr
    stz !VertCntrLinear
    stz !HorzCntrLinear
    stz !SamusGravity
    rts

EnableNmiAndDisplay:
    ; Turn the NES display shadows back on, then run the NES NMI-on routine.
    lda !PPUCNT1ZP
    ora #$1E                    ; BG + sprites visible.
    sta !PPUCNT1ZP
    sta !PPUControl1

    ; jsr !NES_NmiOn              ; sets bit 7 in PPUCNT0ZP/PPUControl0.
    jsl $911000 : dw !NES_NmiOn
    ; jsr !NES_WritePPUCtrl
    jsl $911000 : dw !NES_WritePPUCtrl

    lda #!SNES_NMI_ENABLE
    sta.l !SNES_NMITIMEN

    lda #$01
    sta !NMIStatus              ; do not strand the main loop before first NMI.
    rts
