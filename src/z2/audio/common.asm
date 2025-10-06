print "z2-apu-routines = ", pc

;  Group of methods for the square wave 0 channel
Sq0:

;  Methods and properties for duty
.Duty

..WriteX:
    stx.w z2_Sq0Duty_4000
    rts

..WriteY:
    sty.w z2_Sq0Duty_4000
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
    bne ...next2
    sta z2_Sq1Timer_4006
...next2:
    cpx #$08
    bne ...done
    sta z2_TrgTimer_400A
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
    bne ...next2
    sta z2_Sq1Length_4007
    tax
    lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
    sta.w z2_APUSq1Length ; $922 - not a well-named variable..
    xba
    lda #$02
    tsb.w z2_ApuStatus_4015
    tsb.w z2_APUExtraControl
    bra ...done
...next2:
    cpx #$08
    bne ...done
    sta z2_TrgLength_400B
    tax
    lda #$04
    tsb.w z2_APUExtraControl
    tsb.w z2_ApuStatus_4015
    lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
    sta.w z2_APUTriLength ; $924 - not a well-named variable..
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

;  Group of methods for the triangle channel
Tri:

;  Methods and properties for linear
.Linear

..WriteY:
    sty.w z2_TrgLinear_4008
    rts

;  Group of methods for the noise channel
Noise:

;  Methods and properties for volume
.Volume

..WriteA:
    sta z2_NoiseVolume_400C
    rts

;  Methods and properties for noise frequency
.Period

..WriteA:
    sta z2_NoisePeriod_400E
    rts

..WriteX:
    stx.w z2_NoisePeriod_400E
    rts

;  Methods and properties for note length
.Length

..WriteA:
    phx
    sta z2_NoiseLength_400F
    tax
    lda #$08
    tsb.w z2_APUExtraControl
    tsb.w z2_ApuStatus_4015
    lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
    sta.w z2_APUNoiLength ; $0926 - not a well-named variable..
    txa
    plx
    rts

..WriteY:
    phx
    sty.w z2_NoiseLength_400F
    tax
    lda #$08
    tsb.w z2_APUExtraControl
    tsb.w z2_ApuStatus_4015
    lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
    sta.w z2_APUNoiLength ; $0926 - not a well-named variable..
    txa
    plx
    rts


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