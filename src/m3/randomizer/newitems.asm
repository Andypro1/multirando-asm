!IBranchItem = #$887C
!ISetItem = #$8899
!ILoadSpecialGraphics = #$8764
!ISetGoto = #$8A24
!ISetPreInstructionCode = #$86C1
!IDrawCustom1 = #$E04F
!IDrawCustom2 = #$E067
!IGoto = #$8724
!IKill = #$86BC
!IPlayTrackNow = #$8BDD
!IJSR = #$8A2E
!ISetCounter8 = #$874E
!IGotoDecrement = #$873F
!IGotoIfDoorSet = #$8A72
!ISleep = #$86B4
!IVisibleItem = #i_visible_item
!IChozoItem = #i_chozo_item
!IHiddenItem = #i_hidden_item
!ILoadCustomGraphics = #i_load_custom_graphics
!IPickup = #i_pickup
!IStartDrawLoop = #i_start_draw_loop
!IStartHiddenDrawLoop = #i_start_hidden_draw_loop

!DP_MsgRewardType = $3A
!DP_MsgBitFlag = $3E
!DP_MsgOverride = $40

!ITEM_PLM_BUF = $7ffb00

org $C12D7C   ; Patch to Crateria surface palette for Z3 items e.g. PoH, Pearl
    incbin "../../data/Crateria_palette.bin"

org $C13798   ; Crocomire's room changes colors $1E, $2E, $2F, $3E, and $3F for reasons unknown.
    incbin "../../data/Crocomire_palette.bin"

org $848794
    jsr get_item_bank

org $DC0000
new_item_graphics_data:
    incbin "../../data/newitems_sm.bin"

;  Replace terminator item for testing
; org $8f8432
;    dw $Efe0
; org $8f8432+$5
;    db $72

; Add our new custom item PLMs
org $84efe0
plm_items:
    dw i_visible_item_setup, v_item       ;efe0
    dw i_visible_item_setup, c_item       ;efe4
    dw i_hidden_item_setup,  h_item       ;efe8
v_item:
    dw !IVisibleItem
c_item:
    dw !IChozoItem
h_item:
    dw !IHiddenItem

i_visible_item:
    lda #$0006
    jsr i_load_rando_item
    rts

i_chozo_item:
    lda #$0008
    jsr i_load_rando_item
    rts

i_hidden_item:
    lda #$000A
    jsr i_load_rando_item
    rts

i_load_rando_item:
    cmp #$0006 : bne +
    ldy #p_visible_item
    bra .end
+   cmp #$0008 : bne +    
    ldy #p_chozo_item
    bra .end
+   ldy #p_hidden_item

.end
    rts

p_visible_item:
    dw !ILoadCustomGraphics
    dw !IBranchItem, .end
    dw !ISetGoto, .trigger
    dw !ISetPreInstructionCode, $df89
    ;dw !IStartDrawLoop
    .loop
    dw !IDrawCustom1
    dw !IDrawCustom2
    dw !IGoto, .loop
    .trigger
    dw !ISetItem
    dw SOUNDFX : db !Click
    dw !IPickup
    .end
    dw !IGoto, $dfa9

p_chozo_item:
    dw !ILoadCustomGraphics
    dw !IBranchItem, .end
    dw !IJSR, $dfaf
    dw !IJSR, $dfc7
    dw !ISetGoto, .trigger
    dw !ISetPreInstructionCode, $df89
    dw !ISetCounter8 : db $16
    ;dw !IStartDrawLoop
    .loop
    dw !IDrawCustom1
    dw !IDrawCustom2
    dw !IGoto, .loop
    .trigger
    dw !ISetItem
    dw SOUNDFX : db !Click
    dw !IPickup
    .end
    dw $0001, $a2b5
    dw !IKill   

p_hidden_item:
    dw !ILoadCustomGraphics
    .loop2
    dw !IJSR, $e007
    dw !IBranchItem, .end
    dw !ISetGoto, .trigger
    dw !ISetPreInstructionCode, $df89
    dw !ISetCounter8 : db $16
    ;dw !IStartHiddenDrawLoop
    .loop
    dw !IDrawCustom1
    dw !IDrawCustom2
    dw !IGotoDecrement, .loop
    dw !IJSR, $e020
    dw !IGoto, .loop2
    .trigger
    dw !ISetItem
    dw SOUNDFX : db !Click
    dw !IPickup
    .end
    dw !IJSR, $e032
    dw !IGoto, .loop2

