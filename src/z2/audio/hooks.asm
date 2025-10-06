optimize address ram

;  From labels.asm:
; z2_APUBase = $0900
; z2_APUExtraControl = $0916
; z2_APUSq0Length = $0920
; z2_APUSq1Length = $0922
; z2_APUTriLength = $0924
; z2_APUNoiLength = $0926
; z2_APUIOTemp = $0928

!B0 = ((!BASE_BANK)<<16)
!B6 = ((!BASE_BANK+$6)<<16)
!B7 = ((!BASE_BANK+$7)<<16)

; Big old list of nes apu writes:

; 166AE  8D 11 40       STA DmcCounter_4011

; 1904A  9D 02 40       STA Sq0Timer_4002,X
; 19060  9D 03 40       STA Sq0Length_4003,X
; 190B1  9D 02 40       STA Sq0Timer_4002,X
; 19031  8E 00 40       STX Sq0Duty_4000
; 1CF83  8C 00 40       STY Sq0Duty_4000

; 19034  8C 01 40       STY Sq0Sweep_4001
; 19038  8E 04 40       STX Sq1Duty_4004
; 1903B  8C 05 40       STY Sq1Sweep_4005
; 19D63  8C 08 40       STY TrgLinear_4008
; 1959D  8C 0F 40       STY NoiseLength_400F
; 195A0  8E 0E 40       STX NoisePeriod_400E
; 195A3  8D 0C 40       STA NoiseVolume_400C

; 18007  8D 15 40       STA ApuStatus_4015
; 19292  8D 15 40       STA ApuStatus_4015
; 19298  8D 15 40       STA ApuStatus_4015
; 1985A  8D 15 40       STA ApuStatus_4015


;  Mesen debug expression build:
; (pc - $9038 > 4) &&
; (pc - $904A > 4) &&
; (pc - $9060 > 4) &&
; (pc - $90B1 > 4) &&
; (pc - $9038 > 4) &&
; (pc - $903B > 4) &&
; (pc - $9031 > 4) &&
; (pc - $9034 > 4) &&
; (pc - $9D63 > 4) &&
; (pc - $959D > 4) &&
; (pc - $95A0 > 4) &&
; (pc - $95A3 > 4) &&
; (pc - $cf83 > 4)

; (pc - $8007 > 4) &&
; (pc - $9292 > 4) &&
; (pc - $9298 > 4) &&
; (pc - $985a > 4)

; Patch APU status calls
; 18007  8D 15 40       STA ApuStatus_4015
; 19292  8D 15 40       STA ApuStatus_4015
; 19298  8D 15 40       STA ApuStatus_4015
; 1985A  8D 15 40       STA ApuStatus_4015

org !B6+$8007 : jsr z2_WriteAPUControl
org !B6+$9292 : jsr z2_WriteAPUControl
org !B6+$9298 : jsr z2_WriteAPUControl
org !B6+$985a : jsr z2_WriteAPUControl

; org !B0+$982B : jsr WriteAPUControl
; ; org !B0+$9830 : sta $0915
; org !B0+$9928 : jsr WriteAPUControl
; org !B0+$9BA6 : jsr WriteAPUControl
; ; org !B0+$9BE1 : sta $0915
; org !B0+$9D4B : jsr WriteAPUControl
; ; org !B0+$9D5C : sta $0915
; org !B7+$E467 : jsr WriteAPUControl

; ; Hook writes to Square Wave Channel 1
; 1904A  9D 02 40       STA Sq0Timer_4002,X
; 19060  9D 03 40       STA Sq0Length_4003,X
; 190B1  9D 02 40       STA Sq0Timer_4002,X
; 19031  8E 00 40       STX Sq0Duty_4000
; 19034  8C 01 40       STY Sq0Sweep_4001
; 1CF83  8C 00 40       STY Sq0Duty_4000

org !B6+$904a : jsr Sq0_Timer_WriteXIndexed;sta.w z2_Sq0Timer_4002,X ;jsr WriteAPUSq0Ctrl0_X 
org !B6+$9060 : jsr Sq0_Length_WriteXIndexed ;jsr WriteAPUSq0Ctrl0_X z2_WriteAPUSq0Ctrl3
org !B6+$90b1 : jsr Sq0_Timer_WriteXIndexed ;jsr WriteAPUSq0Ctrl0_X 
org !B6+$9031 : jsr Sq0_Duty_WriteX;stx.w z2_Sq0Duty_4000 ;jsr WriteAPUSq0Ctrl0_X 
org !B7+$cf83 : jsr Sq0_Duty_WriteY
org !B6+$9034 : jsr Sq0_Sweep_WriteY;sty.w z2_Sq0Sweep_4001 ;jsr WriteAPUSq0Ctrl0_X 


