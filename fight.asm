!zone DisplayFightBackground
DisplayFightBackground
          jsr WaitFrame

          lda #0
          sta VIC_SPRITE_ENABLE
          sta NUM_PLAYERS_ALIVE

          lda #36
          sta PARAM1
          lda #7
          sta PARAM2

          ;clear all enemies
          ldx #4
          lda #0
-
          sta FIGHTER_ACTIVE,x
          sta FIGHTER_TYPE,x
          inx
          cpx #NUM_FIGHTERS
          bne -

          ;copy party
          ldx #0
          stx PARAM7
-
          lda FIGHTER_ACTIVE,x
          bne +
          jmp .NotActive
+
          ;store original max values
          lda FIGHTER_HP_MAX_LO,x
          sta STORED_PARTY_HP_MAX_LO,x
          lda FIGHTER_HP_MAX_HI,x
          sta STORED_PARTY_HP_MAX_HI,x
          lda FIGHTER_MP_MAX_LO,x
          sta STORED_PARTY_MP_MAX_LO,x
          lda FIGHTER_MP_MAX_HI,x
          sta STORED_PARTY_MP_MAX_HI,x

          lda #36
          sta FIGHTER_X,x
          lda PARAM2
          sta FIGHTER_Y,x

          lda FIGHTER_ACTIVE,x
          sta PARAM3
          inx
          inx
          jsr DoSpawnObject
          dex
          dex

          ;init speed pos by 50 to 100%
          ldy #200
          lda #0
          jsr GenerateRangedRandom
          sta FIGHTER_SPEED_POS,x

          ;KO is not alive
          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne +
          inc NUM_PLAYERS_ALIVE
          jmp ++
+
          ;player is KO
          lda #SPRITE_RIP
          sta SPRITE_POINTER_BASE + 2,x
          lda #15
          sta VIC_SPRITE_COLOR + 2,x
++
          inc PARAM2
          inc PARAM2
          inc PARAM2

.NotActive
          inc PARAM7
          ldx PARAM7

          cpx #4
          beq +
          jmp -
+

          ldx #18
          lda #0

.ClearLine
          ldy #0

          lda SCREEN_LINE_OFFSET_TABLE_HI,x
          sta ZEROPAGE_POINTER_1+1
          clc
          adc #12
          sta ZEROPAGE_POINTER_2+1
          lda SCREEN_LINE_OFFSET_TABLE_LO,x
          sta ZEROPAGE_POINTER_1

.ClearChar
          lda #32
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y

          iny
          cpy #40
          bne .ClearChar

          cpx #3
          beq .Done
          dex
          jmp .ClearLine

.Done
          rts



;formation in A
!zone StartFightWithFormation
StartFightWithFormation
          sta CURRENT_FORMATION

          ;clean stack
          pla
          pla

          lda #0
          sta MAP_ACTIVE
          lda #1
          sta NO_DISPLAY
          jsr WaitFrame

          jsr DisplayFightBackground

!ifdef MUSIC_ACTIVE {
          lda #1
          jsr MUSIC_PLAYER
}

          ;init battle vars
          lda #0
          sta FIGHT_XP_WON
          sta FIGHT_XP_WON + 1

          lda CURRENT_FORMATION
          jsr InitFormation

          lda #0
          sta NO_DISPLAY
          jmp FightLoop



!zone StartFight
StartFight
          ;clean stack
          pla
          pla

          ldy #MD_LOCAL_FORMATION_GROUP
          lda (CURRENT_MAP_DATA),y
          and #$7f
          bne +

          ;there is no formation for this map
          jsr GenerateRandomNumber
          and #$1f
          sta PARTY_STEPS_TO_AUTO_FIGHT

          jmp GameLoop

+
          lda #0
          sta MAP_ACTIVE
          lda #1
          sta NO_DISPLAY
          jsr WaitFrame

          jsr DisplayFightBackground

!ifdef MUSIC_ACTIVE {
          lda #1
          jsr MUSIC_PLAYER
}

          ;init battle vars
          lda #0
          sta FIGHT_XP_WON
          sta FIGHT_XP_WON + 1

          ldy #MD_LOCAL_FORMATION_GROUP
          lda (CURRENT_MAP_DATA),y
          and #$7f

          ;select any formation from this group
          sta PARAM10
          dec PARAM10

          jsr GenerateRandomNumber
          sta PARAM9
          ldx #0

.KeepSearching
          lda FORMATION_GROUP,x
          cmp PARAM10
          beq .GroupMatch

.KeepSearching2
          inx
          cpx #NUM_FORMATIONS
          bne .KeepSearching

          ldx #0
          jmp .KeepSearching


.GroupMatch
          dec PARAM9
          bne .KeepSearching2

          txa
          jsr InitFormation


          ;init battle temp stats
          ldx #0
          lda #0
-
          sta FIGHTER_FROZEN_COUNT,x
          sta FIGHTER_JUMP_COUNT,x
          sta FIGHTER_JUMP_TARGET,x
          inx
          cpx #NUM_FIGHTERS
          bne -

          lda #0
          sta NO_DISPLAY
          jmp FightLoop



!zone FightWon
FightWon
          ;set happen if won
          lda FIGHT_WON_HAPPEN
          bmi +
          jsr ToggleHappen
+

          lda #0

          sta VIC_SPRITE_ENABLE
          sta SPRITE_ACTIVE
          sta SPRITE_ACTIVE + 1
          sta SPRITE_ACTIVE + 2
          sta SPRITE_ACTIVE + 3
          sta SPRITE_ACTIVE + 4
          sta SPRITE_ACTIVE + 5
          sta SPRITE_ACTIVE + 6
          sta SPRITE_ACTIVE + 7

          jsr ClearEnemyNames

          ;copy stored values
          ldx #0
          stx CURRENT_INDEX
-
          lda STORED_PARTY_HP_MAX_LO,x
          sta FIGHTER_HP_MAX_LO,x
          lda STORED_PARTY_HP_MAX_HI,x
          sta FIGHTER_HP_MAX_HI,x
          lda STORED_PARTY_MP_MAX_LO,x
          sta FIGHTER_MP_MAX_LO,x
          lda STORED_PARTY_MP_MAX_HI,x
          sta FIGHTER_MP_MAX_HI,x

          ;sanitize states
          lda #0
          sta FIGHTER_FROZEN_COUNT,x
          ;sta FIGHTER_STATE_EX,x
          lda FIGHTER_STATE,x
          and #STATUS_KO | STATUS_POISONED
          sta FIGHTER_STATE,x

          jsr ClearBattleTimerChars

          ;make sure HP stay <= HPMax
          ldx CURRENT_INDEX
          jsr CapFighterHP
          ldx CURRENT_INDEX
          jsr CapFighterMP

          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #4
          bne -

          lda #<TEXT_YOU_WIN
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_YOU_WIN
          sta ZEROPAGE_POINTER_1 + 1
          lda #1
          sta PARAM1
          sta PARAM2
          jsr DisplayText


          ;win screen
          lda #0
          sta PARAM1
          lda #3
          sta PARAM2
          lda #40
          sta PARAM3
          lda #16
          sta PARAM4
          jsr DisplayBox

          lda #<TEXT_EXP
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_EXP
          sta ZEROPAGE_POINTER_1 + 1
          lda #25
          sta PARAM1
          lda #5
          sta PARAM2
          jsr DisplayText

          ;display experience won
          lda #30
          sta PARAM1
          lda #6
          sta PARAM2
          ldx FIGHT_XP_WON
          lda FIGHT_XP_WON + 1
          jsr Display16BitDecimal

          ;display fighter
          lda #2
          sta PARAM1
          lda #5
          sta PARAM2
          sta PARAM10
          ldx #0
          stx CURRENT_INDEX
.NextFighter
          lda FIGHTER_ACTIVE,x
          bne +
          jmp .FighterDead
+
          lda PARAM10
          sta PARAM2
          lda PARTY_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda PARTY_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          inc PARAM1
          inc PARAM2
          lda #<TEXT_LV_EXP
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_LV_EXP
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          ;fighter experience
          ldy CURRENT_INDEX

          ;fighter level
          lda #6
          sta PARAM1
          lda PARAM10
          sta PARAM2
          inc PARAM2


          ldy CURRENT_INDEX
          lda FIGHTER_LEVEL,y
          jsr Display2DigitDecimal

          ;display XP received
          lda #13
          sta PARAM1
          ldy CURRENT_INDEX
          lda PARTY_XP_2,y
          sta LOCAL1
          ldx PARTY_XP_1,y
          lda PARTY_XP_3,y
          ldy LOCAL1
          jsr Display24BitDecimal

          lda #2
          sta PARAM1

.FighterDead
          inc PARAM10
          inc PARAM10
          inc PARAM10
          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #4
          beq AddXPLoop
          jmp .NextFighter


!zone AddXPLoop
XP_ADD_DELTA
          !byte 0
          !byte 0
AddXPLoop
          jsr WaitFrame

          lda FIGHT_XP_WON
          ora FIGHT_XP_WON + 1
          bne +
          jmp .AddXPDone
+

          lda #1
          sta XP_ADD_DELTA
          lda #0
          sta XP_ADD_DELTA + 1

          lda FIGHT_XP_WON + 1
          beq .DecBy1

          dec XP_ADD_DELTA
          inc XP_ADD_DELTA + 1

.DecBy1
          ;dec xp by 1
          lda FIGHT_XP_WON
          sec
          sbc XP_ADD_DELTA
          sta FIGHT_XP_WON
          lda FIGHT_XP_WON + 1
          sbc XP_ADD_DELTA + 1
          sta FIGHT_XP_WON + 1

          ;display experience won
          lda #30
          sta PARAM1
          lda #6
          sta PARAM2
          ldx FIGHT_XP_WON
          lda FIGHT_XP_WON + 1
          jsr Display16BitDecimal

          ldy #0
          sty CURRENT_INDEX

.XPNextFighter
          ldy CURRENT_INDEX

          ;copy over resulting values (states!)
          ;TODO - max values

          lda FIGHTER_ACTIVE,y
          bne +
          jmp .XPSkipDeadFighter