i_load_custom_graphics:
    phy : phx 
    lda.l !ITEM_PLM_BUF, x  ; Load item id

    %a8()
    sta $4202
    lda #$0A
    sta $4203
    nop : nop : %ai16()
    lda $4216               ; Multiply it by 0x0A
    clc
    adc #item_graphics
    tay                     ; Add it to the graphics table and transfer into Y
    lda $0000, y
    cmp #$1000
    bcc .no_custom    
    jsr $8764               ; Jump to original PLM graphics loading routine
    plx
    ply
    rts

.no_custom
    tay
    lda $0000, y
    sta.l $7edf0c, x
    plx
    ply
    rts

i_visible_item_setup:
    phy : phx
    jsr load_item_id                
    %a8()
    sta $4202
    lda #$0A
    sta $4203
    nop : nop : %ai16()
    lda $4216                       ; Multiply it by 0x0A
    tax

    lda item_graphics, x
    cmp #$1000
    bcc .no_custom
    plx : ply
    jmp $ee64

.no_custom
    plx : ply
    tyx
    sta.l $7edf0c, x
    jmp $ee64

i_hidden_item_setup:
    phy : phx
    jsr load_item_id
    %a8()
    sta $4202
    lda #$0A
    sta $4203
    nop : nop : %ai16()
    lda $4216                       ; Multiply it by 0x0A
    tax

    lda item_graphics, x
    cmp #$1000
    bcc .no_custom
    plx : ply
    jmp $ee8e
    
.no_custom
    plx : ply
    tyx
    sta.l $7edf0c, x
    jmp $ee8e

i_pickup:
    phx : phy : php
    lda !ITEM_PLM_BUF, x : pha
    
    ; Check if this item belongs to SM
    jsl mb_CheckItemGame
    cmp.w #$0000
    bne .notSm
    pla

    jsr receive_sm_item
    bra .end

.notSm
    ; If this item belongs to another game, then use common item routine
    pla : pha
    jsl mb_WriteItemToInventory

    ; Show item message here
    pla : sta !DP_MsgRewardType : asl : tax
    lda.l item_message_table, x
    and #$00ff
    jsl $858080

.end
    plp : ply : plx
    rts

; This should only ever be called for new items
receive_sm_item:
    cmp #$00CA
    bcs .mapMarker
    cmp #$00B0
    bcc .keyCard
    bra .end

.keyCard
    ; Load the bitmask from the global item table
    sta !DP_MsgRewardType
    asl #3
    tax
    lda.l $7ed7c0+$70           ; Keydoor event location
    ora.l mb_ItemData+$06, x    ; Key bitmask
    sta.l $7ed7c0+$70
    lda !DP_MsgRewardType : asl : tax
    lda.l item_message_table, x
    and #$00ff
    jsl $858080
    bra .end

.mapMarker
    pha
    and #$000f
    sec : sbc #$000a
    clc : adc #$00a0            ; Set event (map marker received)
    jsl $8081fa
    pla
    sta !DP_MsgRewardType       ; Store map marker id
    asl : tax
    lda.l item_message_table, x
    and #$00ff
    jsl $858080                 
    bra .end 

.end
    rts

load_item_id:
    phx : phy

    ; Load the item id from the PLM room argument
    ; Store it in X, and then clear the item id from the room argument
    lda $1dc7, y
    pha : xba : and #$00ff
    tax : pla
    and #$00ff
    sta $1dc7, y
    txa
    
    ; Potentially upgrade this progressive item
    jsl mb_CheckProgressiveItemLong
    ply
    tyx
    sta !ITEM_PLM_BUF, x
    plx
    rts