; Handled by sq0 routines:
; 190B1  9D 02 40       STA Sq0Timer_4002,X
; 19060  9D 03 40       STA Sq0Length_4003,X

; 19038  8E 04 40       STX Sq1Duty_4004
; 1903B  8C 05 40       STY Sq1Sweep_4005

org !B6+$9038 : jsr Sq1_Duty_WriteX
org !B6+$903b : jsr Sq1_Sweep_WriteY

; ; Hook writes to Square Wave Channel 2
; org !B0+$9B14 : jsr WriteAPUSq1Ctrl0_X
; org !B0+$9B3C : jsr WriteAPUSq1Ctrl0
; org !B0+$9B57 : jsr WriteAPUSq1Ctrl0
; org !B0+$9C21 : jsr WriteAPUSq1Ctrl0_X
; org !B0+$9D96 : jsr WriteAPUSq1Ctrl0

; org !B0+$9B37 : jsr WriteAPUSq1Ctrl1
; org !B0+$9C24 : jsr WriteAPUSq1Ctrl1_Y
; org !B0+$9D9B : jsr WriteAPUSq1Ctrl1_X

; org !B0+$9B21 : jsr WriteAPUSq1Ctrl2_X
; org !B0+$9B61 : jsr WriteAPUSq1Ctrl2_X
; org !B0+$9C33 : jsr WriteAPUSq1Ctrl2
; org !B0+$9DAB : jsr WriteAPUSq1Ctrl2_X

; org !B0+$9B19 : jsr WriteAPUSq1Ctrl3_X
; org !B0+$9C3B : jsr WriteAPUSq1Ctrl3


; Handled by sq0 routines:
; 1904A  9D 02 40       STA Sq0Timer_4002,X (x==08)
; 19060  9D 03 40       STA Sq0Length_4003,X (x==08)

; 19D63  8C 08 40       STY TrgLinear_4008

org !B6+$9d63 : jsr Tri_Linear_WriteY

; CHECK: $9067 in B6 in zelda2.nes

; ; Hook writes to Triangle Channel
; org !B0+$9E5D : jsr WriteAPUTriCtrl0
; org !B0+$9E92 : jsr WriteAPUTriCtrl0

; org !B0+$9C48 : jsr WriteAPUTriCtrl2
; org !B0+$9E84 : jsr WriteAPUTriCtrl2_X

; org !B0+$9C50 : jsr WriteAPUTriCtrl3

; Sq0Duty_4000 = $900
; Sq0Sweep_4001 = $901
; Sq0Timer_4002 = $902
; Sq0Length_4003 = $903
; Sq1Duty_4004 = $904
; Sq1Sweep_4005 = $905
; Sq1Timer_4006 = $906
; Sq1Length_4007 = $907
; TrgLinear_4008 = $908
; TrgTimer_400A = $90A
; TrgLength_400B = $90B
; NoiseVolume_400C = $90C
; NoisePeriod_400E = $90E
; NoiseLength_400F = $90F
; DmcFreq_4010 = $910
; DmcCounter_4011 = $911
; DmcAddress_4012 = $912
; DmcLength_4013 = $913
; SpriteDma_4014 = $914
; ApuStatus_4015 = $915

; WriteAPUSq0Ctrl0:
;     sta.w APUBase
;     rts

; WriteAPUSq0Ctrl0_I_Y:
;     sta.w APUBase, y
;     rts

; WriteAPUSq0Ctrl0_Y:
;     sty.w APUBase
;     rts

; WriteAPUSq0Ctrl0_X:
;     stx.w APUBase
;     rts

; WriteAPUSq0Ctrl1:
;     xba
;     lda #$40
;     tsb.w APUBase+$16
;     xba
;     sta.w APUBase+$01
;     rts

; WriteAPUSq0Ctrl1_Y:
;     xba
;     lda #$40
;     tsb.w APUBase+$16
;     xba
;     sty.w APUBase+$01
;     rts    

; WriteAPUSq0Ctrl1_I_Y:
;     cpy #$00
;     bne +
;     jsr WriteAPUSq0Ctrl1
;     rts
; +
;     cpy #$04
;     bne +
;     jsr WriteAPUSq1Ctrl1
;     rts
; +
;     sta $0901, y
;     rts

; WriteAPUSq0Ctrl2:
;     sta.w APUBase+$02
;     rts

; WriteAPUSq0Ctrl2_X:
;     stx.w APUBase+$02
;     rts

; WriteAPUSq0Ctrl2_I_Y:
;     sta.w APUBase+$02, y
;     rts

; WriteAPUSq0Ctrl3:
;     phx
;     sta.w APUBase+$03
;     tax
;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
;     sta.w APUSq0Length
;     xba
;     lda #$01
;     tsb.w APUBase+$15
;     tsb.w APUExtraControl
;     plx
;     xba
;     rts

