; $A7:C831 9F 28 D8 7E STA $7ED828,x[$7E:D828]    ; Set Kraid as dead
; $A7:DB85 9F 28 D8 7E STA $7ED828,x[$7E:D82B]    ; Set Phantoon as dead
; $A5:92DE 9F 28 D8 7E STA $7ED828,x[$7E:D82C]    ; Set Draygon as dead
; $A6:C5E2 22 A6 81 80 JSL $8081A6[$80:81A6]      ; Set Ridley as dead

; Hook Kraid death
org $a7c831
    jsl boss_death_kraid
org $a7db85
    jsl boss_death_phantoon
org $a592de
    jsl boss_death_draygon
org $a6c5e2
    jsl boss_death_ridley

org $8fa68f
    dw $91d6    ; Disable G4 Statue Animations
                ; G4 opening is only triggered by the new event flags
                

org $99f000
boss_death_kraid:
    sta $7ed828,x   ; Store actual boss kill flag
    lda #$0000
    jsr boss_death_reward
    rtl

boss_death_phantoon:
    sta $7ed828,x   ; Store actual boss kill flag
    lda #$0008
    jsr boss_death_reward
    rtl

boss_death_draygon:
    sta $7ed828,x   ; Store actual boss kill flag
    lda #$0010
    jsr boss_death_reward
    rtl

boss_death_ridley:
    jsl $8081a6    ; Store actual boss kill flag
    lda #$0018
    jsr boss_death_reward
    rtl


boss_death_reward:
    phx : php : tax

    ; Load boss reward type from table
    %a8()
    lda.l boss_rewards, x
    sta !DP_MsgRewardType
    beq .pendant
    cmp #$40
    beq .crystal
    bra .smboss

    .pendant
        lda.l boss_rewards+$2, x
        sta !DP_MsgBitFlag
        ora.l !SRAM_ALTTP_ITEM_BUF+$74
        sta.l !SRAM_ALTTP_ITEM_BUF+$74        
        bra .exit
    .crystal
        lda.l boss_rewards+$2, x
        sta !DP_MsgBitFlag
        ora.l !SRAM_ALTTP_ITEM_BUF+$7A
        sta.l !SRAM_ALTTP_ITEM_BUF+$7A
        bra .exit
    .smboss
        ; Save to special event bits for boss tokens (not the actual boss kill flags that opens doors)
        ; Although in a future update adding the option of this also setting those flags should be a possibility
        lda.l boss_rewards+$2, x
        sta !DP_MsgBitFlag
        ora.l $7ed834
        sta.l $7ed834
        jsr rewards_check_bosses
        bra .exit

    .exit

    %ai16()

    ; Show message box
    lda #$0023
    jsl $858080

    plp : plx
    rts

rewards_check_bosses:
    pha
    phx
    php

    %ai16()

    ; Count number of set SM boss flags
    ; using the new event bits for the SM boss credits

    lda $7ed834
    stz $12
    ldx #$0000

-
    lsr : bcc +
    inc $12 ; If C is set, count this as a killed boss
+
    inx
    cpx #$0004
    bne -

    lda $12
    cmp.l config_sm_bosses
    bcc +

    ; Set our new G4 grey door opening flag (using the keydoor events)
    lda.l $7ed7c0+$72   
    ora.l #$0001      
    sta.l $7ed7c0+$72
    
+   plp
    plx
    pla
    rts

rewards_draw_map_icons:
    phx : phy : phb
    pea $8282 : plb :  plb

    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0002 : beq +
        ldy.w #BlueCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$0002 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +
    
    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0010 : beq +
        ldy.w #BlueCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$000A : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0040 : beq +
        ldy.w #BlueCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$0012 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0020 : beq +
        ldy.w #BlueCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$001A : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0004 : beq +
        ldy.w #RedCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$0022 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0001 : beq +
        ldy.w #RedCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$002A : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$7A : bit #$0008 : beq +
        ldy.w #BlueCrystal_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$0032 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$74 : bit #$0004 : beq +
        ldy.w #GreenPendant_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$003A : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$74 : bit #$0002 : beq +
        ldy.w #BluePendant_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$0042 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda !SRAM_ALTTP_ITEM_BUF+$74 : bit #$0001 : beq +
        ldy.w #RedPendant_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$004A : sta $14
        lda #$3e00 : sta $16
        jsl $81879f    
    +

    lda $7ed834 : bit #$0001 : beq +
        ldy.w #BossKraid_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$00DE : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda $7ed834 : bit #$0002 : beq +
        ldy.w #BossPhantoon_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$00E6 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda $7ed834 : bit #$0004 : beq +
        ldy.w #BossDraygon_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$00EE : sta $14
        lda #$3e00 : sta $16
        jsl $81879f
    +

    lda $7ed834 : bit #$0008 : beq +
        ldy.w #BossRidley_Icon_Spritemap
        lda #$0020 : sta $12
        lda #$00F6 : sta $14
        lda #$3e00 : sta $16
        jsl $81879f   
    +

    plb : ply : plx
    rtl