+
          lda FIGHTER_STATE,y
          and #STATUS_KO
          bne .XPSkipDeadFighter

          lda PARTY_XP_1,y
          clc
          adc XP_ADD_DELTA
          sta PARTY_XP_1,y
          lda PARTY_XP_2,y
          adc XP_ADD_DELTA + 1
          sta PARTY_XP_2,y
          lda PARTY_XP_3,y
          adc #0
          sta PARTY_XP_3,y

          ;display fighter XP
          lda #13
          sta PARAM1
          sty LOCAL1
          tya
          asl
          clc
          adc LOCAL1
          adc #6
          sta PARAM2
          sta PARAM10

          lda PARTY_XP_2,y
          sta LOCAL1
          ldx PARTY_XP_1,y
          lda PARTY_XP_3,y
          ldy LOCAL1
          jsr Display24BitDecimal

          ;level up?
          ldy CURRENT_INDEX
          lda FIGHTER_LEVEL,y
          tay
          iny
          cpy #100
          bne +
          jmp .LevelMaxed
+
          jsr CalcExpForNextLevel

          ;compare
          ldx CURRENT_INDEX
          lda RESULT_32BIT
          sec
          sbc PARTY_XP_1,x
          lda RESULT_32BIT + 1
          sbc PARTY_XP_2,x
          lda RESULT_32BIT + 2
          sbc PARTY_XP_3,x
          bcs .NextLevelNotReached

          jsr LevelUp

          jsr DisplayFighterHP

          lda #6
          sta PARAM1
          lda PARAM10
          sta PARAM2

          ldy CURRENT_INDEX
          lda FIGHTER_LEVEL,y
          jsr Display2DigitDecimal

.NextLevelNotReached
.LevelMaxed

.XPSkipDeadFighter
          inc CURRENT_INDEX
          ldy CURRENT_INDEX
          cpy #4
          beq .XPDone
          jmp .XPNextFighter

.XPDone
          jmp AddXPLoop

.AddXPDone
          ;dropped items?
          ldx #4
          stx CURRENT_INDEX
--
          lda FIGHTER_TYPE,x
          beq .NoFighterHere

          tax
          lda ENEMY_DROP_ITEM,x
          cmp #ITEM_NONE
          beq .NoItemsFromThisEnemy

          lda #0
          ldy #100
          jsr GenerateRangedRandom
          cmp ENEMY_DROP_ITEM_CHANCE,x
          bcs .NoItemsFromThisEnemy

          ;yay, we get an item!
          lda ENEMY_DROP_ITEM,x
          jsr AddItemToInventory

          lda #<TEXT_YOU_FOUND
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_YOU_FOUND
          sta ZEROPAGE_POINTER_1 + 1
          lda #3
          sta PARAM1
          lda #17
          sta PARAM2
          jsr DisplayText

          ldy CURRENT_INDEX
          ldx FIGHTER_TYPE,y
          ldy ENEMY_DROP_ITEM,x

          lda ITEM_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda #13
          sta PARAM1
          jsr DisplayText

          jsr WaitForButton

          ldx #0
          lda #32
-
          sta SCREEN_CHAR + 17 * 40 + 3,x
          inx
          cpx #35
          bne -

          lda #3
          sta PARAM1

.NoItemsFromThisEnemy
.NoFighterHere
          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #NUM_FIGHTERS
          bne --

          jsr WaitForButton

          jsr GenerateRandomNumber
          and #$1f
          sta PARTY_STEPS_TO_AUTO_FIGHT

!ifdef MUSIC_ACTIVE {
          lda #0
          jsr MUSIC_PLAYER
}

          jmp RestoreMapAndBackToGame



!zone FinalMessage
FinalMessage
          sty CURRENT_TARGET

          lda #0
          sta VIC_SPRITE_ENABLE

          lda #0
          sta PARAM1
          lda #3
          sta PARAM2
          lda #40
          sta PARAM3
          lda #16
          sta PARAM4
          jsr DisplayBox

          ldy CURRENT_TARGET
          lda GAME_OVER_TYPE_TEXT_LO,y
          sta ZEROPAGE_POINTER_1
          lda GAME_OVER_TYPE_TEXT_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          lda #8
          sta PARAM1
          lda #10
          sta PARAM2
          jsr DisplayText

-
          jsr WaitFrame
          jsr JoyReleasedFirePushed
          bne -

          ldy CURRENT_TARGET
          cpy #1
          bne +

          ;game was won, reset stats
          jsr ResetGameStats
+
          ldy #0
          sty PARTY_MAP
          jmp Title



GAME_OVER_TYPE_TEXT_LO
          !byte <TEXT_YOU_LOST
          !byte <TEXT_YOU_WON_GAME
GAME_OVER_TYPE_TEXT_HI
          !byte >TEXT_YOU_LOST
          !byte >TEXT_YOU_WON_GAME


!zone FightLoop
FightLoop
          jsr WaitFrame

          jsr UpdateBattleTimerChars

          ;lost
          lda NUM_PLAYERS_ALIVE
          bne +

          ldy #0
          jmp FinalMessage
+
          ;fight complete already
          lda NUM_ENEMIES_ALIVE
          bne +
          ;TODO - delay
          jsr ClearEnemyNames
          jmp FightWon
+

          ;is any fighters turn?

          ldx #0
-
          lda FIGHTER_ACTIVE,x
          beq .NextFighter

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne .NextFighter

          ;speed pos >= 128 means turn
          lda FIGHTER_SPEED_POS,x
          cmp #200
          bcc .NextFighter

          ;this fighters turn!
          stx CURRENT_INDEX

          jsr UpdateBattleTimerChars

          lda #0
          ldx CURRENT_INDEX
          sta FIGHTER_SPEED_POS,x


          jmp HandleFighter


.NextFighter
          inx
          cpx #NUM_FIGHTERS
          bne -

          inc BATTLE_STATS_DELAY

          ;apply stats
          lda BATTLE_STATS_DELAY
          and #$3f
          bne .NoStatChanges

          ;stats
          ldx #0
          stx CURRENT_INDEX
.CheckFighterStats
          lda FIGHTER_ACTIVE,x
          beq .SkipStats

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne .SkipStats

          jsr ApplyFighterStats
.SkipStats
          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #NUM_FIGHTERS
          bne .CheckFighterStats


.NoStatChanges
          lda BATTLE_STATS_DELAY
          and #$07
          bne .NoSpeedUpdate

          ;no fighters turn, advance speed
          ldx #0
.AdvanceFighterSpeed
          lda FIGHTER_ACTIVE,x
          beq .SkipFighter

          lda FIGHTER_STATE,x
          and #STATUS_KO | STATUS_FROZEN
          bne .SkipFighter

          lda FIGHTER_SPEED,x
          tay
          lsr
          jsr GenerateRangedRandom
          clc
          adc FIGHTER_SPEED_POS,x
          sta FIGHTER_SPEED_POS,x

.SkipFighter
          inx
          cpx #NUM_FIGHTERS
          bne .AdvanceFighterSpeed

          jsr UpdateBattleTimerChars

.NoSpeedUpdate
          jmp FightLoop



!zone UpdateBattleTimerChars
UpdateBattleTimerChars
          ldx #0

.NextChar
          ;update fighter time pos
          lda FIGHTER_SPEED_POS,x
          lsr
          lsr
          lsr
          lsr
          lsr
          tay
          lda BIT_TABLE_FILLED,y
          sta LOCAL2

          txa
          asl
          asl
          asl
          tay

          lda LOCAL2
          sta BATTLE_TIMER_CHAR_LOCATION + 3,y
          sta BATTLE_TIMER_CHAR_LOCATION + 4,y

          inx
          cpx #4
          bne .NextChar

          rts


!zone ClearBattleTimerChars
ClearBattleTimerChars
          ldx #0
          txa
-
          sta BATTLE_TIMER_CHAR_LOCATION,x
          inx
          cpx #10 * 8
          bne -

          rts



!zone HandleFighter
HandleFighter
          jsr ClearTopPanel

          lda #1
          sta PARAM1
          sta PARAM2

          cpx #4
          bcc .PlayerFighter

          ;display enemy name
          ldy FIGHTER_ACTIVE,x
          lda ENEMY_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda ENEMY_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          ;blink enemy
          lda #5
          sta PARAM1
-
          jsr WaitFrame
          jsr WaitFrame
          jsr WaitFrame
          ldx CURRENT_INDEX
          ldy FIGHTER_ACTIVE,x
          sty PARAM3
          jsr HighlightEnemy

          jsr WaitFrame
          jsr WaitFrame
          jsr WaitFrame
          ldx CURRENT_INDEX
          ldy FIGHTER_ACTIVE,x
          sty PARAM3
          jsr DisplayEnemy

          dec PARAM1
          bne -

          jmp EnemyAI


.PlayerFighter
          ;display name
          lda PARTY_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda PARTY_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText


          lda FIGHTER_STATE,x
          and #STATUS_JUMPED
          beq .NotJumped

          dec FIGHTER_JUMP_COUNT,x
          beq .EndOfJump
          jmp FightLoop

.EndOfJump
          ;remove state
          lda #~STATUS_JUMPED
          and FIGHTER_STATE,x
          sta FIGHTER_STATE,x

          lda FIGHTER_JUMP_TARGET,x
          sta CURRENT_TARGET
          ldy #ATTACK_JUMP_END
          jsr PlayAttackAnimation
          jmp EndPlayerTurn

.NotJumped
          ;step forward
          lda #8
          sta PARAM1
          inx
          inx
-
          jsr MoveSpriteLeft

          dec PARAM1
          bne -

          dex
          dex
          dec FIGHTER_X,x

