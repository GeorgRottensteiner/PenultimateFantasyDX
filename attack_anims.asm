ATTACK_NONE             = $ff
ATTACK_SWORD            = 0
ATTACK_POISON_BITE      = 1
ATTACK_ITEM_HERBS       = 2
ATTACK_ITEM_ETHER       = 3
ATTACK_MAGIC_FIRE       = 4
ATTACK_ITEM_FENIX_DOWN  = 5
ATTACK_ITEM_ANTIDOTE    = 6
ATTACK_HEAL_PARTY       = 7
ATTACK_STEAL            = 8
ATTACK_STUDY            = 9
ATTACK_QUAKE            = 10
ATTACK_STUN             = 11
ATTACK_MAGIC_ICE        = 12
ATTACK_JUMP             = 13
ATTACK_JUMP_END         = 14
ATTACK_MAGIC_LIGHTNING  = 15
ATTACK_MAGIC_CURE       = 16
ATTACK_MAGIC_RAISE      = 17
ATTACK_MAGIC_EARTH      = 18
ATTACK_POISON_DAMAGE    = 19

ATTACK_TARGET_SINGLE      = 0
ATTACK_TARGET_ENEMY_GROUP = 1
ATTACK_TARGET_PARTY       = 2
ATTACK_TARGET_ALL         = 3

AT_SPAWN_OBJECT           = 0     ;4 bytes, sprite, deltax, deltay, color
AT_DELAY                  = 1     ;1 byte number of frames
AT_MOVE                   = 2     ;2 bytes, dx, dy
AT_REMOVE                 = 3
AT_DISPLAY_DAMAGE         = 4
AT_HIDE_DAMAGE            = 5
AT_DISPLAY_TEXT           = 6
AT_CLEAR_TEXT             = 7
AT_CALC_PHYSICAL_DAMAGE   = 8     ;1 byte 0 = full, 1 = half
AT_STATUS_ADD             = 9     ;1 byte status flag mask
AT_STATUS_REMOVE          = 10    ;1 byte status flag mask
AT_CALC_MAGICAL_DAMAGE    = 11
AT_SET_DAMAGE             = 12    ;1 word - damage value, 1 byte - damage type, 1 byte - attack element
AT_REVIVE_TARGET          = 13
AT_HEAL_PARTY             = 14
AT_ANIM_OBJECT            = 15    ;2 bytes, number of frames, anim steps
AT_BEGIN_BLOCK            = 16
AT_END_BLOCK              = 17
AT_MOVE_TOWARDS_TARGET    = 18
AT_MOVE_TOWARDS_START_POS = 19
AT_STEAL                  = 20
AT_STUDY                  = 21
AT_DEDUCT_MP_OR_ABORT     = 22    ;1 byte num of MP
AT_SHAKE                  = 23
AT_AUTO_TARGET            = 24    ;1 byte, 0 = party, 1 = enemies
AT_SET_OBJECT             = 25    ;1 byte, sprite index
AT_ENTER_JUMP_MODE        = 26
AT_END_JUMP_MODE          = 27
AT_END                    = $80



;y = animation
!zone PlayAttackAnimation
PlayAttackAnimationWithoutDisplay
          lda #1
          sta ATTACK_ANIM_NO_DISPLAY
          jmp +
PlayAttackAnimation
          lda #0
          sta ATTACK_ANIM_NO_DISPLAY
+
          lda #ADT_HURT_HP
          sta ATTACK_DAMAGE_TYPE

          lda ATTACK_ANIM_LIST_LO,y
          sta ZEROPAGE_POINTER_5
          lda ATTACK_ANIM_LIST_HI,y
          sta ZEROPAGE_POINTER_5 + 1
          lda #0
          sta PARAM10

.HandleFrame
          ;end reached?
          lda PARAM10
          bpl +

AnimAbort
          ;reset, otherwise DisplayText doesn't display anything
          lda #0
          sta ATTACK_ANIM_NO_DISPLAY
          rts

PLAY_ANIM_TABLE_LO
          !byte <AnimSpawnObject
          !byte <AnimDelay
          !byte <AnimMoveObject
          !byte <AnimRemoveObject
          !byte <AnimDisplayAttackDamage
          !byte <AnimHideAttackDamage
          !byte <AnimDisplayText
          !byte <AnimClearText
          !byte <AnimCalcPhysicalDamage
          !byte <AnimStatusAdd
          !byte <AnimStatusRemove
          !byte <AnimCalcMagicalDamage
          !byte <AnimSetDamage
          !byte <AnimReviveTarget
          !byte <AnimFullReviveParty
          !byte <AnimAnimateObject
          !byte <AnimBeginBlock
          !byte <AnimEndBlock
          !byte <AnimMoveTowardsTarget
          !byte <AnimMoveTowardsStartPos
          !byte <AnimSteal
          !byte <AnimStudy
          !byte <AnimDeductMPOrAbort
          !byte <AnimShake
          !byte <AnimAutoTarget
          !byte <AnimSetObject
          !byte <AnimEnterJumpMode
          !byte <AnimEndJumpMode

