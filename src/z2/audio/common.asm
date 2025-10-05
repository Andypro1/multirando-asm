print "z2-apu-routines = ", pc

;  Group of methods for the square wave 0 channel
Sq0:

;  Methods and properties for duty
.Duty

..WriteX:
    stx.w z2_Sq0Duty_4000
    rts

;  Methods and properties for pitch sweep
.Sweep

..WriteY:
    xba
    lda #$40
    tsb.w z2_APUExtraControl
    xba
    sty.w z2_Sq0Sweep_4001
    rts

;  Methods and properties for the timer
.Timer

..WriteXIndexed:
    cpx #$00
    bne ...next
    sta z2_Sq0Timer_4002
...next:
    cpx #$04
    bne ...done
    sta z2_Sq1Timer_4006
...done:
    rts

;  Methods and properties for note length
.Length

..WriteXIndexed:
    pha : phx
    cpx #$00
    bne ...next
    sta z2_Sq0Length_4003
    tax
    lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
    sta.w z2_APUSq0Length ; $920 - not a well-named variable..
    xba
    lda #$01
    tsb.w z2_ApuStatus_4015
    tsb.w z2_APUExtraControl
    bra ...done
...next:
    cpx #$04
    bne ...done
    sta z2_Sq1Length_4007
    tax
    lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
    sta.w z2_APUSq1Length ; $922 - not a well-named variable..
    xba
    lda #$02
    tsb.w z2_ApuStatus_4015
    tsb.w z2_APUExtraControl
...done:
    plx : pla
    rts


;  Group of methods for the square wave 1 channel
Sq1:

;  Methods and properties for duty
.Duty

..WriteX:
    stx.w z2_Sq1Duty_4004
    rts

;  Methods and properties for pitch sweep
.Sweep

..WriteY:
    xba
    lda #$80
    tsb.w z2_APUExtraControl
    xba
    sty.w z2_Sq1Sweep_4005
    rts








; z2_WriteAPUSq0Ctrl0:
;     sta.w z2_APUBase
;     rts






; z2_WriteAPUSq0Ctrl0_I_Y:
;     sta.w z2_APUBase, y
;     rts

; z2_WriteAPUSq0Ctrl0_Y:
;     sty.w z2_APUBase
;     rts

; z2_WriteAPUSq0Ctrl0_X:
;     stx.w z2_APUBase
;     rts

; z2_WriteAPUSq0Ctrl1:
;     xba
;     lda #$40
;     tsb.w z2_APUBase+$16
;     xba
;     sta.w z2_APUBase+$01
;     rts

; z2_WriteAPUSq0Ctrl1_Y:
;     xba
;     lda #$40
;     tsb.w z2_APUBase+$16
;     xba
;     sty.w z2_APUBase+$01
;     rts

; z2_WriteAPUSq0Ctrl1_I_Y:
;     cpy #$00
;     bne +
;     jsr z2_WriteAPUSq0Ctrl1
;     rts
; +
;     ; cpy #$04
;     ; bne +
;     ; jsr z2_WriteAPUSq1Ctrl1
;     ; rts
; +
;     sta $0901, y
;     rts

; z2_WriteAPUSq0Ctrl3:
;     phx
;     sta.w z2_APUBase+$03
;     tax
;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
;     sta.w z2_APUSq0Length
;     xba
;     lda #$01
;     tsb.w z2_APUBase+$15
;     tsb.w z2_APUExtraControl
;     plx
;     xba
;     rts

; z2_WriteAPUSq0Ctrl3_X:
;     pha
;     stx.w z2_APUBase+$03
;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
;     sta.w z2_APUSq0Length
;     lda #$01
;     tsb.w z2_APUBase+$15
;     tsb.w z2_APUExtraControl
;     pla
;     rts

; z2_WriteAPUSq0Ctrl3_I_Y:
;     cpy #$00
;     bne +
;     jsr z2_WriteAPUSq0Ctrl3
;     rts
; +
;     ; cpy #$04
;     ; bne +
;     ; jsr z2_WriteAPUSq1Ctrl3
;     ; rts
; +
;     ; cpy #$08
;     ; bne +
;     ; jsr z2_WriteAPUTriCtrl3
;     ; rts
; +
;     ; jsr z2_WriteAPUNoiseCtrl3
;     rts

; ; WriteAPUSq1Ctrl0:
; ;     sta.w APUBase+$04
; ;     rts

; ; WriteAPUSq1Ctrl0_X:
; ;     stx.w APUBase+$04
; ;     rts

; ; WriteAPUSq1Ctrl0_Y:
; ;     sty.w APUBase+$04
; ;     rts

; ; WriteAPUSq1Ctrl1:
; ;     xba
; ;     lda #$80
; ;     tsb.w APUBase+$16
; ;     xba
; ;     sta.w APUBase+$05
; ;     rts

; ; WriteAPUSq1Ctrl1_X:
; ;     xba
; ;     lda #$80
; ;     tsb.w APUBase+$16
; ;     xba
; ;     stx.w APUBase+$05
; ;     rts

; ; WriteAPUSq1Ctrl1_Y:
; ;     xba
; ;     lda #$80
; ;     tsb.w APUBase+$16
; ;     xba
; ;     sty.w APUBase+$05
; ;     rts

