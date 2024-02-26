SPRITE_CENTER_OFFSET_X  = 0
SPRITE_CENTER_OFFSET_Y  = 11

TYPE_PLAYER_TIA           = 1
TYPE_PLAYER_CHRIS         = 2
TYPE_PLAYER_GROO          = 3
TYPE_PLAYER_EMILY         = 4
TYPE_MENU_POINTER         = 5
TYPE_SWORD_ATTACK         = 6

SPRITE_BASE               = 64
SPRITE_PLAYER_TIA         = SPRITE_BASE
SPRITE_PLAYER_CHRIS       = SPRITE_BASE + 4
SPRITE_MENU_POINTER       = SPRITE_BASE + 5
SPRITE_ROCK               = SPRITE_BASE + 6
SPRITE_SNOW_FLAKE         = SPRITE_BASE + 13
SPRITE_PLAYER_GROO        = SPRITE_BASE + 8
SPRITE_SWORD_ATTACK       = SPRITE_BASE + 9
SPRITE_RIP                = SPRITE_BASE + 10
SPRITE_POW_1              = SPRITE_BASE + 11
SPRITE_PLAYER_EMILY       = SPRITE_BASE + 12
SPRITE_POW_2              = SPRITE_BASE + 13
SPRITE_FIRE_1             = SPRITE_BASE + 14
SPRITE_FIRE_2             = SPRITE_BASE + 15
SPRITE_LIGHTNING          = SPRITE_BASE + 7


;------------------------------------------------------------
;x is sprite slot
;PARAM1 is X
;PARAM2 is Y
;PARAM3 is object type
;expects #1 in A to add object, #0 does not add
;------------------------------------------------------------
!zone SpawnObject
DoSpawnObject
          lda PARAM3
          sta SPRITE_ACTIVE,x

          ;PARAM1 and PARAM2 hold x,y already
          jsr CalcSpritePosFromCharPos

          ;enable sprite
          lda BIT_TABLE,x
          ora VIC_SPRITE_ENABLE
          sta VIC_SPRITE_ENABLE
          sta GAME_VIC_SPRITE_ENABLE

          ;sprite color
          ldy SPRITE_ACTIVE,x
          lda TYPE_START_COLOR,y
          sta VIC_SPRITE_COLOR,x

          lda TYPE_START_COLOR,y
          bpl .NoMulticolor

          lda BIT_TABLE,x
          ora VIC_SPRITE_MULTICOLOR
          sta VIC_SPRITE_MULTICOLOR
          jmp .MultiColorDone

.NoMulticolor
          lda BIT_TABLE,x
          eor #$ff
          and VIC_SPRITE_MULTICOLOR
          sta VIC_SPRITE_MULTICOLOR

.MultiColorDone

          ;initialise enemy values
          lda TYPE_START_SPRITE,y
          sta SPRITE_POINTER_BASE,x

          ;look right per default
          lda #0
          sta SPRITE_DIRECTION,x
          ;sta SPRITE_DIRECTION_Y,x
          sta SPRITE_ANIM_POS,x
          ;sta SPRITE_ANIM_DELAY,x
          sta SPRITE_MOVE_POS,x
          lda #3
          sta PARAM10
          sty PARAM9

.OffsetY
          beq .NoOffsetY

          jsr MoveSpriteUp
          dec PARAM10
          jmp .OffsetY

.NoOffsetY
          ldy PARAM9

          ;use start direction
          ;lda #0
          ;sta SPRITE_DIRECTION,x

          rts



;------------------------------------------------------------
;CalcSpritePosFromCharPos
;calculates the real sprite coordinates from screen char pos
;and sets them directly
;PARAM1 = char_pos_x
;PARAM2 = char_pos_y
;X      = sprite index
;------------------------------------------------------------
!zone CalcSpritePosFromCharPos
CalcSpritePosFromCharPos
          ;offset screen to border 24,50
          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC_SPRITE_X_EXTEND

          ;need extended x bit?
          lda PARAM1
          sta SPRITE_CHAR_POS_X,x
          cmp #30
          bcc .NoXBit

          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC_SPRITE_X_EXTEND

.NoXBit
          ;calculate sprite positions (offset from border)
          txa
          asl
          tay

          lda PARAM1
          asl
          asl
          asl
          clc
          adc #( 24 - SPRITE_CENTER_OFFSET_X )
          sta SPRITE_POS_X,x
          sta VIC_SPRITE_X_POS,y

          lda PARAM2
          sta SPRITE_CHAR_POS_Y,x
          asl
          asl
          asl
          clc
          adc #( 50 - SPRITE_CENTER_OFFSET_Y )
          sta SPRITE_POS_Y,x
          sta VIC_SPRITE_Y_POS,y

          lda #0
          sta SPRITE_CHAR_POS_X_DELTA,x
          sta SPRITE_CHAR_POS_Y_DELTA,x
          rts



;------------------------------------------------------------
;Move Sprite Left
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteLeft
MoveSpriteLeft
          lda SPRITE_POS_X,x
          bne .NoChangeInExtendedFlag

          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC_SPRITE_X_EXTEND

.NoChangeInExtendedFlag
          dec SPRITE_POS_X,x
          txa
          asl
          tay

          lda SPRITE_POS_X,x
          sta VIC_SPRITE_X_POS,y
          rts