PLAY_ANIM_TABLE_HI
          !byte >AnimSpawnObject
          !byte >AnimDelay
          !byte >AnimMoveObject
          !byte >AnimRemoveObject
          !byte >AnimDisplayAttackDamage
          !byte >AnimHideAttackDamage
          !byte >AnimDisplayText
          !byte >AnimClearText
          !byte >AnimCalcPhysicalDamage
          !byte >AnimStatusAdd
          !byte >AnimStatusRemove
          !byte >AnimCalcMagicalDamage
          !byte >AnimSetDamage
          !byte >AnimReviveTarget
          !byte >AnimFullReviveParty
          !byte >AnimAnimateObject
          !byte >AnimBeginBlock
          !byte >AnimEndBlock
          !byte >AnimMoveTowardsTarget
          !byte >AnimMoveTowardsStartPos
          !byte >AnimSteal
          !byte >AnimStudy
          !byte >AnimDeductMPOrAbort
          !byte >AnimShake
          !byte >AnimAutoTarget
          !byte >AnimSetObject
          !byte >AnimEnterJumpMode
          !byte >AnimEndJumpMode


;PLAY_ANIM_POS
;          !byte 0

+
          ldy #0
          sty PLAY_ANIM_POS
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM10

          and #$7f
          tax

          lda PLAY_ANIM_TABLE_LO,x
          sta PLAY_ANIM_JUMP_LABEL
          lda PLAY_ANIM_TABLE_HI,x
          sta PLAY_ANIM_JUMP_LABEL + 1

PLAY_ANIM_JUMP_LABEL = * + 1
          jmp $8000



!zone AnimSetDamage
AnimSetDamage
          ldx CURRENT_TARGET
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta ATTACK_DAMAGE + 1
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta ATTACK_DAMAGE

          iny
          lda (ZEROPAGE_POINTER_5),y
          sta ATTACK_DAMAGE_TYPE
          bpl +
          ;was magic
          and #$7f
          sta ATTACK_DAMAGE_TYPE

+

          iny
          lda (ZEROPAGE_POINTER_5),y
          sta ATTACK_ELEMENT

          jmp AnimNextFrame



!zone AnimDeductMPOrAbort
AnimDeductMPOrAbort
          ldx CURRENT_INDEX
          iny
          lda (ZEROPAGE_POINTER_5),y
          ;MP
          sta LOCAL1
          lda #0
          sta LOCAL2

          lda FIGHTER_MP_LO,x
          sec
          sbc LOCAL1
          lda FIGHTER_MP_HI,x
          sbc LOCAL2
          bcc .NotEnoughMP

          lda FIGHTER_MP_HI,x
          sbc LOCAL2
          sta FIGHTER_MP_HI,x
          lda FIGHTER_MP_LO,x
          sec
          sbc LOCAL1
          sta FIGHTER_MP_LO,x

          sty PARAM8

          jsr DisplayFighterMP

          ldy PARAM8

          jmp AnimNextFrame

.NotEnoughMP
          lda #<TEXT_NOT_ENOUGH_MP
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_NOT_ENOUGH_MP
          sta ZEROPAGE_POINTER_1 + 1
          lda #1
          sta PARAM1
          sta PARAM2
          jsr DisplayText

          lda #30
          sta PLAY_ANIM_POS
-
          jsr WaitFrame

          dec PLAY_ANIM_POS
          bne -

          ;abort
          jmp AnimAbort



!zone AnimAutoTarget
AnimAutoTarget
          iny
          sty PLAY_ANIM_POS
          ldx #0
          lda (ZEROPAGE_POINTER_5),y
          beq .AutoTargetParty

          ;auto target enemy
          ldx #4

.AutoTargetParty
          ;find first active fighter
-
          lda FIGHTER_ACTIVE,x
          bne .FoundTarget

          inx
          jmp -

.FoundTarget
          stx CURRENT_TARGET

          ldy PLAY_ANIM_POS
          jmp AnimNextFrame





!zone AnimStatusAdd
AnimStatusAdd
          ldx CURRENT_TARGET
          iny
          lda (ZEROPAGE_POINTER_5),y
          ora FIGHTER_STATE,x
          sta FIGHTER_STATE,x

          lda (ZEROPAGE_POINTER_5),y
          cmp #STATUS_FROZEN
          bne +

          lda #20
          sta FIGHTER_FROZEN_COUNT,x
+
          jmp AnimNextFrame

!zone AnimStatusRemove
AnimStatusRemove
          iny
          ldx CURRENT_TARGET
          lda (ZEROPAGE_POINTER_5),y
          eor #$ff
          and FIGHTER_STATE,x
          sta FIGHTER_STATE,x
          jmp AnimNextFrame