.PlayerBattleTurn
          ;battle menu
          ldx CURRENT_INDEX
          lda #<MENU_TEXT_FIGHT
          sta MENU_ENTRY_LO
          lda #>MENU_TEXT_FIGHT
          sta MENU_ENTRY_HI

          lda MENU_TEXT_SPECIALS_LO,x
          sta MENU_ENTRY_LO + 1
          lda MENU_TEXT_SPECIALS_HI,x
          sta MENU_ENTRY_HI + 1
          lda #<MENU_TEXT_MAGIC
          sta MENU_ENTRY_LO + 2
          lda #>MENU_TEXT_MAGIC
          sta MENU_ENTRY_HI + 2
          lda #<MENU_TEXT_ITEM
          sta MENU_ENTRY_LO + 3
          lda #>MENU_TEXT_ITEM
          sta MENU_ENTRY_HI + 3
          lda #4
          sta MENU_ITEM_COUNT
          sta MENU_ITEM_VISIBLE_COUNT

          jsr HandleMenu

          ;0 = fight, 1 = special, 2 = magic, 3 = item
          lda MENU_ITEM
          beq .ChooseTarget
          cmp #3
          beq .ChooseItem
          cmp #2
          beq .ChooseMagic

          ;special
          ldx CURRENT_INDEX
          cpx #0
          beq .Steal
          cpx #1
          beq .Tech
          cpx #2
          beq .Jump
          jmp ProcessMimic


.Steal
          jmp ProcessSteal

.Tech
          jmp ProcessTech

.Jump
          jmp ProcessJump



TARGET_SINGLE   = $00
TARGET_MULTIPLE = $01

ITEM_TO_USE
          !byte 0


.ChooseTarget
          ;choose any single target
          lda #( ITEM_USE_TARGET_SINGLE | ITEM_USE_TARGET_ENEMY )
          sta POTENTIAL_ATTACK_TARGET

          ;TODO - store previously targetted enemy index?

          ;start with enemies
          ldx #4
          jsr ChooseTarget
          jmp FightTarget

.ChooseMagic
          lda #ITEM_TYPE_MAGIC
          jmp .ProcessItemOrMagic

.ChooseItem
          lda #ITEM_TYPE_ITEM
.ProcessItemOrMagic
          jsr FillMenuWithItems
          jsr HandleMenu


          ;chose back
          ldy MENU_ITEM
          bne +
          jmp .PlayerBattleTurn
+

          ;no element per default
          lda #0
          sta ATTACK_ELEMENT

          ;use item depending on type (choose target or use on all)
          lda MENU_ITEM_VALUE,y
          sta ITEM_TO_USE

          tay
          lda ITEM_USE,y
          beq .NoUse
          and #ITEM_USE_TARGET_MASK
          sta POTENTIAL_ATTACK_TARGET

          ;items start with party (or try depending on type?)
          ldx #0

          lda ITEM_USE,y
          and #ITEM_USE_TARGET_ENEMY_FIRST
          beq .GoodItem

          ;choose enemy first
          ldx #4
.GoodItem
          jsr ChooseTarget

          ;remove item from inventory if not magic
          ldy ITEM_TO_USE
          lda ITEM_TYPE,y
          and #ITEM_TYPE_MAGIC
          bne .DoNotRemoveMagic
          lda ITEM_TO_USE
          jsr RemoveItemFromInventory
.DoNotRemoveMagic

          ;play item animation
          ldy ITEM_TO_USE
          lda ITEM_ANIMATION,y
          tay
          jsr PlayAttackAnimation

.NoUse
          jmp EndPlayerTurn



!zone ProcessSteal
ProcessSteal
          lda #( ITEM_USE_TARGET_ENEMY | ITEM_USE_TARGET_SINGLE )
          sta POTENTIAL_ATTACK_TARGET

          ;TODO - store previously targetted enemy index?

          ;start with enemies
          ldx #4
          jsr ChooseTarget

          ldy #ATTACK_STEAL
          jsr PlayAttackAnimation
          jmp EndPlayerTurn



!zone ProcessTech
ProcessTech
          jsr SetFirstMenuItemToBack

          ;fill menu with learned techs
          ldy #1
          lda #<TEXT_LEARN
          sta MENU_ENTRY_LO + 1
          lda #>TEXT_LEARN
          sta MENU_ENTRY_HI + 1
          lda #TECH_NONE
          sta MENU_ITEM_VALUE + 1

          lda #2
          sta MENU_ITEM_COUNT


          ldx #0
-
          lda TECH_LEARNED,x
          beq .NotLearned

          iny
          lda TECH_NAME_LO,x
          sta MENU_ENTRY_LO,y
          lda TECH_NAME_HI,x
          sta MENU_ENTRY_HI,y
          txa
          sta MENU_ITEM_VALUE,y
          inc MENU_ITEM_COUNT

.NotLearned
          inx
          cpx #NUM_TECHNICS
          bne -

          iny
          lda #0
          sta MENU_ENTRY_HI,y

          jsr HandleMenu

          ;chose back
          ldy MENU_ITEM
          bne +
          jmp HandleFighter.PlayerBattleTurn
+

          ldy MENU_ITEM
          lda MENU_ITEM_VALUE,y
          cmp #TECH_NONE
          bne .UseTech

          ;choose single target
          lda #( ITEM_USE_TARGET_ENEMY | ITEM_USE_TARGET_SINGLE )
          sta POTENTIAL_ATTACK_TARGET

          ;TODO - store previously targetted enemy index?

          ;start with enemies
          ldx #4
          jsr ChooseTarget

          ldy #ATTACK_STUDY
          jmp .PlayTechAnim

.UseTech
          tay

          lda #ATTACK_TARGET_ENEMY_GROUP
          sta ATTACK_TARGET

          ;start with first alive enemy
          ldx #4
-
          jsr CanSelectOrTargetFighter
          bne +
          inx
          bne -

+
          stx CURRENT_TARGET
          lda TECH_ANIMATION,y
          tay
.PlayTechAnim
          jsr PlayAttackAnimation
          jmp EndPlayerTurn



!zone ProcessJump
ProcessJump
          ;start with enemies
          lda #( ITEM_USE_TARGET_ENEMY | ITEM_USE_TARGET_SINGLE )
          sta POTENTIAL_ATTACK_TARGET
          ldx #4
          jsr ChooseTarget

          ;store for later
          lda CURRENT_TARGET
          ldx CURRENT_INDEX
          sta FIGHTER_JUMP_TARGET,x
          lda #3
          sta FIGHTER_JUMP_COUNT,x
          stx CURRENT_TARGET

          ldy #ATTACK_JUMP
          jsr PlayAttackAnimation
          jmp FightLoop



!zone ChoosePhysicalEnemy
ChoosePhysicalEnemy
          ldx #4
-
          jsr CanSelectOrTargetFighter
          bne .ValidTargetExists

          inx
          cpx #NUM_FIGHTERS
          bne -

          lda #$ff
          sta CURRENT_TARGET
          rts

.ValidTargetExists
.TryOtherPlayer
          lda #$04
          ldy #NUM_FIGHTERS - 1
          jsr GenerateRangedRandom

          tax
          jsr CanSelectOrTargetFighter
          beq .TryOtherPlayer

          stx CURRENT_TARGET
          rts



!zone ProcessMimic
ProcessMimic
          lda #( ITEM_USE_TARGET_ENEMY | ITEM_USE_TARGET_SINGLE )
          sta POTENTIAL_ATTACK_TARGET

          ;TODO - store previously targetted enemy index?

          ;start with enemies
          ldx #4
          jsr ChooseTarget

          ;"AI"
          ldx CURRENT_TARGET
          ldy FIGHTER_ACTIVE,x

          ;number of special attacks
          lda ENEMY_ATTACKS,y
          and #$7f
          beq .NoSpecialAttacks

          tay
          lda ENEMY_SPECIAL_ATTACK_LIST_LO,y
          sta ZEROPAGE_POINTER_1
          lda ENEMY_SPECIAL_ATTACK_LIST_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #0
.CheckNextSpecialAttack
          ;index
          lda (ZEROPAGE_POINTER_1),y
          sta CURRENT_SPECIAL_ATTACK

          ;chance
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta PARAM1
          and #$7f
          sty PARAM2
          jsr CheckChance
          beq .ChanceFailed

          ;this attack
          jsr ChoosePhysicalEnemy

          lda CURRENT_TARGET
          bmi .NoTarget

          lda #ATTACK_TARGET_SINGLE
          sta ATTACK_TARGET

          ldx CURRENT_INDEX
          ldy CURRENT_SPECIAL_ATTACK
          jsr PlayAttackAnimation
          jmp EndPlayerTurn
.NoTarget
          jmp FightTarget


.ChanceFailed
          ldy PARAM2
          lda PARAM1
          bmi .NoSpecialAttacks

          iny
          jmp .CheckNextSpecialAttack


.NoSpecialAttacks
          ;fall back to simple attack
          jmp FightTarget




!zone ChooseTarget
;x = start index
;set CURRENT_TARGET
ChooseTarget
          ;find next alive enemy
-
          lda FIGHTER_ACTIVE,x
          bne +
          inx
          cpx #NUM_FIGHTERS
          bne -

          ;should not happen!
          brk
+
          stx CURRENT_TARGET

          lda FIGHTER_X,x
          sta PARAM1
          dec PARAM1
          dec PARAM1

          lda FIGHTER_Y,x
          sta PARAM2
          dec PARAM2
          jsr SetMenuPointer

          ;are we targetting a group?
          lda #0
          sta POTENTIAL_TARGET_IS_GROUP
          lda POTENTIAL_ATTACK_TARGET
          and #( ITEM_USE_TARGET_GROUP | ITEM_USE_TARGET_SINGLE )
          cmp #ITEM_USE_TARGET_GROUP
          bne .CanTargetSingleTarget

          inc POTENTIAL_TARGET_IS_GROUP

.CanTargetSingleTarget
.TargetLoop
          jsr WaitFrame

          ;animate group
          lda POTENTIAL_TARGET_IS_GROUP
          beq .NoGroupSelected

          ldx CURRENT_TARGET
          cpx #4
          bcc .AnimatePlayerParty

-
          inx
          cpx #NUM_FIGHTERS
          bne +
          ldx #4
+
          lda FIGHTER_ACTIVE,x
          beq -

          lda FIGHTER_STATE,x
          and #STATUS_JUMPED | STATUS_KO
          bne -

          stx CURRENT_TARGET
          jsr .SubSetPointer
          jmp .AnimGroupSelectionDone


.AnimatePlayerParty
-
          inx
          cpx #4
          bne +
          ldx #0