;------------------------------------------------------------
;Move Sprite Right
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteRight
MoveSpriteRight
          inc SPRITE_POS_X,x
          lda SPRITE_POS_X,x
          bne .NoChangeInExtendedFlag

          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC_SPRITE_X_EXTEND

.NoChangeInExtendedFlag
          txa
          asl
          tay

          lda SPRITE_POS_X,x
          sta VIC_SPRITE_X_POS,y
          rts

;------------------------------------------------------------
;Move Sprite Up
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteUp
MoveSpriteUp
          dec SPRITE_POS_Y,x

          txa
          asl
          tay

          lda SPRITE_POS_Y,x
          sta VIC_SPRITE_Y_POS,y
          rts

;------------------------------------------------------------
;Move Sprite Down
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteDown
MoveSpriteDown
          inc SPRITE_POS_Y,x

          txa
          asl
          tay

          lda SPRITE_POS_Y,x
          sta VIC_SPRITE_Y_POS,y
          rts



!zone RemoveObject
RemoveObject
          lda #0
          sta SPRITE_ACTIVE,x

          lda BIT_TABLE,x
          eor #$ff
          and VIC_SPRITE_ENABLE
          sta VIC_SPRITE_ENABLE
          rts



;y = level to calc exp for
;      lv 00 =      0 xp
;          1 =     32 xp
;          2 =     64 xp
;          3 =    144 xp
;          4 =    256 xp
;          5 =    400 xp
;result in RESULT_32BIT
!zone CalcExpForNextLevel
CalcExpForNextLevel
          lda #0
          sta RESULT_32BIT
          sta RESULT_32BIT + 1
          sta RESULT_32BIT + 2
          sta RESULT_32BIT + 3

          ;32 * Level * Level / 2
          sty OPERAND_8BIT_1
          sty OPERAND_8BIT_2

          jsr Multiply8By8

          lda #32
          sta OPERAND_16BIT_2_1
          lda #0
          sta OPERAND_16BIT_2_2

          jsr Multiply16By16

          ; / 2
          clc
          ror RESULT_32BIT + 3
          ror RESULT_32BIT + 2
          ror RESULT_32BIT + 1
          ror RESULT_32BIT

          rts



;x = index
!zone AddFighterToParty
AddFighterToParty
          txa
          sta FIGHTER_ACTIVE,x
          inc FIGHTER_ACTIVE,x

          lda INITIAL_PARTY_ATTACK,x
          sta FIGHTER_ATTACK,x
          lda INITIAL_PARTY_DEFENSE,x
          sta FIGHTER_DEFENSE,x
          lda INITIAL_PARTY_EVASION,x
          sta FIGHTER_EVASION,x
          ;lda INITIAL_PARTY_MAGIC_EVASION,x
          lda #8
          sta FIGHTER_MAGIC_EVASION,x
          lda INITIAL_PARTY_STRENGTH,x
          sta FIGHTER_STRENGTH,x
          ;lda INITIAL_PARTY_SPEED,x
          lda #11
          sta FIGHTER_SPEED,x

          lda INITIAL_PARTY_HP,x
          sta FIGHTER_HP_LO,x
          sta FIGHTER_HP_MAX_LO,x
          lda INITIAL_PARTY_MP,x
          sta FIGHTER_MP_LO,x
          sta FIGHTER_MP_MAX_LO,x

          cpx #0
          beq .WasFirstPlayer

          ;level up to match first player level
          lda FIGHTER_LEVEL
          sta PARAM9
          beq .NothingToDo
-
          jsr LevelUp

          ;adjust experience
          ldy FIGHTER_LEVEL,x
          stx CURRENT_INDEX
          jsr CalcExpForNextLevel
          ldx CURRENT_INDEX

          lda RESULT_32BIT
          sta PARTY_XP_1,x
          lda RESULT_32BIT + 1
          sta PARTY_XP_2,x
          lda RESULT_32BIT + 2
          sta PARTY_XP_3,x

          dec PARAM9
          bne -

          ;full values
          lda FIGHTER_HP_MAX_LO,x
          sta FIGHTER_HP_LO,x
          lda FIGHTER_HP_MAX_HI,x
          sta FIGHTER_HP_HI,x
          lda FIGHTER_MP_MAX_LO,x
          sta FIGHTER_MP_LO,x
          lda FIGHTER_MP_MAX_HI,x
          sta FIGHTER_MP_HI,x

.NothingToDo
.WasFirstPlayer
          rts



SPRITE_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_POS_X_EXTEND
          !byte 0
SPRITE_CHAR_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_X_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_ACTIVE
          !byte 0,0,0,0,0,0,0,0
SPRITE_DIRECTION
          !byte 0,0,0,0,0,0,0,0
;SPRITE_DIRECTION_Y
;          !byte 0,0,0,0,0,0,0,0
SPRITE_ANIM_POS
          !byte 0,0,0,0,0,0,0,0
;SPRITE_ANIM_DELAY
;          !byte 0,0,0,0,0,0,0,0
SPRITE_MOVE_POS
          !byte 0,0,0,0,0,0,0,0

CHARBOX_DISPLAY_TYPE
          !byte 0

NUM_INVENTORY_ITEMS = 20
INVENTORY_SLOT
          !fill NUM_INVENTORY_ITEMS,0
INVENTORY_COUNT
          !fill NUM_INVENTORY_ITEMS,0

