optimize address ram

!B0 = ((!BASE_BANK)<<16)
!B6 = ((!BASE_BANK+$6)<<16)
!B7 = ((!BASE_BANK+$7)<<16)

;  APU control calls
org !B6+$8007 : jsr z2_WriteAPUControl
org !B6+$9292 : jsr z2_WriteAPUControl
org !B6+$9298 : jsr z2_WriteAPUControl
org !B6+$985a : jsr z2_WriteAPUControl


;  Square wave 0 calls
org !B6+$9031 : jsr Sq0_Duty_WriteX
org !B6+$9034 : jsr Sq0_Sweep_WriteY
org !B6+$904a : jsr Sq0_Timer_WriteXIndexed
org !B6+$9060 : jsr Sq0_Length_WriteXIndexed
org !B6+$90b1 : jsr Sq0_Timer_WriteXIndexed
org !B7+$cf83 : jsr Sq0_Duty_WriteY


;  Square wave 1 calls
org !B6+$9038 : jsr Sq1_Duty_WriteX
org !B6+$903b : jsr Sq1_Sweep_WriteY

;  Sq1 but handled by sq0 routines:
; 190B1  9D 02 40       STA Sq0Timer_4002,X
; 19060  9D 03 40       STA Sq0Length_4003,X


;  Triangle calls
org !B6+$9d63 : jsr Tri_Linear_WriteY

;  Triangle but handled by sq0 routines:
; 1904A  9D 02 40       STA Sq0Timer_4002,X (x==08)
; 19060  9D 03 40       STA Sq0Length_4003,X (x==08)


;  Noise calls
org !B6+$959d : jsr Noise_Length_WriteY
org !B6+$95a0 : jsr Noise_Period_WriteX
org !B6+$95a3 : jsr Noise_Volume_WriteA
org !B6+$9625 : jsr Noise_Period_WriteA
org !B6+$962f : jsr Noise_Volume_WriteA
org !B6+$9634 : jsr Noise_Length_WriteA
org !B6+$9b4b : jsr Noise_Volume_WriteA


;  DMC calls (TODO:)
; org !B0+$9bb7 : jsr WriteAPUDMCCounter
; org !B0+$9bcf : jsr WriteAPUDMCFreq
; org !B0+$9bd5 : jsr WriteAPUDMCAddr
; org !B0+$9bdb : jsr WriteAPUDMCLength
; org !B0+$9bea : jsr WriteAPUDMCPlay