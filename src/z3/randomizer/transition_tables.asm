; Transition tables for going from Z3 -> Another game
; Starts at $AA8000

; Transition table when entering a dungeon/cave
transition_table_in:
;  room_id, screen, game,  destination, args
;  room_id = $82:C577[EntranceIndex], screen = $040A cached at $7EC140
dw $0122, $0035, $0000, m3_CrateriaMapDoorData_in, $0000       ; Lake Hylia entrance -> M3 Parlor
dw $0122, $0011, $0002, $0066, $0003       ; Fortune Teller (Light) -> Z1

dw $00E5, $0003, $0000, $97c2, $0000       ; Death mountain cave -> Norfair map station
dw $010E, $0077, $0000, $a894, $0000       ; Dark world ice rod cave -> Maridia missile refill
dw $0115, $0070, $0000, m3_LNRefillDoorData_in, $0000       ;  Misery mire right side -> LN GT Refill

; dw $00F2, $0018, $0003, $091d, $0042       ; Elder House (West) -> M1 Kraid entrance room
dw $00F2, $0018, $0003, $0715, $00c2       ; Elder House (West) -> M1 Kraid entrance room
dw $00F3, $0018, $0003, $111d, $0004       ; Elder House (East) -> M1 Ridley room

dw $0000

org $A8A000
; Transition table when exiting a dungeon/cave
transition_table_out:
;  room_id,  reserved, game,  destination, args
;dw $0112, $0000, $0000, $8bce, $0000       ; Shop exit -> Parlor
dw $0000
