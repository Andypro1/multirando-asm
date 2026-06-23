transition_table:
;  room (XXYY), direction, game, destination, args [xxxx xxxx DSxx xAAA]
dw $111d, $0001, $0001, $00f3, $0004       ; Ridley room right door -> Z3 Elder House (East)
; dw $091d, $0001, $0001, $00f2, $0002       ; Kraid entrance room right door -> Z3 Elder House (West)
dw $0715, $0002, $0001, $00f2, $00c2       ; Kraid entrance room right door -> Z3 Elder House (West)
dw $091d, $0002, $0000, $9252, $0000       ; Kraid entrance room left door -> SM Kraid room right door
dw $111d, $0002, $0000, $98ca, $0000       ; Ridley room left door -> SM Ridley room top door
dw $081d, $0001, $0000, $91b6, $0000       ; Kraid room right door -> SM Kraid room left door
dw $101d, $0001, $0000, $9a62, $0000       ; Ridley E-tank room right door -> SM Ridley room bottom door
dw $0000
; orig:  $0B0C, $0004, $0001, $0210, $0000
;$1a13, $0004, $0001, $0210, $0081
;$111d, $0004, $0001, $0210, $0004