; WriteAPUSq0Ctrl3_X:
;     pha
;     stx.w APUBase+$03
;     lda.w Sound__EmulateLengthCounter_length_d3_mixed, x
;     sta.w APUSq0Length
;     lda #$01
;     tsb.w APUBase+$15
;     tsb.w APUExtraControl   
;     pla
;     rts

; WriteAPUSq0Ctrl3_I_Y:
;     cpy #$00
;     bne +
;     jsr WriteAPUSq0Ctrl3
;     rts
; +
;     cpy #$04
;     bne +
;     jsr WriteAPUSq1Ctrl3
;     rts
; +
;     cpy #$08
;     bne +
;     jsr WriteAPUTriCtrl3
;     rts
; +
;     jsr WriteAPUNoiseCtrl3    
;     rts


; org !B0+$9900 : jsr WriteAPUSq0Ctrl0_X
; org !B0+$9911 : jsr WriteAPUSq0Ctrl0
; org !B0+$9C06 : jsr WriteAPUSq0Ctrl0_X
; org !B0+$9E01 : jsr WriteAPUSq0Ctrl0

; org !B0+$9922 : jsr WriteAPUSq0Ctrl1
; org !B0+$9C03 : jsr WriteAPUSq0Ctrl1_Y
; org !B0+$9E16 : jsr WriteAPUSq0Ctrl1

; org !B0+$990A : jsr WriteAPUSq0Ctrl2_X
; org !B0+$9C15 : jsr WriteAPUSq0Ctrl2
; org !B0+$9E11 : jsr WriteAPUSq0Ctrl2_X

; org !B0+$9905 : jsr WriteAPUSq0Ctrl3_X
; org !B0+$9C1D : jsr WriteAPUSq0Ctrl3


; ; Hook writes to Square Wave Channel 2
; org !B0+$9B14 : jsr WriteAPUSq1Ctrl0_X
; org !B0+$9B3C : jsr WriteAPUSq1Ctrl0
; org !B0+$9B57 : jsr WriteAPUSq1Ctrl0
; org !B0+$9C21 : jsr WriteAPUSq1Ctrl0_X
; org !B0+$9D96 : jsr WriteAPUSq1Ctrl0

; org !B0+$9B37 : jsr WriteAPUSq1Ctrl1
; org !B0+$9C24 : jsr WriteAPUSq1Ctrl1_Y
; org !B0+$9D9B : jsr WriteAPUSq1Ctrl1_X

; org !B0+$9B21 : jsr WriteAPUSq1Ctrl2_X
; org !B0+$9B61 : jsr WriteAPUSq1Ctrl2_X
; org !B0+$9C33 : jsr WriteAPUSq1Ctrl2
; org !B0+$9DAB : jsr WriteAPUSq1Ctrl2_X

; org !B0+$9B19 : jsr WriteAPUSq1Ctrl3_X
; org !B0+$9C3B : jsr WriteAPUSq1Ctrl3

; ; Hook writes to Triangle Channel
; org !B0+$9E5D : jsr WriteAPUTriCtrl0
; org !B0+$9E92 : jsr WriteAPUTriCtrl0

; org !B0+$9C48 : jsr WriteAPUTriCtrl2
; org !B0+$9E84 : jsr WriteAPUTriCtrl2_X

; org !B0+$9C50 : jsr WriteAPUTriCtrl3

; ; Hook writes to Noise Channel
; org !B0+$997B : jsr WriteAPUNoiseCtrl0
; org !B0+$9989 : jsr WriteAPUNoiseCtrl0
; org !B0+$9A2A : jsr WriteAPUNoiseCtrl0
; org !B0+$9EC4 : jsr WriteAPUNoiseCtrl0

; org !B0+$9971 : jsr WriteAPUNoiseCtrl2
; org !B0+$99F4 : jsr WriteAPUNoiseCtrl2_X
; org !B0+$9A2F : jsr WriteAPUNoiseCtrl2_X
; org !B0+$9ECA : jsr WriteAPUNoiseCtrl2

; org !B0+$9980 : jsr WriteAPUNoiseCtrl3
; org !B0+$9A34 : jsr WriteAPUNoiseCtrl3
; org !B0+$9ED0 : jsr WriteAPUNoiseCtrl3

; ;  Hook writes to DMC
; org !B0+$9bb7 : jsr WriteAPUDMCCounter
; org !B0+$9bcf : jsr WriteAPUDMCFreq
; org !B0+$9bd5 : jsr WriteAPUDMCAddr
; org !B0+$9bdb : jsr WriteAPUDMCLength
; org !B0+$9bea : jsr WriteAPUDMCPlay