item_graphics:
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 00 Dummy - L1SwordAndShield        
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 01 Master Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 02 Tempered Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 03 Gold Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 04 Blue Shield
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 05 Red Shield
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 06 Mirror Shield
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 07 Fire Rod
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 08 Ice Rod
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 09 Hammer
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 0A Hookshot
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 0B Bow
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 0C Blue Boomerang
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 0D Powder
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 0E Bee (bottle contents)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 0F Bombos

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 10 Ether
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 11 Quake
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 12 Lamp
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 13 Shovel
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 14 Flute
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 15 Somaria
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 16 Empty Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 17 Heart Piece
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 18 Cane of Byrna
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 19 Cape
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 1A Mirror
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 1B Gloves
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 1C Titan's Mitts
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 1D Book
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 1E Flippers
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 1F Moon Pearl

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 20 Dummy     
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 21 Bug-Catching Net
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 22 Blue Tunic
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 23 Red Tunic
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 24 Dummy - Key       
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 25 Dummy - Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 26 Heart Container (no animation)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 27 One bomb
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 28 3 Bombs
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 29 Mushroom
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 2A Red Boomerang
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 2B Red Potion Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 2C Green Potion Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 2D Blue Potion Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 2E Dummy - Red potion (contents)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 2F Dummy - Green potion (contents)

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 30 Dummy - Blue potion (contents)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 31 10 Bombs
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 32 Dummy - Big key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 33 Dummy - Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 34 1 Rupee
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 35 5 Rupees
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 36 20 Rupees
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 37 Dummy - Pendant of Courage
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 38 Dummy - Pendant of Wisdom
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 39 Dummy - Pendant of Power
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 3A Bow and Arrows
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 3B Silver Arrows
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 3C Bee Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 3D Fairy Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 3E Heart Container - Boss
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 3F Heart Container - Sanc

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 40 100 Rupees
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 41 50 Rupees
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 42 Dummy - Small heart
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 43 Single Arrow
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 44 10 Arrows
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 45 Dummy - Small magic
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 46 300 Rupees
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 47 20 Rupees
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 48 Good Bee Bottle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 49 Fighter Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 4A Dummy - Activated flute
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 4B Boots
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 4C Dummy - 50 Bomb upgrade
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 4D Dummy - 70 Arrow upgrade
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 4E Half Magic
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 4F Quarter Magic

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 50 Master Sword    
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 51 5 Bomb Upgrade
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 52 10 Bomb Upgrade
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 53 5 Arrow Upgrade
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 54 10 Arrow Upgrade
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 55 Dummy - Programmable 1
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 56 Dummy - Programmable 2
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 57 Dummy - Programmable 3
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 58 Silver Arrows

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 59 - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 5A - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 5B - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 5C - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 5D - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 5E - Progressive Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 5F - Progressive Shield

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 60 - Progressive Armor
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 61 - Progressive Glove
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 62 - Bombs                  (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 63 - High Jump              (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 64 - Reserved - Progressive Bow                 (Why two here? Are both used?)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 65 - Reserved - Progressive Bow                 (Why two here? Are both used?)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 66 - Long Beam              (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 67 - Screw Attack           (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 68 - Morph Ball             (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 69 - Varia Suit             (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 6A - Reserved - Goal Item (Single/Triforce)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 6B - Reserved - Goal Item (Multi/Power Star)    (Is this used for anything)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 6C - Wave Beam              (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 6D - Ice Beam               (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 6E - Energy Tank            (M1)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 6F - Missiles               (M1)

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 70 - Crateria L1 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 71 - Crateria L2 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 72 - Ganons Tower Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 73 - Turtle Rock Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 74 - Thieves' Town Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 75 - Tower of Hera Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 76 - Ice Palace Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 77 - Skull Woods Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 78 - Misery Mire Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 79 - Palace Of Darkness Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 7A - Swamp Palace Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 7B - Crateria Boss Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 7C - Desert Palace Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 7D - Eastern Palace Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 7E - Maridia Boss Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 7F - Hyrule Castle Map

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 80 - Brinstar L1 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 81 - Brinstar L2 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 82 - Ganons Tower Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 83 - Turtle Rock Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 84 - Thieves' Town Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 85 - Tower of Hera Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 86 - Ice Palace Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 87 - Skull Woods Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 88 - Misery Mire Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 89 - Palace of Darkness Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 8A - Swamp Palace Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 8B - Brinstar Boss Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 8C - Desert Palace Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 8D - Eastern Palace Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 8E - Wrecked Ship L1 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 8F - Wrecked Ship Boss Key

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 90 - Norfair L1 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 91 - Norfair L2 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 92 - Ganons Tower Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 93 - Turtle Rock Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 94 - Thieves' Town Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 95 - Tower of Hera Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 96 - Ice Palace Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 97 - Skull Woods Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 98 - Misery Mire Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 99 - Palace of Darkness Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 9A - Swamp Palace Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 9B - Norfair Boss Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 9C - Desert Palace Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 9D - Eastern Palace Big Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 9E - Lower Norfair L1 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; 9F - Lower Norfair Boss Key

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A0 - Hyrule Castle Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A1 - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A2 - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A3 - Desert Palace Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A4 - Castle Tower Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A5 - Swamp Palace Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A6 - Palace of Darkness Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A7 - Misery Mire Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A8 - Skull Woods Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; A9 - Ice Palace Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; AA - Tower of Hera Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; AB - Thieves' Town Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; AC - Turtle Rock Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; AD - Ganons Tower Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; AE - Maridia L1 Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; AF - Maridia L2 Key

    ; SM (B0-FF)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B0 - Grapple beam
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B1 - X-ray scope
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B2 - Varia suit
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B3 - Spring ball
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B4 - Morph ball
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B5 - Screw attack
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B6 - Gravity suit
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B7 - Hi-Jump
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B8 - Space jump
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; B9 - Bombs
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; BA - Speed booster
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; BB - Charge
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; BC - Ice Beam
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; BD - Wave beam
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; BE - Spazer
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; BF - Plasma beam

    ; C0
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C0 - Energy Tank
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C1 - Reserve tank
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C2 - Missile
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C3 - Super Missile
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C4 - Power Bomb    
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C5 - Kraid Boss Token
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C6 - Phantoon Boss Token
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C7 - Draygon Boss Token
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C8 - Ridley Boss Token
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; C9 - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; CA - Kraid Map 
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; CB - Phantoon Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; CC - Draygon Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; CD - Ridley Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; CE - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; CF - Unused (Reserved)

    ; Z1 (D0-FF)
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D0 - Bombs
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D1 - Wooden Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D2 - White Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D3 - Magical Sword
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D4 - Bait
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D5 - Recorder
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D6 - Blue Candle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D7 - Red Candle
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D8 - Arrows
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; D9 - Silver Arrows
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; DA - Bow
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; DB - Magical Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; DC - Raft
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; DD - Stepladder
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; DE - Unused?
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; DF - 5 Rupees
    
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E0 - Magical Rod
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E1 - Book of Magic
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E2 - Blue Ring
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E3 - Red Ring
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E4 - Power Bracelet
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E5 - Letter
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E6 - Compass
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E7 - Dungeon Map
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E8 - 1 Rupee
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; E9 - Small Key
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; EA - Heart Container
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; EB - Triforce Fragment
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; EC - Magical Shield
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; ED - Boomerang
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; EE - Magical Boomerang
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; EF - Blue Potion

    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F0 - Red Potion
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F1 - Clock
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F2 - Small Heart
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F3 - Fairy
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F4 - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F5 - Unused
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F6 - Unused

    ; These plaques have to go at some point since they're taking up valuable
    ; item ids
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F7 - L1 Key Plaque
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F8 - L2 Key Plaque
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; F9 - Boss Key Plaque
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; FA - Zero Marker
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; FB - One Marker
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; FC - Two Marker
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; FD - Three Marker
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; FE - Four Marker
    dw $1900 : db $01, $01, $00, $00, $03, $03, $00, $00    ; FF - Unused

get_item_bank:
    cpy #item_graphics
    bcc .original
.custom
    lda.w #(new_item_graphics_data>>16)
    bra .end
.original
    lda.w #$0089
.end
    rts

warnpc $84fe00

; Patch SFX
org $8498e3
CLIPCHECK:
	LDA $05D7
	CMP #$0002
	BEQ $0E
	LDA #$0000
	JSL $808FF7
	LDA $07F5
	JSL $808FC1
	LDA #$0000
	STA $05D7
	RTL

CLIPSET:
	LDA #$0001
	STA $05D7
	JSL $82BE17
	LDA #$0000
	RTS
SOUNDFX:
	JSR SETFX
	AND #$00FF
	JSL $809049
	RTS
SPECIALFX:
	JSR SETFX
	JSL $8090CB
	RTS
MISCFX:
	JSR SETFX
	JSL $80914D
	RTS
SETFX:
	LDA #$0002
	STA $05D7
	LDA $0000,y
	INY
	RTS