!zone AnimCalcPhysicalDamage
AnimCalcPhysicalDamage
          lda #ATT_TYPE_PHYSICAL
          sta ATTACK_TYPE

          iny
          sty PLAY_ANIM_POS
          lda (ZEROPAGE_POINTER_5),y
          ;damage type
          beq .PhysicalDamage
          cmp #1
          beq .PhysicalDamageHalf

          ;TODO - other damage types

          jmp .PhysicalDamage

.PhysicalDamageHalf
          jsr CalcAttackDamage
          lsr ATTACK_DAMAGE + 1
          ror ATTACK_DAMAGE

          ;min. 1
          lda ATTACK_DAMAGE
          eor ATTACK_DAMAGE + 1
          bne +

          lda #1
          sta ATTACK_DAMAGE
+
          jmp .Goon


.PhysicalDamage

          jsr CalcAttackDamage
.Goon
          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimCalcMagicalDamage
AnimCalcMagicalDamage
          sty PLAY_ANIM_POS
          lda #ATT_TYPE_MAGIC
          sta ATTACK_TYPE
          jsr CalcAttackDamage
          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



;followed by text pointer
!zone AnimDisplayText
AnimDisplayText
          iny
          tya
          clc
          adc ZEROPAGE_POINTER_5
          sta ZEROPAGE_POINTER_1
          lda ZEROPAGE_POINTER_5 + 1
          adc #0
          sta ZEROPAGE_POINTER_1 + 1

          sty PLAY_ANIM_POS

          jsr ClearTopPanel

          lda #1
          sta PARAM1
          sta PARAM2
          jsr DisplayText

          ;add length of text
          lda PLAY_ANIM_POS
          clc
          adc PARAM5
          tay
          dey
          jmp AnimNextFrame


!zone AnimClearText
AnimClearText
          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          sty PLAY_ANIM_POS
          jsr ClearTopPanel
          ldy PLAY_ANIM_POS

.NoDisplay
          jmp AnimNextFrame



!zone AnimMoveTowardsTarget
AnimMoveTowardsTarget
          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          ldx CURRENT_TARGET
          lda FIGHTER_X,x
          sta PARAM1
          lda FIGHTER_Y,x
          sta PARAM2
          ldx CURRENT_INDEX
          inx
          inx
          jsr CalcSpritePosFromCharPos

.NoDisplay
          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimMoveTowardsStartPos
AnimMoveTowardsStartPos
          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          ;reset fighter pos
          ldx CURRENT_INDEX
          lda FIGHTER_X,x
          sta PARAM1
          lda FIGHTER_Y,x
          sta PARAM2
          inx
          inx
          jsr CalcSpritePosFromCharPos

.NoDisplay
          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimSteal
AnimSteal
          ldy CURRENT_TARGET
          ldx FIGHTER_ACTIVE,y

          ;has item to steal?
          lda ENEMY_STEAL_ITEM_CHANCE,x
          sta PARAM9

          lda ENEMY_STEAL_ITEM,x
          sta PARAM10
          cmp #ITEM_NONE
          bne .CheckChance

          ;has item to drop?
          lda ENEMY_DROP_ITEM,x
          sta PARAM10
          cmp #ITEM_NONE
          beq .NoItemsFromThisEnemy
          lda ENEMY_DROP_ITEM_CHANCE,x
          sta PARAM9

.CheckChance
          lda #0
          ldy #100
          jsr GenerateRangedRandom
          cmp PARAM9
          bcs .NoItemsFromThisEnemy

          ;yay, we get an item!
          lda PARAM10
          jsr AddItemToInventory

          lda #<TEXT_YOU_FOUND
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_YOU_FOUND
          sta ZEROPAGE_POINTER_1 + 1
          lda #1
          sta PARAM1
          sta PARAM2
          jsr DisplayText

          ldy CURRENT_TARGET
          ldx FIGHTER_TYPE,y
          ldy PARAM10

          lda ITEM_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda #11
          sta PARAM1
          jsr DisplayText

          jmp .WaitAndClear

.NoItemsFromThisEnemy
          ldx CURRENT_TARGET
          lda FIGHTER_X,x
          sta PARAM1
          lda FIGHTER_Y,x
          sta PARAM2
          dec PARAM2

          ;two chars higher for party
          cpx #4
          bcs +
          dec PARAM2
          dec PARAM2
+

          lda #<TEXT_MISS
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_MISS
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

.WaitAndClear
          lda #30
          sta PLAY_ANIM_POS
-
          jsr WaitFrame

          dec PLAY_ANIM_POS
          bne -

          ldy #0
          jmp AnimHideAttackDamage



!zone AnimStudy
AnimStudy
          ldy CURRENT_TARGET
          ldx FIGHTER_ACTIVE,y

          ;has item to steal?
          lda ENEMY_TECH,x
          cmp #TECH_NONE
          beq .Miss
          sta PARAM10

          ;already learned?
          tay
          lda TECH_LEARNED,y
          bne .Miss

          ;check chance
          lda #50
          jsr CheckChance
          beq .Miss

          ;yay, we learn the technic
          lda #<TEXT_YOU_LEARN
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_YOU_LEARN
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayTextOnTop

          ;actual learning
          ldy PARAM10
          lda #1
          sta TECH_LEARNED,y

          lda TECH_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda TECH_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda #13
          sta PARAM1
          jsr DisplayText

          jmp .WaitAndClear