+
          lda FIGHTER_ACTIVE,x
          beq -

          lda FIGHTER_STATE,x
          and #STATUS_JUMPED
          bne -

          stx CURRENT_TARGET
          jsr .SubSetPointer

.AnimGroupSelectionDone
.NoGroupSelected
          jsr JoyReleasedLeftPushed
          bne .NotLeft

          ldx CURRENT_TARGET
          cpx #4
          bcc .PartyIsSelected

          ;enemy (or group) is selected
          lda POTENTIAL_TARGET_IS_GROUP
          bne .CannotChooseLeft

          ;can enemy group be chosen?
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_GROUP
          beq .CannotChooseLeft

          ;set to group
          inc POTENTIAL_TARGET_IS_GROUP

          jmp .LeftDone

.PartyIsSelected
          lda POTENTIAL_TARGET_IS_GROUP
          beq .SinglePlayerIsTargetted

          ;whole party is selected
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_SINGLE
          beq .CannotChooseSinglePlayerOrEnemy

          dec POTENTIAL_TARGET_IS_GROUP
          jmp .LeftDone

.CannotChooseSinglePlayerOrEnemy
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_ENEMY
          ;cannot choose enemy group
          beq .LeftDone

          ;choose any enemy
          jsr ChooseFirstEnemy
          jmp .SetPointer

.SinglePlayerIsTargetted
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_ENEMY
          beq .LeftDone

          ;choose first active enemy
          jsr ChooseFirstEnemy
          jmp .SetPointer

.LeftDone
.CannotChooseLeft
.NotLeft
          jsr JoyReleasedRightPushed
          bne .NotRight

          ldx CURRENT_TARGET
          cpx #4
          bcc .PartyIsSelectedR

          ;enemy (or group) is selected
          lda POTENTIAL_TARGET_IS_GROUP
          beq .SingleEnemyIsSelected

          ;enemy group is selected
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_SINGLE
          beq .CannotSelectSingleTargetR

          ;single enemy target
          dec POTENTIAL_TARGET_IS_GROUP
          jmp .RightDone

.CannotSelectSingleTargetR
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_PARTY
          beq .CannotChooseRight

          ;select player party
          ldx #0
          stx CURRENT_TARGET
          jmp .SetPointer

.SingleEnemyIsSelected
          ;can change selection to player?
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_PARTY
          beq .CannotChooseRight

          ;select first player alive
          ldx #0
-
          lda FIGHTER_ACTIVE,x
          bne .SelectR

          inx
          cpx #4
          bne -
          jmp .CannotChooseRight

.SelectR
          stx CURRENT_INDEX
          jmp .SetPointer

.PartyIsSelectedR
          ;can whole party be selected?
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_PARTY
          beq .CannotChooseRight

          ;whole party is selected
          lda POTENTIAL_ATTACK_TARGET
          and #ITEM_USE_TARGET_SINGLE
          beq .CannotChooseRight

          inc POTENTIAL_TARGET_IS_GROUP
          jmp .RightDone

.RightDone
.CannotChooseRight
.NotRight

          jsr JoyReleasedUpPushed
          bne .NotUp

-
          lda CURRENT_TARGET
          bne +
          lda #NUM_FIGHTERS
          sta CURRENT_TARGET
+
          dec CURRENT_TARGET
          ldx CURRENT_TARGET
          lda FIGHTER_ACTIVE,x
          beq -

          lda FIGHTER_STATE,x
          and #STATUS_JUMPED
          bne -

          jmp .SetPointer

.NotUp
          jsr JoyReleasedDownPushed
          bne .NotDown

-
          inc CURRENT_TARGET
          lda CURRENT_TARGET
          cmp #NUM_FIGHTERS
          bne +
          lda #0
          sta CURRENT_TARGET
+
          ldx CURRENT_TARGET
          lda FIGHTER_ACTIVE,x
          beq -

          lda FIGHTER_STATE,x
          and #STATUS_JUMPED
          bne -

          jmp .SetPointer

.NotDown
          jsr JoyReleasedFirePushed
          bne .NotFire

          lda #ATTACK_TARGET_SINGLE
          sta ATTACK_TARGET

          lda POTENTIAL_TARGET_IS_GROUP
          beq +

          ;either party or enemies
          ldx CURRENT_TARGET
          cpx #4
          bcc .Party

          jsr ChooseFirstEnemy
          lda #ATTACK_TARGET_ENEMY_GROUP
          jmp ++
.Party
          ldx #0
          lda #ATTACK_TARGET_PARTY
++
          sta ATTACK_TARGET
          stx CURRENT_TARGET

+
          ;disable
          ldx #SPRITE_INDEX_POINTER
          jmp RemoveObject

.NotFire

          jmp .TargetLoop

.SetPointer
          jsr .SubSetPointer
          jmp .TargetLoop

.SubSetPointer
          lda FIGHTER_X,x
          sta PARAM1
          dec PARAM1
          dec PARAM1
          lda FIGHTER_Y,x
          sta PARAM2
          dec PARAM2
          jmp SetMenuPointer



!zone ChooseFirstEnemy
ChooseFirstEnemy
          ldx #4
-
          lda FIGHTER_ACTIVE,x
          beq +

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne +

          stx CURRENT_TARGET
          rts

+
          inx
          jmp -



;attacker = CURRENT_INDEX
;target = CURRENT_TARGET
!zone FightTarget
FightTarget
          ldx CURRENT_INDEX

          jsr AttackTarget
          jmp EndPlayerTurn



AttackTarget
          lda #ATTACK_TARGET_SINGLE
          sta ATTACK_TARGET
          lda #0
          sta ATTACK_ELEMENT

          ;TODO - depend on weapon equipped?
          ldy #ATTACK_SWORD
          jmp PlayAttackAnimation



;CURRENT_TARGET = target
!zone ApplyDamageToTarget
ApplyDamageToTarget
          ;apply damage to target
          ldx CURRENT_TARGET
          lda FIGHTER_HP_LO,x
          sec
          sbc ATTACK_DAMAGE
          sta FIGHTER_HP_LO,x
          lda FIGHTER_HP_HI,x
          sbc ATTACK_DAMAGE + 1
          sta FIGHTER_HP_HI,x
          bcc .FighterKilled

          ora FIGHTER_HP_LO,x
          beq .FighterKilled

          ;update HP display
          cpx #4
          bcs .NotAPlayer

          jsr DisplayFighterHP

.NotAPlayer
          rts

.FighterKilled
          ;remove fighter
          cpx #4
          bcs .RemoveEnemy

          ;player was killed
          lda #0
          sta FIGHTER_HP_LO,x
          sta FIGHTER_HP_HI,x
          jsr DisplayFighterHP

          ldx CURRENT_TARGET

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne .WasAlreadyKo

          dec NUM_PLAYERS_ALIVE

          ;this auto-clears other states which vanish when KOed
          lda #STATUS_KO
          sta FIGHTER_STATE,x
          ;lda #0
          ;sta FIGHTER_STATE_EX,x

.WasAlreadyKo
          ;set KO image
          lda #SPRITE_RIP
          sta SPRITE_POINTER_BASE + 2,x
          lda #15
          sta VIC_SPRITE_COLOR + 2,x

          rts

.RemoveEnemy
          ldx CURRENT_TARGET

          ldy FIGHTER_ACTIVE,x
          lda ENEMY_XP_LO,y
          clc
          adc FIGHT_XP_WON
          sta FIGHT_XP_WON
          lda FIGHT_XP_WON + 1
          adc ENEMY_XP_HI,y
          sta FIGHT_XP_WON + 1

          jsr ClearEnemy

          dec NUM_ENEMIES_ALIVE

          jmp DisplayEnemyNames


!if 0 {
!zone ApplyMPDamageToTarget
ApplyMPDamageToTarget
          ldx CURRENT_TARGET
          lda FIGHTER_MP_LO,x
          sec
          sbc ATTACK_DAMAGE
          sta FIGHTER_MP_LO,x
          lda FIGHTER_MP_HI,x
          sbc ATTACK_DAMAGE + 1
          sta FIGHTER_MP_HI,x
          bcc .MPNulled

          ora FIGHTER_MP_LO,x
          bne .UpdateDisplay

.MPNulled
          lda #0
          sta FIGHTER_MP_LO,x
          sta FIGHTER_MP_HI,x

.UpdateDisplay
          cpx #4
          bcs .NotAPlayer
          jsr DisplayFighterMP
.NotAPlayer
          rts
}


;display player health during fight
;x = index
!zone DisplayFighterHP
DisplayFighterHP
          cpx #4
          bcs .NoDisplay

          txa
          tay
          clc
          adc #20
          sta PARAM2

          lda FIGHTER_ACTIVE,x
          bne +
.NoDisplay
          rts

+
          lda #30
          sta PARAM1

          ldx FIGHTER_HP_LO,y
          lda FIGHTER_HP_HI,y
          jmp Display16BitDecimal



;display player health during fight
;x = index
!zone DisplayFighterMP
DisplayFighterMP
          cpx #4
          bcs .NoDisplay

          txa
          tay
          clc
          adc #20
          sta PARAM2

          lda FIGHTER_ACTIVE,x
          bne +

.NoDisplay
          rts

+

          lda #35
          sta PARAM1

          ldx FIGHTER_MP_LO,y
          lda FIGHTER_MP_HI,y
          jmp Display16BitDecimal



!zone EndPlayerTurn
EndPlayerTurn
          ;step back
          ldx CURRENT_INDEX
          inx
          inx

          lda #8
          sta PARAM1
-
          jsr MoveSpriteRight

          dec PARAM1
          bne -

          dex
          dex
          inc FIGHTER_X,x

          jmp FightLoop



;x,CURRENT_INDEX = attacker
;target = CURRENT_TARGET
;returns 0 if miss, 1 if hit
!zone CheckAttackHit
CheckAttackHit