; ; WriteAPUSq1Ctrl2:
; ;     sta.w APUBase+$06
; ;     rts

; ; WriteAPUSq1Ctrl2_X:
; ;     stx.w APUBase+$06
; ;     rts

; ; WriteAPUSq1Ctrl3:
; ;     phx
; ;     sta.w APUBase+$07
; ;     tax
; ;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
; ;     sta.w APUSq1Length
; ;     xba
; ;     lda #$02
; ;     tsb.w APUBase+$15
; ;     tsb.w APUExtraControl
; ;     plx
; ;     xba
; ;     rts

; ; WriteAPUSq1Ctrl3_X:
; ;     pha
; ;     stx.w APUBase+$07
; ;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
; ;     sta.w APUSq1Length
; ;     lda #$02
; ;     tsb.w APUBase+$15
; ;     tsb.w APUExtraControl
; ;     pla
; ;     rts

; ; WriteAPUTriCtrl0:
; ;     sta.w APUBase+$08
; ;     rts

; ; WriteAPUTriCtrl1:
; ;     sta.w APUBase+$09
; ;     rts

; ; WriteAPUTriCtrl2:
; ;     sta.w APUBase+$0A
; ;     rts

; ; WriteAPUTriCtrl2_X:
; ;     stx.w APUBase+$0A
; ;     rts

; ; WriteAPUTriCtrl3:
; ;     phx
; ;     sta.w APUBase+$0B
; ;     tax
; ;     lda #$04
; ;     tsb.w APUExtraControl
; ;     tsb.w APUBase+$15
; ;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
; ;     sta.w APUTriLength
; ;     txa
; ;     plx
; ;     rts

; ; WriteAPUNoiseCtrl0:
; ;     sta.w APUBase+$0C
; ;     rts

; ; WriteAPUNoiseCtrl1:
; ;     sta.w APUBase+$0D
; ;     rts

; ; WriteAPUNoiseCtrl2:
; ;     sta.w APUBase+$0E
; ;     rts

; ; WriteAPUNoiseCtrl2_X:
; ;     stx.w APUBase+$0E
; ;     rts

; ; WriteAPUNoiseCtrl3:
; ;     phx
; ;     sta.w APUBase+$0F
; ;     tax
; ;     lda #$08
; ;     tsb.w APUExtraControl
; ;     tsb.w APUBase+$15
; ;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
; ;     sta.w APUNoiLength
; ;     txa
; ;     plx
; ;     rts

z2_WriteAPUControl:
    sta.w z2_APUIOTemp
    xba
    lda.w z2_APUIOTemp
    eor.b #$ff
    and.b #$1f
    trb.w z2_APUBase+$15
    trb.w z2_APUExtraControl
    lsr.w z2_APUIOTemp
    bcs +
        stz.w z2_APUBase+$03
        stz.w z2_APUSq0Length
+
    lsr.w z2_APUIOTemp
    bcs +
        stz.w z2_APUBase+$07
        stz.w z2_APUSq1Length
+
    lsr.w z2_APUIOTemp
    bcs +
        stz.w z2_APUBase+$0B
        stz.w z2_APUTriLength
+
    lsr.w z2_APUIOTemp
    bcs +
        stz.w z2_APUBase+$0F
        stz.w z2_APUNoiLength
+
    lsr.w z2_APUIOTemp
    bcc +
        lda.b #$10
        tsb.w z2_APUBase+$15
        bne +
            tsb.w z2_APUExtraControl
+
    xba
    rts

; WriteAPUDMCCounter:
;     stx.w DmcCounter_4011
; rts

; WriteAPUDMCFreq:
;     sta DmcFreq_4010
; rts

; WriteAPUDMCAddr:
;     sta DmcAddress_4012
; rts

; WriteAPUDMCLength:
;     sta DmcLength_4013
; rts

; WriteAPUDMCPlay:
;     sta ApuStatus_4015
;     and #%00010000
;     sta APUExtraControl
; rts


Sound__EmulateLengthCounter_length_d3_mixed:
fillbyte $06 : fill 8
fillbyte $80 : fill 8
fillbyte $0B : fill 8
fillbyte $02 : fill 8
fillbyte $15 : fill 8
fillbyte $03 : fill 8
fillbyte $29 : fill 8
fillbyte $04 : fill 8
fillbyte $51 : fill 8
fillbyte $05 : fill 8
fillbyte $1F : fill 8
fillbyte $06 : fill 8
fillbyte $08 : fill 8
fillbyte $07 : fill 8
fillbyte $0F : fill 8
fillbyte $08 : fill 8
fillbyte $07 : fill 8
fillbyte $09 : fill 8
fillbyte $0D : fill 8
fillbyte $0A : fill 8
fillbyte $19 : fill 8
fillbyte $0B : fill 8
fillbyte $31 : fill 8
fillbyte $0C : fill 8
fillbyte $61 : fill 8
fillbyte $0D : fill 8
fillbyte $25 : fill 8
fillbyte $0E : fill 8
fillbyte $09 : fill 8
fillbyte $0F : fill 8
fillbyte $11 : fill 8
fillbyte $10 : fill 8