.Miss
          ldx CURRENT_TARGET
          lda FIGHTER_X,x
          sta PARAM1
          lda FIGHTER_Y,x
          sta PARAM2
          dec PARAM2

          lda #<TEXT_MISS
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_MISS
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

.WaitAndClear
          lda #30
          sta PLAY_ANIM_POS
-
          jsr WaitFrame

          dec PLAY_ANIM_POS
          bne -

          ldy #0
          jmp AnimHideAttackDamage



!zone AnimShake
AnimShake
          sty PLAY_ANIM_POS

          lda #50
          sta PLAY_ANIM_POS

          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

-
          jsr WaitFrame
          jsr GenerateRandomNumber
          and #$07
          sta GAME_SHAKE

          dec PLAY_ANIM_POS
          bne -

.NoDisplay
          lda #0
          sta GAME_SHAKE
          ldy PLAY_ANIM_POS
          jmp AnimNextFrame


!zone AnimDelay
AnimDelay
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PLAY_ANIM_POS

          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

-
          jsr WaitFrame
          dec PLAY_ANIM_POS
          bne -

.NoDisplay
          jmp AnimNextFrame



!zone AnimHideAttackDamage
AnimHideAttackDamage
          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay


          sty PLAY_ANIM_POS
          ldx CURRENT_TARGET
          ldy FIGHTER_Y,x
          dey

          ;higher above players
          cpx #4
          bcs +

          dey
          dey
+

          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_3
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_3 + 1
          ldy FIGHTER_X,x

          lda #32
          sta (ZEROPAGE_POINTER_3),y
          iny
          sta (ZEROPAGE_POINTER_3),y
          iny
          sta (ZEROPAGE_POINTER_3),y
          iny
          sta (ZEROPAGE_POINTER_3),y
          ldy PLAY_ANIM_POS
.NoDisplay
          jmp AnimNextFrame



!zone AnimDisplayAttackDamage
AnimDisplayAttackDamage
          sty PLAY_ANIM_POS
          ldx CURRENT_TARGET
          lda FIGHTER_X,x
          sta PARAM1
          lda FIGHTER_Y,x
          sta PARAM2
          dec PARAM2

          ;higher above players
          cpx #4
          bcs +

          dec PARAM2
          dec PARAM2
+

          lda ATTACK_MISS
          beq .AttackHits

          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          lda #<TEXT_MISS
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_MISS
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText
          jmp .AttackMissed


 .AttackHits
          lda ATTACK_ANIM_NO_DISPLAY
          bne +

          ldx ATTACK_DAMAGE_TYPE
          ldy DISPLAY_NUMBER_COLOR,x
          ldx ATTACK_DAMAGE
          lda ATTACK_DAMAGE + 1
          jsr Display16BitDecimalWithColorInY

+
          lda ATTACK_DAMAGE_TYPE
          cmp #ADT_HURT_HP
          beq .HurtHP
          cmp #ADT_HEAL_HP
          beq .HealHP
          cmp #ADT_HEAL_MP
          beq .HealMP

          ;apply MP damage
          ;jsr ApplyMPDamageToTarget
          jmp +


.HurtHP
          jsr ApplyDamageToTarget
          jmp +
.HealHP
          lda ATTACK_DAMAGE
          ldy ATTACK_DAMAGE + 1
          ldx CURRENT_TARGET
          jsr IncreaseFighterHP
          jmp +
.HealMP
          lda ATTACK_DAMAGE
          ldy ATTACK_DAMAGE + 1
          ldx CURRENT_TARGET
          jsr IncreaseFighterMP

+

.AttackMissed
          ldy PLAY_ANIM_POS
.NoDisplay
          jmp AnimNextFrame



!zone AnimRemoveObject
AnimRemoveObject
          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          ldx #SPRITE_INDEX_ATTACK_ANIM_FRONT
          jsr RemoveObject

.NoDisplay
          jmp AnimNextFrame



!zone AnimSpawnObject
AnimSpawnObject
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM6

          ;X offset
          ldx CURRENT_TARGET
          iny
          lda (ZEROPAGE_POINTER_5),y
          clc
          adc FIGHTER_X,x
          sta PARAM1

          ;y offset
          iny
          lda (ZEROPAGE_POINTER_5),y
          clc
          adc FIGHTER_Y,x
          sta PARAM2

          ;color
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM7

          sty PARAM8

          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          ;center sprite
          lda FIGHTER_WIDTH,x
          cmp #3
          bcc +
          sec
          sbc #3
          lsr