!if 0 {
          ;Step 1. Clear

          ;If physical attack and the target has clear status, the attack always misses
          ;If magical attack and the target has clear status, the attack always hits.

          lda ATTACK_TYPE
          cmp #ATT_TYPE_PHYSICAL
          bne .MagicalAttack

          ldy CURRENT_TARGET
          lda FIGHTER_STATE_EX,y
          and #STATUS_EX_SHADOW
          beq .Step2

          ;always miss
          ;Step 4d. If physical attack, and target has Image status, then the attack always misses, and there is a 1 in 4 chance of removing the Image status.

          jsr GenerateRandomNumber
          and #$03
          beq +

          ;remove shadow state
          lda #STATUS_EX_SHADOW
          eor #$ff
          and FIGHTER_STATE_EX,y
          sta FIGHTER_STATE_EX,y

+
          jmp .Miss

.MagicalAttack
          ldy CURRENT_TARGET
          lda FIGHTER_STATE_EX,y
          and #STATUS_EX_SHADOW
          bne .Hit
.Step2
}
          ;Step 2. Death Protection
          ;If the target is protected from Wound status, and the attack misses death protected targets, then the attack always misses.
          ;TODO

          ;Step 3. Unblockable attacks
          ;If the spell is unblockable, then it always hits
          ;TODO - Attack stats

          ;Step 4. Check to hit for normal attacks

          ;TODO Attacks which can be blocked by Stamina skip this step, and instead use step 5.

          ;Step 4a. If target has Sleep, Petrify, Freeze, or Stop status, then the attack always hits.
          lda FIGHTER_STATE,y
          ;and #STATUS_SLEEPING | STATUS_PETRIFIED | STATUS_FROZEN
          and #STATUS_FROZEN
          bne .Hit

!if 0 {
          lda FIGHTER_STATE_EX,y
          and #STATUS_EX_STOP
          bne .Hit
}
          ;NODO Step 4b. If attack is physical and hits the back of the target, then it always hits.

          ;Step 4c. If attack has a perfect (255) hit rate, then the attack always hits.
          ;TODO - attack hit rate


          ;Step 4e. Chance to hit
          ;1. BlockValue = (255 - MBlock * 2) + 1

          lda ATTACK_TYPE
          cmp #ATT_TYPE_PHYSICAL
          bne .Magical

          lda FIGHTER_DEFENSE,y
          jmp +
.Magical
          lda FIGHTER_MAGIC_DEFENSE,y
+
          ;* 2
          ;asl
          sta LOCAL1

          ;255 -
          lda #255
          sec
          sbc LOCAL1
          sta LOCAL1

          ; + 1
          inc LOCAL1

          ;2. If BlockValue > 255 then BlockValue = 255
          bcc +
          lda #255
          sta LOCAL1
+
          ;If BlockValue < 1 then BlockValue = 1
          lda LOCAL1
          bne +
          lda #1
          sta LOCAL1
+

          ;3. If ((Hit Rate * BlockValue) / 256) > [0..99] then you hit; otherwise, you miss.
          sta OPERAND_8BIT_2

          jsr CalcFighterHitRate
          sta OPERAND_8BIT_1
          jsr Multiply8By8

          ;/ 256 > 0..99 ?
          lda OPERAND_16BIT_1 + 1
          cmp #80
          bcc .Miss




          ;NODO Step 5. Check to hit for attacks that can be blocked by Stamina
          ;Most attacks use step 4 instead of this step. Only Break, Doom, Demi, Quartr, X-Zone, W Wind, Shoat, Odin, Raiden, Antlion, Snare, X-Fer, andGrav Bomb use this step.

          ;Step 5a. Chance to hit
          ;1. BlockValue = (255 - MBlock * 2) + 1
          ;2. If BlockValue > 255 then BlockValue = 255
          ;If BlockValue < 1 then BlockValue = 1
          ;3. If ((Hit Rate * BlockValue) / 256) > [0..99] then you hit, otherwise you miss.
          ;Step 5b. Check if Stamina blocks
          ;If target's stamina >= [0..127] then the attack misses (even if it hit in step 5a); otherwise, the attack hits as long as it hit in step 5a.

          jmp .Hit


.Miss
          lda #0
          rts

.Hit
          lda #1
          rts



;uses fighter from x
;returns strength in A
!zone CalcFighterStrength
CalcFighterStrength
          lda FIGHTER_STRENGTH,x

          ldy FIGHTER_WEAPON,x
          clc
          adc ITEM_ATTACK_POWER,y

          ldy FIGHTER_ARMOUR,x
          clc
          adc ITEM_ATTACK_POWER,y

          ldy FIGHTER_RELIC,x
          clc
          adc ITEM_ATTACK_POWER,y
          rts



;uses fighter from x
;returns defense in A
!zone CalcFighterDefense
CalcFighterDefense
          lda FIGHTER_DEFENSE,x

          ldy FIGHTER_WEAPON,x
          clc
          adc ITEM_DEFENSE,y

          ldy FIGHTER_ARMOUR,x
          clc
          adc ITEM_DEFENSE,y

          ldy FIGHTER_RELIC,x
          clc
          adc ITEM_DEFENSE,y
          rts



!if 0 {
;uses fighter from x
;returns evasion in A
!zone CalcFighterEvasion
CalcFighterEvasion
          lda FIGHTER_EVASION,x

          ldy FIGHTER_WEAPON,x
          clc
          adc ITEM_EVASION,y

          ldy FIGHTER_ARMOUR,x
          clc
          adc ITEM_EVASION,y

          ldy FIGHTER_RELIC,x
          clc
          adc ITEM_EVASION,y
          rts
}



;uses fighter from x
;returns magic defense in A
!zone CalcFighterMagicDefense
CalcFighterMagicDefense
          lda FIGHTER_MAGIC_DEFENSE,x

          ldy FIGHTER_WEAPON,x
          clc
          adc ITEM_MAGIC_DEFENSE,y

          ldy FIGHTER_ARMOUR,x
          clc
          adc ITEM_MAGIC_DEFENSE,y

          ldy FIGHTER_RELIC,x
          clc
          adc ITEM_MAGIC_DEFENSE,y
          rts


;uses fighter from x
;returns hit rate in A
!zone CalcFighterHitRate
CalcFighterHitRate
          lda FIGHTER_HIT_RATE,x

          ldy FIGHTER_WEAPON,x
          clc
          adc ITEM_HIT_RATE,y

          ldy FIGHTER_ARMOUR,x
          cpy #ITEM_NOTHING
          beq +
          clc
          adc ITEM_HIT_RATE,y
+
          ldy FIGHTER_RELIC,x
          cpy #ITEM_NOTHING
          beq +
          clc
          adc ITEM_HIT_RATE,y
+
          rts




!if 0 {
;uses fighter from x
;returns immunity in A
!zone CalcFighterElementImmunity
CalcFighterElementImmunity
          lda FIGHTER_ELEMENT_IMMUNE,x

          ;ldy FIGHTER_WEAPON,x
          ;ora ITEM_ELEMENT_IMMUNE,y

          ;ldy FIGHTER_ARMOUR,x
          ;ora ITEM_ELEMENT_IMMUNE,y

          ;ldy FIGHTER_RELIC,x
          ;ora ITEM_ELEMENT_IMMUNE,y
          rts
}


!if 0 {
;uses fighter from x
;returns weakness in A
!zone CalcFighterElementWeakness
CalcFighterElementWeakness
          lda FIGHTER_ELEMENT_WEAK,x

          ;ldy FIGHTER_WEAPON,x
          ;ora ITEM_ELEMENT_WEAK,y

          ;ldy FIGHTER_ARMOUR,x
          ;ora ITEM_ELEMENT_WEAK,y

          ;ldy FIGHTER_RELIC,x
          ;ora ITEM_ELEMENT_WEAK,y
          rts
}


;uses fighter from x
;returns resistance in A
!zone CalcFighterElementResistance
CalcFighterElementResistance
          lda FIGHTER_ELEMENT_RESISTANT,x

          ldy FIGHTER_WEAPON,x
          ora ITEM_ELEMENT_RESISTANCE,y

          ldy FIGHTER_ARMOUR,x
          ora ITEM_ELEMENT_RESISTANCE,y

          ldy FIGHTER_RELIC,x
          ora ITEM_ELEMENT_RESISTANCE,y
          rts



!if 0 {
;uses fighter from x
;returns absorbance in A
!zone CalcFighterElementAbsorbance
CalcFighterElementAbsorbance
          lda FIGHTER_ELEMENT_ABSORB,x

          ;ldy FIGHTER_WEAPON,x
          ;ora ITEM_ELEMENT_ABSORB,y

          ;ldy FIGHTER_ARMOUR,x
          ;ora ITEM_ELEMENT_ABSORB,y

          ;ldy FIGHTER_RELIC,x
          ;ora ITEM_ELEMENT_ABSORB,y
          rts
}



;x = attacker
;target = CURRENT_TARGET
!zone CalcAttackDamage
BATTLE_POWER = PARAM4
CalcAttackDamage
          ldx CURRENT_INDEX
          lda #0
          sta TEMP_ATTACK
          sta TEMP_ATTACK + 1
          sta OPERAND_16BIT_2
          sta OPERAND_16BIT_2 + 1
          sta ATTACK_MISS

          ldy CURRENT_TARGET
          lda FIGHTER_ACTIVE,y
          bne +
          jmp .ZeroDamage
+
          lda FIGHTER_STATE,y
          and #STATUS_KO
          beq +
          jmp .ZeroDamage


          ;magical attacks have attack damage pre-set
          lda ATTACK_TYPE
          cmp #ATT_TYPE_MAGIC
          beq +
          lda #0
          sta ATTACK_DAMAGE
          sta ATTACK_DAMAGE + 1
+

          jsr CheckAttackHit
          bne .Hit

          ;miss !
          lda #$ff
          sta ATTACK_DAMAGE
          sta ATTACK_DAMAGE + 1
          lda #1
          sta ATTACK_MISS
          rts

.Hit
          lda ATTACK_TYPE
          cmp #ATT_TYPE_MAGIC
          bne .PhysAttack

          lda ATTACK_DAMAGE
          sta OPERAND_16BIT_2
          lda ATTACK_DAMAGE + 1
          sta OPERAND_16BIT_2 + 1

          ;* 4
          ;lda #4
          ;sta OPERAND_16BIT_1
          ;lda #0
          ;sta OPERAND_16BIT_1 + 1
          ;jsr Multiply16By16

          ;lda RESULT_32BIT + 1
          ;sta OPERAND_16BIT_2 + 1
          ;lda RESULT_32BIT
          ;sta OPERAND_16BIT_2

          ldx CURRENT_INDEX
          jmp .MagicBattle

