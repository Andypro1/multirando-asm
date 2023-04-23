; Check for specific door and teleport to ALTTP
;

org $82e2fa
    jsl sm_check_teleport

org $d00000
sm_check_teleport:
    phx
    pha
    php
    %ai16()

    ldx #$0000
-
    lda.l sm_teleport_table,x
    beq ++
    cmp $078d
    beq +
    txa
    clc
    adc #$0038
    tax
    bne -
    jmp ++
+
    jmp sm_do_teleport
++
    plp
    pla
    plx
    jsl $8882ac
    rtl

sm_do_teleport:
    lda.l sm_teleport_table+$2,x
    ;sta !SRAM_ALTTP_EXIT            ; Store ALTTP exit id
    lda.l sm_teleport_table+$4,x
    ;sta !SRAM_ALTTP_DARKWORLD       ; Store dark world status

;     ldy #$0000
; -
;     lda.l sm_teleport_table+$6,x
;     phx
;     tyx
;     sta.l !SRAM_ALTTP_OVERWORLD_BUF,x
;     plx
;     inx
;     inx
;     iny
;     iny
;     cpy #$0032
;     bne -
    
;     lda #$001c                      ; Add transition to ALTTP
;     jsl inc_stat
    
    jsl $8085c6                     ; Save map data

    lda #$0000
    jsl $818000                     ; Save SRAM

    lda #$0000
    sta.l $806166
    sta.l $806168                   ; Set these values to 0 to force load from the ship if samus dies
    jsl sm_fix_checksum             ; Fix SRAM checksum (otherwise SM deletes the file on load)

    jml transition_to_zelda         ; Call transition routine to ALTTP

sm_teleport_table:
    ; door_id, cave_id, darkworld, [0x20 bytes from $7ec140-7ec150 (Overworld position / scroll data)]
    ; Crateria map station -> Fortune teller
    dw $8976, $0122, $0000
        db $35, $00, $16, $00, $6a, $0c, $00, $0a, $c8, $0c, $58, $0a, $35, $00, $80, $03
        db $d7, $0c, $7d, $0a, $00, $0c, $1e, $0f, $00, $0a, $00, $0d, $20, $0b, $00, $10
        db $00, $09, $00, $0e, $00, $20, $27, $04, $00, $00, $06, $00, $fa, $ff, $00, $00
        db $00, $00
    ; Norfair map station -> Cave on death mountain             97c2
    dw $9306, $00e5, $0000
        db $03, $00, $16, $01, $26, $02, $1e, $08, $87, $02, $88, $08, $03, $00, $c2, $10
        db $93, $02, $93, $08, $00, $00, $1e, $03, $00, $06, $00, $09, $20, $ff, $00, $04
        db $00, $05, $00, $0a, $00, $20, $22, $10, $00, $00, $08, $00, $f8, $ff, $02, $00
        db $fe, $ff

    ; Maridia missile refill -> Dark world ice rod cave (right) a894  
    dw $a8f4, $010e, $0040 
        db $77, $00, $16, $00, $00, $0c, $22, $0e, $47, $0c, $98, $0e, $77, $00, $86, $00
        db $6f, $0c, $a3, $0e, $00, $0c, $1e, $0d, $00, $0e, $00, $0f, $20, $0b, $00, $0e
        db $00, $0d, $00, $10, $00, $21, $40, $19, $00, $00, $00, $00, $00, $00, $0e, $00
        db $f2, $ff

    ; ; LN GT refill -> Misery mire right side fairy              98a6
    ; dw NewLNRefillDoorData_exit, $0115, $0040 
    ;     db $70, $00, $16, $01, $64, $0c, $36, $01, $c7, $0c, $b8, $01, $70, $00, $26, $03          
    ;     db $d3, $0c, $c1, $01, $00, $0c, $1e, $0f, $00, $00, $00, $03, $20, $0b, $00, $10
    ;     db $00, $ff, $00, $04, $00, $21, $42, $16, $00, $00, $0a, $00, $f6, $ff, $fa, $ff
    ;     db $06, $00
    
    dw $0000

sm_fix_checksum:
    pha
    phx
    phy
    php

    %ai16()
    
    lda $14
    pha
    stz $14
    ldx #$0010
 -
    lda.l $806000,x
    clc
    adc $14
    sta $14
    inx
    inx
    cpx #$065c
    bne -

    ldx #$0000
    lda $14
    sta.l $806000,x
    sta.l $807ff0,x
    eor #$ffff
    sta.l $806008,x
    sta.l $807ff8,x
    pla
    sta $14

    plp
    ply
    plx
    pla
    rtl

transition_to_zelda:
    sei                         ; Disable IRQ's
    
    %a8()
    %i16()

    phk
    plb                         ; Set data bank program bank

    lda #$00
    sta $004200                 ; Disable NMI and Joypad autoread
    sta $00420c                 ; Disable H-DMA

    lda #$8f
    sta $002100                 ; Enable PPU force blank

    jsl zelda_spc_reset         ; Kill the SM music engine and put the SPC in IPL upload mode
                                ; Gotta do this before switching RAM contents

; -
;     bit $4212                   ; Wait for a fresh NMI
;     bmi -

; -
;     bit $4212
;     bpl -

    ; Set things up for Zelda 1 for now
    sep #$20
    
    lda #$86
    sta $002222   ; Swap Z1 bank into $80-9F

    ; Set stack to be NES-compatible
    rep #$30
    ldx #$01FF
    txs

    ; Write Z1 NMI to I-RAM
    lda #$105c
    sta.l !IRAM_NMI
    lda #$0008
    sta.l !IRAM_NMI+2  

    sep #$30

    lda #$02
	sta $002224

    ; Jump to zelda 1 init code
    jml z1_SnesBoot


zelda_spc_reset:
    pha
    php
    %a8()
    
    lda #$ff                    ; Send N-SPC into "upload mode"
    sta $2140

    rep #$30
    lda #$0000
    sta $12
    sta $14

    jsl $80800a
    db alttp_spc_data, (alttp_spc_data>>8)+$80, alttp_spc_data>>16

    plp
    pla
    rtl

; This must be placed below $8000 in a bank due to SM music upload code changes
org $d10000
base $e28000
    alttp_spc_data:        ; Upload this data to the SM music engine to kill it and put it back into IPL mode
        dw $002a, $15a0
        db $8f, $6c, $f2 
        db $8f, $e0, $f3 ; Disable echo buffer writes and mute amplifier
        db $8f, $7c, $f2 
        db $8f, $ff, $f3 ; ENDX
        db $8f, $7d, $f2 
        db $8f, $00, $f3 ; Disable echo delay
        db $8f, $4d, $f2 
        db $8f, $00, $f3 ; EON
        db $8f, $5c, $f2 
        db $8f, $ff, $f3 ; KOFF
        db $8f, $5c, $f2 
        db $8f, $00, $f3 ; KOFF
        db $8f, $80, $f1 ; Enable IPL ROM
        db $5f, $c0, $ff ; jmp $ffc0
        dw $0000, $1500