+
          clc
          adc PARAM1
          sta PARAM1
          lda FIGHTER_HEIGHT,x
          lsr
          clc
          adc PARAM2
          sta PARAM2

          ldx #SPRITE_INDEX_ATTACK_ANIM_FRONT
          lda #TYPE_MENU_POINTER
          sta PARAM3
          jsr DoSpawnObject

          lda PARAM6
          sta SPRITE_POINTER_BASE,x

          lda PARAM7
          sta VIC_SPRITE_COLOR,x
          bpl +
          ;MC

          lda BIT_TABLE,x
          ora VIC_SPRITE_MULTICOLOR
          sta VIC_SPRITE_MULTICOLOR
          jmp ++

+
          ;single color
          lda BIT_TABLE,x
          eor #$ff
          and VIC_SPRITE_MULTICOLOR
          sta VIC_SPRITE_MULTICOLOR
++
          ldy PARAM8

.NoDisplay
AnimNextFrame
          iny
          tya
          clc
          adc ZEROPAGE_POINTER_5
          sta ZEROPAGE_POINTER_5
          bcc +
          inc ZEROPAGE_POINTER_5 + 1
+

          jmp PlayAttackAnimation.HandleFrame



!zone AnimMoveObject
AnimMoveObject
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM1

          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM2
          sty PARAM8

          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          ldx #SPRITE_INDEX_ATTACK_ANIM_FRONT

.NextX
          lda PARAM1
          beq .DXDone
          bmi .MoveLeft

          jsr MoveSpriteRight
          dec PARAM1
          jmp .NextX


.MoveLeft
          jsr MoveSpriteLeft
          inc PARAM1
          jmp .NextX

.DXDone
.NextY
          lda PARAM2
          beq .DYDone
          bmi .MoveUp

          jsr MoveSpriteDown
          dec PARAM2
          jmp .NextY

.MoveUp
          jsr MoveSpriteUp
          inc PARAM2
          jmp .NextY

.DYDone
          ldy PARAM8
.NoDisplay
          jmp AnimNextFrame



!zone AnimSetObject
AnimSetObject
          iny
          ldx #SPRITE_INDEX_ATTACK_ANIM_FRONT
          lda (ZEROPAGE_POINTER_5),y
          sta SPRITE_POINTER_BASE,x
          jmp AnimNextFrame



!zone AnimFullReviveParty
AnimFullReviveParty
          ldx #0
.NextFighter
          lda FIGHTER_ACTIVE,x
          beq .NotActive

          lda FIGHTER_HP_MAX_LO,x
          sta FIGHTER_HP_LO,x
          lda FIGHTER_HP_MAX_HI,x
          sta FIGHTER_HP_HI,x
          lda FIGHTER_MP_MAX_LO,x
          sta FIGHTER_MP_LO,x
          lda FIGHTER_MP_MAX_HI,x
          sta FIGHTER_MP_HI,x

          ;remove all stati
          lda #0
          sta FIGHTER_STATE,x
          ;sta FIGHTER_STATE_EX,x

.NotActive
          inx
          cpx #4
          bne .NextFighter

          sty PLAY_ANIM_POS

          jsr DisplayPartyValues

          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimAnimateObject
AnimAnimateObject
          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          ;num frames
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM1

          ;num anim steps
          iny
          lda (ZEROPAGE_POINTER_5),y
          sta PARAM2

          sty PLAY_ANIM_POS

          ;store base sprite index
          ldx #SPRITE_INDEX_ATTACK_ANIM_FRONT
          lda SPRITE_POINTER_BASE,x
          sta PARAM9

.NextFrame
          ldx #SPRITE_INDEX_ATTACK_ANIM_FRONT

          inc SPRITE_ANIM_POS,x

          lda SPRITE_ANIM_POS,x
          cmp PARAM2
          bne +

          lda #0
          sta SPRITE_ANIM_POS,x
+
          clc
          adc PARAM9
          sta SPRITE_POINTER_BASE,x

          jsr WaitFrame

          dec PARAM1
          bne .NextFrame

          ldy PLAY_ANIM_POS
.NoDisplay
          jmp AnimNextFrame



!zone AnimReviveTarget
AnimReviveTarget
          ldx CURRENT_TARGET

          lda FIGHTER_ACTIVE,x
          beq .Goon

          lda FIGHTER_STATE,x
          and #STATUS_KO
          beq .Goon

          ;alive again!
          inc NUM_PLAYERS_ALIVE

          lda #STATUS_KO
          eor #$ff
          and FIGHTER_STATE,x
          sta FIGHTER_STATE,x

          sty PLAY_ANIM_POS

          ;rebuild character sprite
          lda ATTACK_ANIM_NO_DISPLAY
          bne +

          ldx CURRENT_TARGET
          lda TYPE_START_SPRITE + 1,x
          sta SPRITE_POINTER_BASE + 2,x
          lda TYPE_START_COLOR + 1,x
          sta VIC_SPRITE_COLOR + 2,x

+

          ;revive with random HP
          lda #20
          ldy #50
          jsr GenerateRangedRandom

          ldy #0
          jsr IncreaseFighterHP

          ldy PLAY_ANIM_POS
.Goon
          jmp AnimNextFrame