.PhysAttack
          ;Step 1a. Vigor2 = Vigor * 2
          ;If Vigor >= 128 then Vigor2 = 255 instead
          ldx CURRENT_INDEX
          jsr CalcFighterStrength
          asl
          bpl +
          lda #255
+
          sta BATTLE_POWER

          ldx CURRENT_INDEX

          cpx #4
          bcc .APlayer

          ;attacker is a monster
          ;Step 1a. Damage = Level * Level * (Battle Power * 4 + Vigor) / 256
          ;Note that vigor for each monster is randomly determined at the beginning of the battle as [56..63]


          ;Battle Power * 4
          lda FIGHTER_ATTACK,x
          sta OPERAND_8BIT_1
          lda #4
          sta OPERAND_8BIT_2
          jsr Multiply8By8

          ;+ Vigor
          ldx CURRENT_INDEX
          lda FIGHTER_STRENGTH,x
          clc
          adc OPERAND_16BIT_1
          sta OPERAND_16BIT_2
          bcc +
          inc OPERAND_16BIT_2 + 1
+
          ;level * level
          ldx CURRENT_INDEX
          lda FIGHTER_LEVEL,x
          sta OPERAND_8BIT_1
          sta OPERAND_8BIT_2
          jsr Multiply8By8

          ;Level * Level * (Battle Power * 4 + Vigor)
          jsr Multiply16By16

          ;/ 256
          lda RESULT_32BIT + 1
          sta ATTACK_DAMAGE
          lda RESULT_32BIT + 2
          sta ATTACK_DAMAGE + 1
          jmp .ProcessMultipliers

.APlayer

          ;Step 1b. Attack = Battle Power + Vigor2
          lda BATTLE_POWER
          clc
          adc FIGHTER_ATTACK,x
          sta OPERAND_16BIT_2
          bcc +
          inc OPERAND_16BIT_2 + 1
+

          ;Step 1c. If equipped with Gauntlet, Attack = Attack + Battle Power * 3 / 4

          ;Step 1d. Damage = Battle Power + ((Level * Level * Attack) / 256) * 3 / 2

.MagicBattle
          ;level * level
          lda FIGHTER_LEVEL,x
          sta OPERAND_8BIT_1
          sta OPERAND_8BIT_2
          jsr Multiply8By8

          ;* attack (stored previously)
          jsr Multiply16By16

          ; / 256
          lda RESULT_32BIT + 1
          sta OPERAND_16BIT_1
          lda RESULT_32BIT + 2
          sta OPERAND_16BIT_1 + 1

          ;* 3
          lda #3
          sta OPERAND_16BIT_2
          lda #0
          sta OPERAND_16BIT_2 + 1
          jsr Multiply16By16

          ;/ 2
          lsr RESULT_32BIT + 1
          ror RESULT_32BIT

          ;+Battle Power
          lda BATTLE_POWER
          clc
          adc RESULT_32BIT
          sta ATTACK_DAMAGE
          bcc +
          inc RESULT_32BIT + 1
+
          lda RESULT_32BIT + 1
          sta ATTACK_DAMAGE + 1

          ;Step 1e. If character is equipped with an Offering:
          ;Damage = Damage / 2

          ;Step 1f. If the attack is a standard fight attack and the character is equipped with a Genji Glove, but only one or zero weapons:
          ;Damage = ceil(Damage * 3 / 4)


.ProcessMultipliers
          ;For physical attacks made by monsters:

          ;Step 5. Damage Multipliers #1

          ;The damage multiplier starts out = 0.
          lda #0
          sta OPERAND_8BIT_2

          ;The following add to the damage multiplier:
          ;Morph (attacker) - If Attacker has morph status add 2 to damage multiplier
          ;Berserk - If physical attack and attacker has berserk status add 1 to damage multiplier
          ;Critical hit - Standard attacks have a 1 in 32 chance of being a critical hit. If the attack is a critical hit add 2 to damage multiplier
          jsr GenerateRandomNumber
          and #$1f
          bne .NoCritical
          inc OPERAND_8BIT_2
          inc OPERAND_8BIT_2
.NoCritical


          ;Step 5a. Damage = Damage + ((Damage / 2) * damage multiplier)
          lda OPERAND_8BIT_2
          beq .NoMultiplier1

          sta OPERAND_16BIT_1
          lda #0
          sta OPERAND_16BIT_1 + 1


          lda ATTACK_DAMAGE
          sta OPERAND_16BIT_2
          lda ATTACK_DAMAGE + 1
          sta OPERAND_16BIT_2 + 1

          ;/ 2
          lsr OPERAND_16BIT_2 + 1
          ror OPERAND_16BIT_2

          ;* damage multiplier
          jsr Multiply16By16

          ;+ damage
          lda ATTACK_DAMAGE
          clc
          adc RESULT_32BIT
          sta ATTACK_DAMAGE
          lda ATTACK_DAMAGE + 1
          adc RESULT_32BIT + 1
          sta ATTACK_DAMAGE + 1


.NoMultiplier1

          ;Step 6. Damage modification

          ;Step 6a. Random Variance
          ;Damage = (Damage * [224..255] / 256) + 1
          lda ATTACK_DAMAGE
          sta OPERAND_16BIT_2
          lda ATTACK_DAMAGE + 1
          sta OPERAND_16BIT_2 + 1

          ;[224..255]
          lda #224
          ldy #255
          jsr GenerateRangedRandom
          sta OPERAND_16BIT_1
          lda #0
          sta OPERAND_16BIT_1 + 1

          ;* damage
          jsr Multiply16By16

          ; / 256 + 1
          lda RESULT_32BIT + 1
          clc
          adc #1
          sta ATTACK_DAMAGE
          lda RESULT_32BIT + 2
          adc #0
          sta ATTACK_DAMAGE + 1

          ;Step 6b. Defense modification
          ;Damage = (Damage * (255 - Defense) / 256) + 1
          ;Magical attacks use Magic defense instead of defense

          lda ATTACK_TYPE
          cmp #ATT_TYPE_MAGIC
          bne .PhysicalAttack

          ldx CURRENT_TARGET
          jsr CalcFighterMagicDefense
          sta LOCAL1

          jmp .CalcDefense


.PhysicalAttack
          ldx CURRENT_TARGET
          jsr CalcFighterDefense
          sta LOCAL1

.CalcDefense
          lda #255
          sec
          sbc LOCAL1
          sta OPERAND_16BIT_1
          lda #0
          sta OPERAND_16BIT_1 + 1

          ;* Damage
          lda ATTACK_DAMAGE
          sta OPERAND_16BIT_2
          lda ATTACK_DAMAGE + 1
          sta OPERAND_16BIT_2 + 1

          jsr Multiply16By16

          ;/256
          lda RESULT_32BIT + 1
          sta OPERAND_16BIT_1
          lda RESULT_32BIT + 2
          sta OPERAND_16BIT_1 + 1

          ; + 1
          lda OPERAND_16BIT_1
          clc
          adc #1
          sta ATTACK_DAMAGE
          lda OPERAND_16BIT_1 + 1
          adc #0
          sta ATTACK_DAMAGE + 1

!if 0 {
          ;Step 6c. Safe / Shell
          ;If magical attack and target has shell status, or physical attack and target has safe status:
          lda #STATUS_EX_PROTECT
          sta LOCAL1

          lda ATTACK_TYPE
          cmp #ATT_TYPE_PHYSICAL
          beq +

          lda #STATUS_EX_SHELL
          sta LOCAL1
+
          ;shell or protect
          ldx CURRENT_TARGET
          lda FIGHTER_STATE,x
          and LOCAL1
          beq .TargetIsProtected

          ;Damage = (Damage * 170 / 256) + 1
          lda #170
          sta OPERAND_16BIT_1
          lda #0
          sta OPERAND_16BIT_1 + 1

          ;* Damage
          lda ATTACK_DAMAGE
          sta OPERAND_16BIT_2
          lda ATTACK_DAMAGE + 1
          sta OPERAND_16BIT_2 + 1

          jsr Multiply16By16

          ;/256
          lda RESULT_32BIT + 1
          sta OPERAND_16BIT_1
          lda RESULT_32BIT + 2
          sta OPERAND_16BIT_1 + 1

          ; + 1
          lda OPERAND_16BIT_1
          clc
          adc #1
          sta ATTACK_DAMAGE
          lda OPERAND_16BIT_1 + 1
          adc #0
          sta ATTACK_DAMAGE + 1

.TargetIsProtected
}
          ;half if group is selected
          lda ATTACK_TARGET
          and #ATTACK_TARGET_ENEMY_GROUP | ATTACK_TARGET_PARTY
          beq .NoGroupTargetted

          ;/2
          lsr ATTACK_DAMAGE + 1
          ror ATTACK_DAMAGE


.NoGroupTargetted

          ;Step 6d. Target Defending
          ;If physical attack and target is Defending:
          ;Damage = Damage / 2

          ;Step 6e. Target's row
          ;If physical attack and target is in back row:
          ;Damage = Damage / 2

          ;Step 6f. Morph (target)
          ;If magical attack and target has morph status:
          ;Damage = Damage / 2


          ;Step 6g. Self Damage
          ;If the attacker and target are both characters:
          ;Damage = Damage / 2

          ;Healing attacks skip this step
          lda ATTACK_DAMAGE_TYPE
          cmp #ADT_HEAL_HP
          beq .SkipHalf

          lda ATTACK_DAMAGE_TYPE
          cmp #ADT_HEAL_MP
          beq .SkipHalf

          lda CURRENT_INDEX
          cmp #4
          bcs .NotAPlayer

          lda CURRENT_TARGET
          cmp #4
          bcc .NotAPlayer

          ;a player char hits a player char
          ;/2
          lsr ATTACK_DAMAGE + 1
          ror ATTACK_DAMAGE

