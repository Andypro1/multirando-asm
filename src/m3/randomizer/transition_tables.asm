org $d00000
sm_transition_table:
    ;  door,  game,  destination, args
    dw CrateriaMapDoorData_out, $0001, $0200, $0000
    dw $9306, $0001, $0201, $0000
    dw $a8f4, $0001, $0202, $0040
    dw LNRefillDoorData_out, $0001, $0203, $0040
    dw $91da, $0003, $091d, $0082     ; SM Kraid room right door -> M1 Kraid entrance room left door
    dw $91ce, $0003, $081d, $0002     ; SM Kraid room left door -> M1 Kraid room right door
    dw $98be, $0003, $111d, $0084     ; SM Ridley room top door -> M1 Ridley room left door
    dw $98b2, $0003, $101d, $0004     ; SM Ridley room bottom door -> M1 Ridley E-tank room right door
    dw $0000

warnpc $d01000