!zone AnimBeginBlock
AnimBeginBlock
          lda ZEROPAGE_POINTER_5
          sta ATTACK_BLOCK_START_POS
          lda ZEROPAGE_POINTER_5 + 1
          sta ATTACK_BLOCK_START_POS + 1

          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimEndBlock
AnimEndBlock
          lda ATTACK_TARGET
          cmp #ATTACK_TARGET_SINGLE
          beq .EndDone
          cmp #ATTACK_TARGET_ENEMY_GROUP
          beq .CheckEnemyGroup
          cmp #ATTACK_TARGET_ALL
          beq .CheckEnemyGroup

          ;was ATTACK_TARGET_PARTY
.NextPlayer
          inc CURRENT_TARGET
          ldx CURRENT_TARGET
          cpx #4
          beq .EndDone

          jsr CanSelectOrTargetFighter
          beq .NextPlayer

          jmp .JumpToBeginBlock

.CheckEnemyGroup
          inc CURRENT_TARGET
          ldx CURRENT_TARGET
          cpx #NUM_FIGHTERS
          beq .EndDone

          lda FIGHTER_ACTIVE,x
          beq .CheckEnemyGroup

.JumpToBeginBlock
          lda ATTACK_BLOCK_START_POS
          sta ZEROPAGE_POINTER_5
          lda ATTACK_BLOCK_START_POS + 1
          sta ZEROPAGE_POINTER_5 + 1
          ldy #0
          jmp AnimNextFrame

.EndDone
          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimEnterJumpMode
AnimEnterJumpMode
          sty PLAY_ANIM_POS
          lda #$0
          sta VIC_SPRITE_PRIORITY

          lda CURRENT_INDEX
          clc
          adc #2
          asl
          tax

-
          jsr WaitFrame

          lda #4
          sta PARAM1
--
          lda VIC_SPRITE_Y_POS,x
          beq .Done

          dec VIC_SPRITE_Y_POS,x

          dec PARAM1
          bne --
          jmp -


.Done
          lda #$3c
          sta VIC_SPRITE_PRIORITY

          ldy PLAY_ANIM_POS
          jmp AnimNextFrame



!zone AnimEndJumpMode
AnimEndJumpMode
          lda #$0
          sta VIC_SPRITE_PRIORITY

          ldy CURRENT_TARGET
          lda FIGHTER_X,y
          sta PARAM1
          lda FIGHTER_Y,y
          sta PARAM2
          ldx CURRENT_INDEX
          inx
          inx
          jsr CalcSpritePosFromCharPos

          lda CURRENT_INDEX
          clc
          adc #2
          tay
          asl
          tax

          lda #0
          sta VIC_SPRITE_Y_POS,x


-
          jsr WaitFrame

          lda #4
          sta PARAM1
--
          lda VIC_SPRITE_Y_POS,x
          cmp SPRITE_POS_Y,y
          beq .Done

          inc VIC_SPRITE_Y_POS,x

          dec PARAM1
          bne --
          jmp -


.Done
          lda #$3c
          sta VIC_SPRITE_PRIORITY

          ldy PLAY_ANIM_POS
          jmp AnimNextFrame





ATTACK_ANIM_LIST_LO
          !byte <AA_SWORD
          !byte <AA_POISON_BITE
          !byte <AA_HERBS
          !byte <AA_ETHER
          !byte <AA_FIRE
          !byte <AA_FENIX_DOWN
          !byte <AA_ANTIDOTE
          !byte <AA_HEAL_PARTY
          !byte <AA_STEAL
          !byte <AA_STUDY
          !byte <AA_QUAKE
          !byte <AA_STUN
          !byte <AA_ICE
          !byte <AA_JUMP
          !byte <AA_JUMP_END
          !byte <AA_LIGHTNING
          !byte <AA_CURE
          !byte <AA_RAISE
          !byte <AA_ROCK
          !byte <AA_POISON_DAMAGE

ATTACK_ANIM_LIST_HI
          !byte >AA_SWORD
          !byte >AA_POISON_BITE
          !byte >AA_HERBS
          !byte >AA_ETHER
          !byte >AA_FIRE
          !byte >AA_FENIX_DOWN
          !byte >AA_ANTIDOTE
          !byte >AA_HEAL_PARTY
          !byte >AA_STEAL
          !byte >AA_STUDY
          !byte >AA_QUAKE
          !byte >AA_STUN
          !byte >AA_ICE
          !byte >AA_JUMP
          !byte >AA_JUMP_END
          !byte >AA_LIGHTNING
          !byte >AA_CURE
          !byte >AA_RAISE
          !byte >AA_ROCK
          !byte >AA_POISON_DAMAGE

AA_SWORD
          !byte AT_CALC_PHYSICAL_DAMAGE,0
          !byte AT_SPAWN_OBJECT,SPRITE_SWORD_ATTACK,2,0,$81
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,6
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,6
          !byte AT_DELAY,3
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,3
          !byte AT_REMOVE
          !byte AT_DELAY,50
          !byte AT_HIDE_DAMAGE | AT_END