.NotAPlayer
.SkipHalf

          ;skip step 7 (damage * 2 if hit in back)
          jmp .NotPetrified

!if 0 {
          ;Step 8. Petrify damage
          ;If the target has petrify status, then damage is set to 0.
          ldx CURRENT_TARGET
          lda FIGHTER_STATE,x
          and #STATUS_PETRIFIED
          beq .NotPetrified
}
.ZeroDamage
          lda #0
          sta ATTACK_DAMAGE
          sta ATTACK_DAMAGE + 1
          rts

.NotPetrified
          lda ATTACK_ELEMENT
          beq .NoElement

          ;Step 9. Elemental resistance
          ;For each step, if the condition is met, no further steps are checked. So for example, if the target absorbs the element, then steps 9c to 9e are not checked.

          ;Step 9a. If the element has been nullified (by Force Field), then: Damage = 0.
          ;TODO ?

          ;ldx CURRENT_TARGET
          ;lda FIGHTER_ELEMENT_NULLIFY,x
          ;and ATTACK_ELEMENT
          ;bne .ZeroDamage

          ;Step 9b. If target absorbs the element of the attack, then damage is unchanged, but it heals HP instead of dealing damage.
          ldx CURRENT_TARGET
          ;jsr CalcFighterElementAbsorbance
          lda FIGHTER_ELEMENT_ABSORB,x
          and ATTACK_ELEMENT
          beq .NoAbsorb

          ;heal instead of damage
          lda ATTACK_DAMAGE_TYPE
          ora #$01
          sta ATTACK_DAMAGE_TYPE
          rts

          ;Step 9c. If target is immune to the element of the attack: Damage = 0
.NoAbsorb
          ldx CURRENT_TARGET
          ;jsr CalcFighterElementImmunity
          lda FIGHTER_ELEMENT_IMMUNE,x
          and ATTACK_ELEMENT
          bne .ZeroDamage

          ;Step 9d. If target is resistant to the element of the attack: Damage = Damage / 2
          ldx CURRENT_TARGET
          jsr CalcFighterElementResistance
          and ATTACK_ELEMENT
          beq .NotResistant

          ;half damage
          lsr ATTACK_DAMAGE + 1
          ror ATTACK_DAMAGE

          jmp .CapDamage

.NotResistant
          ;Step 9e. If target is weak to the element of the attack: Damage = Damage * 2
          ldx CURRENT_TARGET
          ;jsr CalcFighterElementWeakness
          lda FIGHTER_ELEMENT_WEAK,x
          and ATTACK_ELEMENT
          beq .NotWeak

          ;double damage
          asl ATTACK_DAMAGE
          rol ATTACK_DAMAGE + 1
          jmp .CapDamage

.NotWeak
.NoElement
.CapDamage

          lda ATTACK_DAMAGE
          sec
          sbc #<9999
          lda ATTACK_DAMAGE + 1
          sbc #>9999
          bcc .NotMaxed

          lda #<9999
          sta ATTACK_DAMAGE
          lda #>9999
          sta ATTACK_DAMAGE + 1

.NotMaxed
          rts


;multiplies OPERAND_8BIT_1 with OPERAND_8BIT_2, stores in OPERAND_16BIT_1 (OPERAND_16BIT_1_1 and OPERAND_16BIT_1_2)

!zone Multiply8By8
Multiply8By8
          lda #$00
          tay
          sty LOCAL1   ; remove this line for 16*8=16bit multiply
          beq .enterLoop

.doAdd
          clc
          adc OPERAND_8BIT_1
          tax

          tya
          adc LOCAL1
          tay
          txa

.loop
          asl OPERAND_8BIT_1
          rol LOCAL1
.enterLoop  ; accumulating multiply entry point (enter with .A=lo, .Y=hi)
          lsr OPERAND_8BIT_2
          bcs .doAdd
          bne .loop

          sta OPERAND_16BIT_1_1
          sty OPERAND_16BIT_1_2
          rts


;multiplies OPERAND_16BIT_1 with OPERAND_16BIT_2, stores in RESULT_32BIT_1

!zone Multiply16By16
Multiply16By16
          lda #$00
          ; clear upper bits of product
          sta RESULT_32BIT + 2
          sta RESULT_32BIT + 3

          ; set binary count to 16
          ldx #$10
.shift_r
          lsr OPERAND_16BIT_2 + 1 ; divide multiplier by 2
          ror OPERAND_16BIT_2
          bcc .rotate_r
          lda RESULT_32BIT + 2 ; get upper half of product and add multiplicand
          clc
          adc OPERAND_16BIT_1
          sta RESULT_32BIT + 2
          lda RESULT_32BIT + 3
          adc OPERAND_16BIT_1 + 1
.rotate_r
          ; rotate partial product
          ror
          sta RESULT_32BIT + 3
          ror RESULT_32BIT + 2
          ror RESULT_32BIT + 1
          ror RESULT_32BIT
          dex
          bne .shift_r
          rts




;converts a decimal (in OPERAND_16BIT_1)
!zone ConvertTo2DigitDecimal
ConvertTo2DigitDecimal
          sta LOCAL1

          lda #0
          sta OPERAND_16BIT_1
          sta OPERAND_16BIT_1 + 1

          lda LOCAL1
          beq .Done

          ldx #0

-
          lda LOCAL1
          sec
          sbc #10
          bcc .TooFar
          sta LOCAL1
          inx
          jmp -


.TooFar
          stx OPERAND_16BIT_1
          lda LOCAL1
          sta OPERAND_16BIT_1 + 1
.Done
          rts



;converts x (lo) and a(hi) to decimal (in RESULT_32BIT)
!zone Convert16BitToDecimal
Convert16BitToDecimal
          stx OPERAND_16BIT_2
          sta OPERAND_16BIT_2 + 1

          lda #0
          sta RESULT_32BIT
          sta RESULT_32BIT + 1
          sta RESULT_32BIT + 2
          sta RESULT_32BIT + 3

          lda OPERAND_16BIT_2
          ora OPERAND_16BIT_2 + 1
          bne .NotZero

          rts

.NotZero
          ;first digit
.FirstDigit
          inc RESULT_32BIT

          lda OPERAND_16BIT_2
          sec
          sbc #<1000
          sta OPERAND_16BIT_2

          lda OPERAND_16BIT_2 + 1
          sbc #>1000
          bcc .OneTooFar
          sta OPERAND_16BIT_2 + 1
          jmp .FirstDigit


.OneTooFar
          dec RESULT_32BIT
          lda OPERAND_16BIT_2
          adc #<1000
          sta OPERAND_16BIT_2

.SecondDigit
          ;second digit
          inc RESULT_32BIT + 1

          lda OPERAND_16BIT_2
          sec
          sbc #<100
          sta OPERAND_16BIT_2

          lda OPERAND_16BIT_2 + 1
          sbc #>100
          bcc .OneTooFar2
          sta OPERAND_16BIT_2 + 1

          jmp .SecondDigit


.OneTooFar2
          dec RESULT_32BIT + 1
          lda OPERAND_16BIT_2
          adc #<100
          sta OPERAND_16BIT_2

.ThirdDigit
          ;third digit
          inc RESULT_32BIT + 2

          lda OPERAND_16BIT_2
          sec
          sbc #<10
          sta OPERAND_16BIT_2

          lda OPERAND_16BIT_2 + 1
          sbc #>10
          bcc .OneTooFar3
          sta OPERAND_16BIT_2 + 1
          jmp .ThirdDigit


.OneTooFar3
          dec RESULT_32BIT + 2
          lda OPERAND_16BIT_2
          adc #<10
          sta OPERAND_16BIT_2

          ;4th digit
          lda OPERAND_16BIT_2
          sta RESULT_32BIT + 3
          rts



;converts x (lo), y(med) and a(hi) to decimal (in RESULT_64BIT)
!zone Convert24BitToDecimal
Convert24BitToDecimal
          stx RESULT_32BIT
          sty RESULT_32BIT + 1
          sta RESULT_32BIT + 2

          lda #0
          sta RESULT_64BIT
          sta RESULT_64BIT + 1
          sta RESULT_64BIT + 2
          sta RESULT_64BIT + 3
          sta RESULT_64BIT + 4
          sta RESULT_64BIT + 5
          sta RESULT_64BIT + 6
          sta RESULT_64BIT + 7

          lda RESULT_32BIT
          ora RESULT_32BIT + 1
          ora RESULT_32BIT + 2
          ora RESULT_32BIT + 3
          bne .NotZero

          rts

          ;100000 = $0186A0
.NotZero
          ;first digit
.FirstDigit
          inc RESULT_64BIT

          lda RESULT_32BIT
          sec
          sbc #$a0
          sta RESULT_32BIT

          lda RESULT_32BIT + 1
          sbc #$86
          sta RESULT_32BIT + 1

          lda RESULT_32BIT + 2
          sbc #$01
          bcc .OneTooFar
          sta RESULT_32BIT + 2
          jmp .FirstDigit


.OneTooFar
          dec RESULT_64BIT

          ;re-add 100000
          lda RESULT_32BIT
          clc
          adc #$a0
          sta RESULT_32BIT
          lda RESULT_32BIT + 1
          adc #$86
          sta RESULT_32BIT + 1
          lda RESULT_32BIT + 2
          adc #$01
          sta RESULT_32BIT + 2

.SecondDigit
          ;second digit
          inc RESULT_64BIT + 1

          lda RESULT_32BIT
          sec
          sbc #<10000
          sta RESULT_32BIT

          lda RESULT_32BIT + 1
          sbc #>10000
          bcc .OneTooFar2
          sta RESULT_32BIT + 1
          jmp .SecondDigit


.OneTooFar2
          dec RESULT_64BIT + 1
          lda RESULT_32BIT
          adc #<10000
          sta RESULT_32BIT

.SecondDigitB
          ;second digit
          inc RESULT_64BIT + 2

          lda RESULT_32BIT
          sec
          sbc #<1000
          sta RESULT_32BIT

          lda RESULT_32BIT + 1
          sbc #>1000
          bcc .OneTooFar2B
          sta RESULT_32BIT + 1
          jmp .SecondDigitB