AA_HERBS
          !byte AT_SET_DAMAGE,0,25,ADT_HEAL_HP,0
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_SWORD_ATTACK,2,0,5
          !byte AT_DELAY,9
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,3
          !byte AT_REMOVE
          !byte AT_DELAY,50
          !byte AT_HIDE_DAMAGE | AT_END

AA_POISON_BITE
          !byte AT_CALC_PHYSICAL_DAMAGE,1
          !byte AT_BEGIN_BLOCK
          !byte AT_DISPLAY_TEXT
          !text "POISOn"
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_POW_1,1,1,5
          !byte AT_DELAY,9
          !byte AT_DISPLAY_DAMAGE
          !byte AT_STATUS_ADD,STATUS_POISONED
          !byte AT_MOVE,8,256-8
          !byte AT_DELAY,6
          !byte AT_MOVE,256-6,256-6
          !byte AT_DELAY,6
          !byte AT_MOVE,4,256-4
          !byte AT_DELAY,6
          !byte AT_REMOVE
          !byte AT_HIDE_DAMAGE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,5



AA_ETHER
          !byte AT_SET_DAMAGE,0,25,ADT_HEAL_MP,0
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_SWORD_ATTACK,2,0,3
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,6
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,6
          !byte AT_DELAY,3
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,3
          !byte AT_REMOVE
          !byte AT_DELAY,50
          !byte AT_HIDE_DAMAGE | AT_END

AA_FENIX_DOWN
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_POW_1,1,1,1
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,256 - 6
          !byte AT_SET_OBJECT,SPRITE_POW_2
          !byte AT_DELAY,3
          !byte AT_MOVE,6,256 - 6
          !byte AT_DELAY,12
          !byte AT_REVIVE_TARGET
          !byte AT_DELAY,3
          !byte AT_REMOVE
          !byte AT_DELAY,50
          !byte AT_HIDE_DAMAGE | AT_END

AA_HEAL_PARTY
          !byte AT_HEAL_PARTY
          !byte AT_DISPLAY_TEXT
          !text "PARTY HEALEd"
          !byte AT_DELAY,50
          !byte AT_CLEAR_TEXT | AT_END


AA_ANTIDOTE
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_POW_1,1,1,7
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,256 - 6
          !byte AT_SET_OBJECT,SPRITE_POW_2
          !byte AT_DELAY,3
          !byte AT_MOVE,6,256 - 6
          !byte AT_DELAY,12
          !byte AT_STATUS_REMOVE,STATUS_POISONED
          !byte AT_REMOVE
          !byte AT_DELAY | AT_END,50

AA_FIRE
          !byte AT_DEDUCT_MP_OR_ABORT,10
          !byte AT_BEGIN_BLOCK
          !byte AT_SET_DAMAGE,>200,<200,ADT_MAGIC | ADT_HURT_HP,ELEMENT_FIRE
          !byte AT_CALC_MAGICAL_DAMAGE
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_FIRE_1,0,0,$87
          !byte AT_ANIM_OBJECT,25,2
          !byte AT_DISPLAY_DAMAGE
          !byte AT_ANIM_OBJECT,25,2
          !byte AT_HIDE_DAMAGE
          !byte AT_REMOVE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,50

AA_ICE
          !byte AT_DEDUCT_MP_OR_ABORT,10
          !byte AT_BEGIN_BLOCK
          !byte AT_SET_DAMAGE,>200,<200,ADT_MAGIC | ADT_HURT_HP,ELEMENT_ICE
          !byte AT_CALC_MAGICAL_DAMAGE
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_SNOW_FLAKE,0,0,3
          !byte AT_DELAY,10
          !byte AT_MOVE,256 - 6,256 - 6
          !byte AT_DELAY,3
          !byte AT_MOVE,6,256 - 6
          !byte AT_DELAY,12
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,25
          !byte AT_HIDE_DAMAGE
          !byte AT_REMOVE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,50

AA_STUDY
          !byte AT_MOVE_TOWARDS_TARGET
          !byte AT_DELAY,20
          !byte AT_STUDY
          !byte AT_MOVE_TOWARDS_START_POS
          !byte AT_DELAY | AT_END,50

AA_STEAL
          !byte AT_MOVE_TOWARDS_TARGET
          !byte AT_DELAY,20
          !byte AT_STEAL
          !byte AT_MOVE_TOWARDS_START_POS
          !byte AT_DELAY | AT_END,50

AA_QUAKE
          !byte AT_DEDUCT_MP_OR_ABORT,20
          !byte AT_SET_DAMAGE,>200,<200,ADT_MAGIC | ADT_HURT_HP,ELEMENT_EARTH
          !byte AT_AUTO_TARGET,1
          !byte AT_SHAKE
          !byte AT_BEGIN_BLOCK
          !byte AT_CALC_MAGICAL_DAMAGE
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,20
          !byte AT_HIDE_DAMAGE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,50