.OneTooFar2B
          dec RESULT_64BIT + 2
          lda RESULT_32BIT
          adc #<1000
          sta RESULT_32BIT

.ThirdDigit
          ;third digit
          inc RESULT_64BIT + 3

          lda RESULT_32BIT
          sec
          sbc #<100
          sta RESULT_32BIT

          lda RESULT_32BIT + 1
          sbc #>100
          bcc .OneTooFar3
          sta RESULT_32BIT + 1

          jmp .ThirdDigit


.OneTooFar3
          dec RESULT_64BIT + 3
          lda RESULT_32BIT
          adc #<100
          sta RESULT_32BIT

.FourthDigit
          ;4th digit
          inc RESULT_64BIT + 4

          lda RESULT_32BIT
          sec
          sbc #<10
          sta RESULT_32BIT

          lda RESULT_32BIT + 1
          sbc #>10
          bcc .OneTooFar4
          sta RESULT_32BIT + 1
          jmp .FourthDigit


.OneTooFar4
          dec RESULT_64BIT + 4
          lda RESULT_32BIT
          adc #<10
          sta RESULT_32BIT

          ;5th digit
          lda RESULT_32BIT
          sta RESULT_64BIT + 5
          rts



;x = lo
;a = hi
;y = color
;PARAM1 = x
;PARAM2 = y

!zone Display16BitDecimal
DUMMY2
          !byte 0
Display16BitDecimal
          ldy #1
Display16BitDecimalWithColorInY
          sty DUMMY2
          jsr Convert16BitToDecimal

          ldy PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta .DisplayPos
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta .DisplayPos + 1

          lda PARAM1
          clc
          adc .DisplayPos
          sta .DisplayPos
          sta .DisplayPos2
          sta .DisplayColorPos
          lda .DisplayPos + 1
          adc #0
          sta .DisplayPos + 1
          sta .DisplayPos2 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta .DisplayColorPos + 1

          ldy #0
-
          lda RESULT_32BIT,y
          bne +

          lda #32
.DisplayPos2 = * + 1
          sta $8000,y
          iny
          cpy #3
          bne -

+

-
          lda RESULT_32BIT,y
          clc
          adc #33

.DisplayPos = * + 1
          sta $8000,y

          lda DUMMY2
.DisplayColorPos = * + 1
          sta $8000,y

          iny
          cpy #4
          bne -
          rts



;x = lo
;y = med
;a = hi
;PARAM1 = x
;PARAM2 = y

!zone Display24BitDecimal
Display24BitDecimal
          jsr Convert24BitToDecimal

          ldy PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta .DisplayPos
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta .DisplayPos + 1

          lda PARAM1
          clc
          adc .DisplayPos
          sta .DisplayPos
          sta .DisplayPos2
          sta .DisplayColorPos
          lda .DisplayPos + 1
          adc #0
          sta .DisplayPos + 1
          sta .DisplayPos2 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta .DisplayColorPos + 1

          ldy #0
-
          lda RESULT_64BIT,y
          bne +

          lda #32
.DisplayPos2 = * + 1
          sta $8000,y
          iny
          cpy #5
          bne -

+

-
          lda RESULT_64BIT,y
          clc
          adc #33

.DisplayPos = * + 1
          sta $8000,y

          lda #1
.DisplayColorPos = * + 1
          sta $8000,y

          iny
          cpy #6
          bne -
          rts




;a = value
;PARAM1 = x
;PARAM2 = y

!zone Display2DigitDecimal
Display2DigitDecimal
          jsr ConvertTo2DigitDecimal

          ldy PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta .DisplayPos
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta .DisplayPos + 1

          lda PARAM1
          clc
          adc .DisplayPos
          sta .DisplayPos
          sta .DisplayColorPos
          lda .DisplayPos + 1
          adc #0
          sta .DisplayPos + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta .DisplayColorPos + 1

          ldy #0
          lda OPERAND_16BIT_1
          bne +
          iny
+

-
          lda OPERAND_16BIT_1,y
          clc
          adc #33

.DisplayPos = * + 1
          sta $8000,y

          lda #1
.DisplayColorPos = * + 1
          sta $8000,y

          iny
          cpy #2
          bne -
          rts


;set pointer at x = PARAM1, y = PARAM2
!zone SetMenuPointer
SetMenuPointer
          lda #TYPE_MENU_POINTER
          sta PARAM3
          ldx #SPRITE_INDEX_POINTER
          jsr DoSpawnObject
          lda VIC_SPRITE_Y_POS + SPRITE_INDEX_POINTER * 2
          clc
          adc #13
          sta VIC_SPRITE_Y_POS + SPRITE_INDEX_POINTER * 2
          jsr MoveSpriteLeft
          jsr MoveSpriteLeft
          jmp MoveSpriteLeft


;index in X
;returns 1 if can select, 0 if not
!zone CanSelectOrTargetFighter
CanSelectOrTargetFighter
          lda FIGHTER_ACTIVE,x
          beq .Cannot

          lda FIGHTER_STATE,x
          and #STATUS_KO | STATUS_JUMPED
          beq .CanSelect


          lda #0
.Cannot
          rts

.CanSelect
          lda #1
          rts



NUM_FIGHTERS = 10
FIGHTER_WEAPON
          !fill NUM_FIGHTERS, ITEM_NOTHING
FIGHTER_ARMOUR
          !fill NUM_FIGHTERS, ITEM_NOTHING
FIGHTER_RELIC
          !fill NUM_FIGHTERS, ITEM_NOTHING


;FIGHTER_ACTIVE
;          !fill NUM_FIGHTERS, 0
FIGHTER_TYPE
          !fill NUM_FIGHTERS, 0
FIGHTER_HP_LO
          !fill NUM_FIGHTERS, 0
FIGHTER_HP_HI
          !fill NUM_FIGHTERS, 0
FIGHTER_HP_MAX_LO
          !fill NUM_FIGHTERS, 0
FIGHTER_HP_MAX_HI
          !fill NUM_FIGHTERS, 0
FIGHTER_MP_LO
          !fill NUM_FIGHTERS, 0
FIGHTER_MP_HI
          !fill NUM_FIGHTERS, 0
FIGHTER_MP_MAX_LO
          !fill NUM_FIGHTERS, 0
FIGHTER_MP_MAX_HI
          !fill NUM_FIGHTERS, 0
FIGHTER_SPEED
          !fill NUM_FIGHTERS, 0
FIGHTER_SPEED_POS
          !fill NUM_FIGHTERS, 0
FIGHTER_LEVEL
          !fill NUM_FIGHTERS, 0
FIGHTER_STATE
          !fill NUM_FIGHTERS, 0
;FIGHTER_STATE_EX
;          !fill NUM_FIGHTERS, 0
FIGHTER_MAGIC_DEFENSE
          !fill NUM_FIGHTERS, 0
FIGHTER_HIT_RATE
          !fill NUM_FIGHTERS, 0
FIGHTER_X
          !fill NUM_FIGHTERS, 0
FIGHTER_Y
          !fill NUM_FIGHTERS, 0
FIGHTER_WIDTH
          !fill NUM_FIGHTERS, 0
FIGHTER_HEIGHT
          !fill NUM_FIGHTERS, 0
;index to first character
FIGHTER_CHARS
          !fill NUM_FIGHTERS, 0

FIGHTER_ATTACK
          !fill NUM_FIGHTERS, 0
FIGHTER_STRENGTH
          !fill NUM_FIGHTERS, 0
FIGHTER_DEFENSE
          !fill NUM_FIGHTERS, 0
FIGHTER_EVASION
          !fill NUM_FIGHTERS, 0
FIGHTER_MAGIC_EVASION
          !fill NUM_FIGHTERS, 0
FIGHTER_ELEMENT_ABSORB
          !fill NUM_FIGHTERS, 0
FIGHTER_ELEMENT_IMMUNE
          !fill NUM_FIGHTERS, 0
FIGHTER_ELEMENT_RESISTANT
          !fill NUM_FIGHTERS, 0
FIGHTER_ELEMENT_WEAK
          !fill NUM_FIGHTERS, 0
FIGHTER_FROZEN_COUNT
          !fill NUM_FIGHTERS, 0
FIGHTER_JUMP_COUNT
          !fill NUM_FIGHTERS, 0
FIGHTER_JUMP_TARGET
          !fill NUM_FIGHTERS, 0

NUM_PLAYERS_ALIVE
          !byte 0

NUM_ENEMIES_ALIVE
          !byte 0


;CURRENT_TARGET
;          !byte 0

FIGHT_XP_WON
          !word 0

OPERAND_8BIT_1
          !byte 0
OPERAND_8BIT_2
          !byte 0

OPERAND_16BIT_1
OPERAND_16BIT_1_1
          !byte 0
OPERAND_16BIT_1_2
          !byte 0

OPERAND_16BIT_2
OPERAND_16BIT_2_1
          !byte 0
OPERAND_16BIT_2_2
          !byte 0


ATT_TYPE_PHYSICAL = 0
ATT_TYPE_MAGIC = 1
ATTACK_TYPE
          !byte 0

RESULT_32BIT
          !byte 0,0,0,0

RESULT_64BIT
          !byte 0,0,0,0
          !byte 0,0,0,0

;ATTACK_DAMAGE
;          !word 0
;          !byte 0

POTENTIAL_ATTACK_TARGET
          !byte 0
POTENTIAL_TARGET_IS_GROUP
          !byte 0

TEMP_ATTACK
          !word 0
ATTACK_MISS
          !byte 0

ADT_HURT_HP = 0
ADT_HEAL_HP = 1
ADT_HURT_MP = 2
ADT_HEAL_MP = 3
ADT_MAGIC   = $80

;ADT_HURT_HP = 0
;ADT_HEAL_HP = 1
;ADT_HURT_MP = 2
;ADT_HEAL_MP = 3
ATTACK_DAMAGE_TYPE
          !byte 0

ATTACK_ELEMENT
          !byte 0
BATTLE_STATS_DELAY
          !byte 0

CURRENT_FORMATION
          !byte 0

BATTLE_MULTI_COLOR_1
          !byte 0;8
BATTLE_MULTI_COLOR_2
          !byte 0;11