AA_STUN
          !byte AT_DELAY,10
          !byte AT_DISPLAY_TEXT
          !text "STUn"
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_POW_1,1,1,7
          !byte AT_DELAY,3
          !byte AT_MOVE,256 - 6,256 - 6
          !byte AT_SET_OBJECT,SPRITE_POW_2
          !byte AT_DELAY,3
          !byte AT_MOVE,6,256 - 6
          !byte AT_DELAY,12
          !byte AT_STATUS_ADD,STATUS_FROZEN
          !byte AT_REMOVE
          !byte AT_DELAY | AT_END,50

AA_JUMP_END
          !byte AT_END_JUMP_MODE
          !byte AT_STATUS_REMOVE,STATUS_JUMPED
          !byte AT_CALC_PHYSICAL_DAMAGE,0
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY, 50
          !byte AT_MOVE_TOWARDS_START_POS
          !byte AT_HIDE_DAMAGE
          !byte AT_DELAY | AT_END, 50

AA_JUMP
          !byte AT_ENTER_JUMP_MODE
          !byte AT_STATUS_ADD,STATUS_JUMPED
          !byte AT_DELAY | AT_END, 50


AA_LIGHTNING
          !byte AT_DEDUCT_MP_OR_ABORT,10
          !byte AT_BEGIN_BLOCK
          !byte AT_SET_DAMAGE,>200,<200,ADT_MAGIC | ADT_HURT_HP,ELEMENT_LIGHTNING
          !byte AT_CALC_MAGICAL_DAMAGE
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_LIGHTNING,0,0,07
          !byte AT_MOVE,0,256 - 20
          !byte AT_DELAY,5
          !byte AT_MOVE,0,10
          !byte AT_DELAY,5
          !byte AT_MOVE,0,10
          !byte AT_DELAY,5
          !byte AT_MOVE,0,10
          !byte AT_DELAY,5
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,5
          !byte AT_REMOVE
          !byte AT_DELAY,25
          !byte AT_HIDE_DAMAGE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,50

AA_CURE
          !byte AT_DEDUCT_MP_OR_ABORT,10
          !byte AT_BEGIN_BLOCK
          !byte AT_SET_DAMAGE,>200,<200,ADT_MAGIC | ADT_HEAL_HP,0
          !byte AT_CALC_MAGICAL_DAMAGE
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_POW_1,2,0,5
          !byte AT_DELAY,9
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,3
          !byte AT_REMOVE
          !byte AT_DELAY,50
          !byte AT_HIDE_DAMAGE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,50

AA_RAISE
          !byte AT_DEDUCT_MP_OR_ABORT,20
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_POW_2,2,0,1
          !byte AT_DELAY,9
          !byte AT_REVIVE_TARGET
          !byte AT_DELAY,3
          !byte AT_REMOVE
          !byte AT_DELAY | AT_END,20

AA_ROCK
          !byte AT_DEDUCT_MP_OR_ABORT,10
          !byte AT_BEGIN_BLOCK
          !byte AT_SET_DAMAGE,>200,<200,ADT_MAGIC | ADT_HURT_HP,ELEMENT_EARTH
          !byte AT_CALC_MAGICAL_DAMAGE
          !byte AT_DELAY,10
          !byte AT_SPAWN_OBJECT,SPRITE_ROCK,0,0,$88
          !byte AT_MOVE,0,256 - 20
          !byte AT_DELAY,5
          !byte AT_MOVE,0,10
          !byte AT_DELAY,5
          !byte AT_MOVE,0,10
          !byte AT_DELAY,5
          !byte AT_MOVE,0,10
          !byte AT_DELAY,5
          !byte AT_DISPLAY_DAMAGE
          !byte AT_DELAY,5
          !byte AT_REMOVE
          !byte AT_DELAY,25
          !byte AT_HIDE_DAMAGE
          !byte AT_END_BLOCK
          !byte AT_DELAY | AT_END,50

AA_POISON_DAMAGE
          !byte AT_SPAWN_OBJECT,SPRITE_POW_1,1,1,5
          !byte AT_DELAY,9
          !byte AT_DISPLAY_DAMAGE
          !byte AT_MOVE,8,256-8
          !byte AT_DELAY,6
          !byte AT_MOVE,256-6,256-6
          !byte AT_DELAY,6
          !byte AT_MOVE,4,256-4
          !byte AT_REMOVE
          !byte AT_DELAY,6
          !byte AT_HIDE_DAMAGE
          !byte AT_DELAY | AT_END,5

ATTACK_BLOCK_START_POS
          !word 0


;lookup from ADT_xxx
DISPLAY_NUMBER_COLOR
          !byte 1     ;hurt HP
          !byte 5     ;heal HP
          !byte 2     ;hurt MP
          !byte 6     ;heal MP


;ATTACK_ANIM_NO_DISPLAY
;          !byte 0

;which group?
;ATTACK_TARGET_SINGLE      = 0
;ATTACK_TARGET_ENEMY_GROUP = 1
;ATTACK_TARGET_PARTY       = 2
;ATTACK_TARGET_ALL         = 3
ATTACK_TARGET
          !byte 0
          