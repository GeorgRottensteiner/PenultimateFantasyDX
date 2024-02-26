;FORMATION_GREEN_SLIME   = 0
;FORMATION_GREEN_SLIMES  = 1
;FORMATION_BLUE_SLIME    = 2
;FORMATION_SLIMES        = 3
;FORMATION_SPECTRE       = 4
;FORMATION_BOSS_1        = 5
;FORMATION_BOSS_2        = 6
;FORMATION_BOSS_3        = 7
;FORMATION_BOSS_4        = 8


ENEMY_GREEN_SLIME     = 1
ENEMY_BLUE_SLIME      = 2
ENEMY_ORC             = 3
ENEMY_SKELLY          = 4
ENEMY_SPECTRE         = 5
ENEMY_ROLLO           = 6
ENEMY_MIST            = 7
ENEMY_YELLOW_SKELLY   = 8
ENEMY_BOSS_1          = 9
ENEMY_BOSS_2          = 10
ENEMY_BOSS_3          = 11
ENEMY_BOSS_4          = 12
ENEMY_TONBERRY        = 13

;A = formation
!zone InitFormation
;CURRENT_CHAR_INDEX
;          !byte 0

InitFormation
          sta PARAM10

          tay

          lda FORMATION_ENEMY_COUNT,y
          sta PARAM5

          lda #<BATTLE_CHARS
          sta ZEROPAGE_POINTER_5
          lda #>BATTLE_CHARS
          sta ZEROPAGE_POINTER_5 + 1
          lda #BATTLE_CHARS_START
          sta CURRENT_CHAR_INDEX

          lda FORMATION_ENEMY_LIST_LO,y
          sta ZEROPAGE_POINTER_4
          lda FORMATION_ENEMY_LIST_HI,y
          sta ZEROPAGE_POINTER_4 + 1

          ldy #0
          ldy #0
          sty CURRENT_INDEX
          sty NUM_ENEMIES_ALIVE

.FetchNextEnemy
          ldx CURRENT_INDEX

          ;enemy type
          lda (ZEROPAGE_POINTER_4),y
          sta PARAM3

          ;enemy X
          iny
          lda (ZEROPAGE_POINTER_4),y
          sta PARAM1
          sta FIGHTER_X + 4,x

          ;enemy Y
          iny
          lda (ZEROPAGE_POINTER_4),y
          sta PARAM2
          sta FIGHTER_Y + 4,x

          ;copy charset?
          ldy PARAM3
          lda ENEMY_CHARS_DATA_LO,y
          sta ZEROPAGE_POINTER_2
          lda ENEMY_CHARS_DATA_HI,y
          sta ZEROPAGE_POINTER_2 + 1

          ldx #0
-
          ldy FIGHTER_ACTIVE + 4,x
          lda ENEMY_CHARS_DATA_LO,y
          cmp ZEROPAGE_POINTER_2
          bne .CharsDifferent

          lda ENEMY_CHARS_DATA_HI,y
          cmp ZEROPAGE_POINTER_2 + 1
          beq .ReuseChars

.CharsDifferent
          cpx CURRENT_INDEX
          beq .CharsNotUsedYet

          inx
          jmp -


.ReuseChars
          ;copy fighter size
          ldy CURRENT_INDEX
          lda FIGHTER_WIDTH + 4,x
          sta FIGHTER_WIDTH + 4,y
          lda FIGHTER_HEIGHT + 4,x
          sta FIGHTER_HEIGHT + 4,y

          ;copy char pointer
          lda FIGHTER_CHARS + 4,x
          ldx CURRENT_INDEX
          sta FIGHTER_CHARS + 4,x
          jmp .DisplayEnemy




.CharsNotUsedYet
          ;copy enemy chars to charset
          ldx CURRENT_INDEX
          ldy PARAM3

          lda ENEMY_CHAR_COUNT,y
          sta LOCAL2
          asl
          asl
          asl
          sta LOCAL1

          ;fighter width/height
          lda ENEMY_CHAR_WIDTH,y
          sta FIGHTER_WIDTH + 4,x
          lda #0
          sta FIGHTER_HEIGHT + 4,x

-
          inc FIGHTER_HEIGHT + 4,x
          lda LOCAL2
          sec
          sbc FIGHTER_WIDTH + 4,x
          sta LOCAL2
          bne -

          lda CURRENT_CHAR_INDEX
          sta FIGHTER_CHARS + 4,x

          lda ENEMY_CHARS_DATA_LO,y
          sta ZEROPAGE_POINTER_1
          lda ENEMY_CHARS_DATA_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #0
-
          lda (ZEROPAGE_POINTER_1),y
          sta (ZEROPAGE_POINTER_5),y

          iny
          cpy LOCAL1
          bne -

          ;UpdateCharsPointer
          lda LOCAL1
          clc
          adc ZEROPAGE_POINTER_5
          sta ZEROPAGE_POINTER_5
          bcc +
          inc ZEROPAGE_POINTER_5 + 1
+
          lda LOCAL1
          lsr
          lsr
          lsr
          clc
          adc CURRENT_CHAR_INDEX
          sta CURRENT_CHAR_INDEX

          ;x = enemy index
          ;
.DisplayEnemy
          lda CURRENT_INDEX
          clc
          adc #4
          tax
          jsr DisplayEnemy

          ;copy/set fighter data
          lda CURRENT_INDEX
          clc
          adc #4
          tax
          lda PARAM3
          sta FIGHTER_ACTIVE,x

          inc NUM_ENEMIES_ALIVE

          ldy PARAM3
          tya
          sta FIGHTER_TYPE,x

          lda ENEMY_HP_LO,y
          sta FIGHTER_HP_LO,x
          sta FIGHTER_HP_MAX_LO,x
          lda ENEMY_HP_HI,y
          sta FIGHTER_HP_HI,x
          sta FIGHTER_HP_MAX_HI,x

          ;lda ENEMY_HIT_RATE,y
          lda #100
          sta FIGHTER_HIT_RATE,x

          lda ENEMY_MP_LO,y
          sta FIGHTER_MP_LO,x
          sta FIGHTER_MP_MAX_LO,x
          lda ENEMY_MP_HI,y
          sta FIGHTER_MP_HI,x
          sta FIGHTER_MP_MAX_HI,x

          lda ENEMY_LEVEL,y
          sta FIGHTER_LEVEL,x
          lda ENEMY_MAGIC_DEFENSE,y
          sta FIGHTER_MAGIC_DEFENSE,x

          lda ENEMY_ELEMENT_WEAKNESS,y
          sta FIGHTER_ELEMENT_WEAK,x
          ;lda ENEMY_ELEMENT_IMMUNITY,y
          lda #0
          sta FIGHTER_ELEMENT_IMMUNE,x
          lda ENEMY_ELEMENT_ABSORB,y
          sta FIGHTER_ELEMENT_ABSORB,x
          lda ENEMY_ELEMENT_RESISTANCE,y
          sta FIGHTER_ELEMENT_RESISTANT,x

          lda ENEMY_ATTACK,y
          sta FIGHTER_ATTACK,x
          lda ENEMY_DEFENSE,y
          sta FIGHTER_DEFENSE,x
          lda ENEMY_EVASION,y
          sta FIGHTER_EVASION,x
          lda ENEMY_MAGIC_EVASION,y
          sta FIGHTER_MAGIC_EVASION,x

          lda #0
          sta FIGHTER_STATE,x
          ;sta FIGHTER_STATE_EX,x
          sta FIGHTER_FROZEN_COUNT,x

          lda ENEMY_MULTI_COLORS,y
          and #$0f
          sta BATTLE_MULTI_COLOR_2
          lda ENEMY_MULTI_COLORS,y
          lsr
          lsr
          lsr
          lsr
          sta BATTLE_MULTI_COLOR_1


          ;Note that vigor for each monster is randomly determined at the beginning of the battle as [56..63]
          lda #56
          ldy #63
          jsr GenerateRangedRandom
          sta FIGHTER_STRENGTH,x

          ldy PARAM3
          lda ENEMY_SPEED,y
          sta FIGHTER_SPEED,x

          ;random initial speed pos
          lda #0
          ldy #200
          jsr GenerateRangedRandom

          sta FIGHTER_SPEED_POS,x

          ;next enemy
          inc CURRENT_INDEX
          lda CURRENT_INDEX
          cmp PARAM5
          beq DisplayEnemyNames

          lda ZEROPAGE_POINTER_4
          clc
          adc #3
          sta ZEROPAGE_POINTER_4
          bcc ++
          inc ZEROPAGE_POINTER_4 + 1
++
          ldy #0
          jmp .FetchNextEnemy


!zone DisplayEnemyNames
DisplayEnemyNames
          jsr ClearEnemyNames

          lda #0
          ldx #4
          stx CURRENT_DISPLAY_ENEMY

.CheckNextFighter
          lda FIGHTER_ACTIVE,x
          beq .NextFighter
          sta LOCAL1

          ;used this fighter type before?
          txa
          tay
-
          cpy #4
          beq .CanDisplay

          lda FIGHTER_ACTIVE - 1,y
          cmp LOCAL1
          beq .SkipFighter
          dey
          jmp -

.CanDisplay
          ldy LOCAL1
          lda ENEMY_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda ENEMY_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText
          inc PARAM2
          ;lda PARAM2
          ;cmp #24
          ;beq .EnoughNames

.SkipFighter
.NextFighter
          inc CURRENT_DISPLAY_ENEMY
          ldx CURRENT_DISPLAY_ENEMY
          cpx #NUM_FIGHTERS
          bne .CheckNextFighter
;.EnoughNames
          rts



!zone ClearEnemyNames
ClearEnemyNames
          lda #1
          sta PARAM1
          lda #20
          sta PARAM2
          lda #8
          sta PARAM3
          lda #4
          sta PARAM4
          jmp ClearArea



;x = fighter index
;PARAM3 = enemy type
!zone DisplayEnemy
PrepareEnemyPointers
          ldy FIGHTER_Y,x
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_2
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_2 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_3 + 1

          ;add x
          lda FIGHTER_X,x
          clc
          adc ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+

          ldy PARAM3
          lda ENEMY_COLOR_DATA_LO,y
          sta ZEROPAGE_POINTER_1
          lda ENEMY_COLOR_DATA_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ;color pointer
          lda #0
          sta LOCAL1
          sta PARAM9
          sta PARAM10

          ;char width
          lda ENEMY_CHAR_WIDTH,y
          sta LOCAL2

          lda ENEMY_CHAR_COUNT,y
          sta LOCAL3

          lda FIGHTER_CHARS,x
          sta LOCAL4
          rts

DisplayEnemy
          jsr PrepareEnemyPointers

.DrawLine
          ;line

.NextChar
          ;char
          ldy PARAM10
          lda LOCAL4
          sta (ZEROPAGE_POINTER_2),y
          inc LOCAL4

          ;color
          ldy LOCAL1
          lda (ZEROPAGE_POINTER_1),y
          ldy PARAM10
          sta (ZEROPAGE_POINTER_3),y

          inc PARAM9
          inc PARAM10
          inc LOCAL1

          lda PARAM10
          cmp LOCAL2
          bne .NextChar

          ;next line?
          lda PARAM9
          cmp LOCAL3
          bne .NextLine
          rts

.NextLine
          lda ZEROPAGE_POINTER_2
          clc
          adc #40
          sta ZEROPAGE_POINTER_2
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
+
          lda ZEROPAGE_POINTER_3
          clc
          adc #40
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_3 + 1
+
          lda #0
          sta PARAM10
          jmp .DrawLine



;x = fighter index
;PARAM3 = enemy type
!zone HighlightEnemy
ENEMY_HIGHLIGHT_TYPE
          !byte 0

HighlightEnemy
          jsr PrepareEnemyPointers

          lda ENEMY_HIGHLIGHT_TYPE
          eor #$01
          sta ENEMY_HIGHLIGHT_TYPE

!if 0 {
          ldy FIGHTER_Y,x
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_2
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_2 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_3 + 1

          ;add x
          lda FIGHTER_X,x
          clc
          adc ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+

          ldy PARAM3

          ;color pointer
          lda #0
          sta LOCAL1
          sta PARAM9
          sta PARAM10

          ;char width
          lda ENEMY_CHAR_WIDTH,y
          sta LOCAL2

          lda ENEMY_CHAR_COUNT,y
          sta LOCAL3

          lda FIGHTER_CHARS,x
          sta LOCAL4
}

.DrawLine
          ;line

.NextChar
          ;char
          ldy PARAM10
          lda LOCAL4
          sta (ZEROPAGE_POINTER_2),y
          inc LOCAL4

          ;color
          ;ldy LOCAL1
          lda (ZEROPAGE_POINTER_3),y
          and #$08
          ora ENEMY_HIGHLIGHT_TYPE
          sta (ZEROPAGE_POINTER_3),y

          inc PARAM9
          inc PARAM10
          inc LOCAL1

          lda PARAM10
          cmp LOCAL2
          bne .NextChar

          ;next line?
          lda PARAM9
          cmp LOCAL3
          bne .NextLine
          rts

.NextLine
          lda ZEROPAGE_POINTER_2
          clc
          adc #40
          sta ZEROPAGE_POINTER_2
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
+
          lda ZEROPAGE_POINTER_3
          clc
          adc #40
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_3 + 1
+
          lda #0
          sta PARAM10
          jmp .DrawLine


;x = fighter index
!zone ClearEnemy
ClearEnemy
          ldy FIGHTER_Y,x
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_2
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_2 + 1

          ;add x
          lda FIGHTER_X,x
          clc
          adc ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_2
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
+

          ldy FIGHTER_ACTIVE,x

          lda #0
          sta FIGHTER_ACTIVE,x

          ;color pointer
          lda #0
          sta LOCAL1
          sta PARAM9
          sta PARAM10

          ;char width
          lda ENEMY_CHAR_WIDTH,y
          sta LOCAL2

          lda ENEMY_CHAR_COUNT,y
          sta LOCAL3

.DrawLine
          ;line

.NextChar
          ;char
          ldy PARAM10
          lda #32
          sta (ZEROPAGE_POINTER_2),y

          inc PARAM9
          inc PARAM10
          inc LOCAL1

          lda PARAM10
          cmp LOCAL2
          bne .NextChar

          ;next line?
          lda PARAM9
          cmp LOCAL3
          bne .NextLine
          rts

.NextLine
          lda ZEROPAGE_POINTER_2
          clc
          adc #40
          sta ZEROPAGE_POINTER_2
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
+
          lda #0
          sta PARAM10
          jmp .DrawLine



;x, CURRENT_INDEX = enemy
!zone EnemyAI
EnemyAI
          ;safety measure
          lda NUM_PLAYERS_ALIVE
          bne +
          jmp FightLoop
+

          ;"AI"
          ldy FIGHTER_ACTIVE,x

          ;number of special attacks
          lda ENEMY_ATTACKS,y
          and #$7f
          beq .NoSpecialAttacks

          ;TODO
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
          jmp HandleSpecialAttack


.ChanceFailed
          ldy PARAM2
          lda PARAM1
          bmi .NoSpecialAttacks

          iny
          jmp .CheckNextSpecialAttack


.NoSpecialAttacks
          ldx CURRENT_INDEX
          ldy FIGHTER_ACTIVE,x
          lda ENEMY_ATTACKS,y
          bmi .HasPhysicalAttack

          ;do nothing? (wait)
          jmp FightLoop

.HasPhysicalAttack
          jsr ChoosePhysicalTarget
          lda CURRENT_TARGET
          bmi .NoTarget

          ldx CURRENT_INDEX
          jsr AttackTarget

.NoTarget
          jmp FightLoop


;CURRENT_INDEX = fighter
;CURRENT_SPECIAL_ATTACK = special attack index
!zone HandleSpecialAttack
HandleSpecialAttack
          jsr ChoosePhysicalTarget
          lda CURRENT_TARGET
          bmi .NoTarget

          lda #ATTACK_TARGET_SINGLE
          sta ATTACK_TARGET

          ldx CURRENT_INDEX
          ldy CURRENT_SPECIAL_ATTACK
          jsr PlayAttackAnimation
.NoTarget
          jmp FightLoop



;a = chance (0 to 100)
;returns 1 = erfolgreich
!zone CheckChance
CheckChance
          sta PARAM3

          lda #0
          ldy #100
          jsr GenerateRangedRandom
          cmp PARAM3
          bcc +

          lda #0
          rts
+
          lda #1
          rts


;choose random player
!zone ChoosePhysicalTarget
ChoosePhysicalTarget
          ldx #0
-
          jsr CanSelectOrTargetFighter
          bne .ValidTargetExists

          inx
          cpx #4
          bne -

          lda #$ff
          sta CURRENT_TARGET
          rts

.ValidTargetExists
.TryOtherPlayer
          jsr GenerateRandomNumber
          and #$03

          tax

          jsr CanSelectOrTargetFighter
          beq .TryOtherPlayer

          stx CURRENT_TARGET
          rts




FORMATION_ENEMY_LIST_LO
          !byte <F_GREEN_SLIME
          !byte <F_GREEN_SLIME_2
          !byte <F_BLUE_SLIME
          !byte <F_SLIMES
          !byte <F_ORC
          !byte <F_ORC_2
          !byte <F_SKELLY
          !byte <F_SKELLIES
          !byte <F_SPECTRE
          !byte <F_ROLLO
          !byte <F_ROLLO_2
          !byte <F_MIST
          !byte <F_MIST_2
          !byte <F_SKELLIES_MIX
          !byte <F_BOSS_1
          !byte <F_BOSS_2
          !byte <F_BOSS_3
          !byte <F_BOSS_4
          !byte <F_SKELLIES_PLUS
          !byte <F_SKELLIES_PLUS2
          !byte <F_ROLLO_MIST_MIX
          !byte <F_TONBERRY
          !byte <F_TONBERRIES

FORMATION_ENEMY_LIST_HI
          !byte >F_GREEN_SLIME
          !byte >F_GREEN_SLIME_2
          !byte >F_BLUE_SLIME
          !byte >F_SLIMES
          !byte >F_ORC
          !byte >F_ORC_2
          !byte >F_SKELLY
          !byte >F_SKELLIES
          !byte >F_SPECTRE
          !byte >F_ROLLO
          !byte >F_ROLLO_2
          !byte >F_MIST
          !byte >F_MIST_2
          !byte >F_SKELLIES_MIX
          !byte >F_BOSS_1
          !byte >F_BOSS_2
          !byte >F_BOSS_3
          !byte >F_BOSS_4
          !byte >F_SKELLIES_PLUS
          !byte >F_SKELLIES_PLUS2
          !byte >F_ROLLO_MIST_MIX
          !byte >F_TONBERRY
          !byte >F_TONBERRIES


F_GREEN_SLIME
          !byte ENEMY_GREEN_SLIME, 5,7

F_GREEN_SLIME_2
          !byte ENEMY_GREEN_SLIME, 5,7
          !byte ENEMY_GREEN_SLIME, 5,10

F_BLUE_SLIME
          !byte ENEMY_BLUE_SLIME, 5,7

F_SLIMES
          !byte ENEMY_GREEN_SLIME, 8,7
          !byte ENEMY_BLUE_SLIME, 13,10
          !byte ENEMY_GREEN_SLIME, 7,13

F_ORC
          !byte ENEMY_ORC, 13,10

F_ORC_2
          !byte ENEMY_ORC, 8,7
          !byte ENEMY_ORC, 7,13

F_SKELLY
          !byte ENEMY_SKELLY,13,10
F_SKELLIES
          !byte ENEMY_SKELLY,8,7
          !byte ENEMY_SKELLY,7,13

F_SPECTRE
          !byte ENEMY_SPECTRE,8,8

F_ROLLO
          !byte ENEMY_ROLLO,5,7

F_ROLLO_2
          !byte ENEMY_ROLLO,8,7
          !byte ENEMY_ROLLO,13,10
          !byte ENEMY_ROLLO,7,13

F_MIST
          !byte ENEMY_MIST,5,9
F_MIST_2
          !byte ENEMY_MIST,5,9
          !byte ENEMY_MIST,13,10

F_SKELLIES_MIX
          !byte ENEMY_SKELLY,12,7
          !byte ENEMY_SKELLY,10,13
          !byte ENEMY_YELLOW_SKELLY,5,10

F_SKELLIES_PLUS
          !byte ENEMY_SKELLY,18,6
          !byte ENEMY_SKELLY,16,12
          !byte ENEMY_SKELLY,12,6
          !byte ENEMY_SKELLY,10,12
          !byte ENEMY_YELLOW_SKELLY,5,9

F_SKELLIES_PLUS2
          !byte ENEMY_SKELLY,18,6
          !byte ENEMY_YELLOW_SKELLY,16,12
          !byte ENEMY_YELLOW_SKELLY,12,7
          !byte ENEMY_SKELLY,10,13
          !byte ENEMY_YELLOW_SKELLY,5,10

F_ROLLO_MIST_MIX
          !byte ENEMY_ROLLO,9,7
          !byte ENEMY_ROLLO,13,10
          !byte ENEMY_ROLLO,10,13
          !byte ENEMY_MIST,5,9
          !byte ENEMY_MIST,18,12


F_BOSS_1
          !byte ENEMY_BOSS_1,10,8
F_BOSS_2
          !byte ENEMY_BOSS_2,10,8
F_BOSS_3
          !byte ENEMY_BOSS_3,10,8
F_BOSS_4
          !byte ENEMY_BOSS_4,10,8

F_TONBERRY
          !byte ENEMY_TONBERRY,13,10
F_TONBERRIES
          !byte ENEMY_TONBERRY,8,7
          !byte ENEMY_TONBERRY,7,13

FORMATION_GROUP
          !byte 0
          !byte 0
          !byte 1
          !byte 1
          !byte 2       ;orc
          !byte 2       ;orcs
          !byte 2       ;zombie
          !byte 2       ;zombies
          !byte 3       ;spectre
          !byte 4       ;rollo
          !byte 4       ;rollos
          !byte 4       ;mist
          !byte 4       ;mists
          !byte 10      ;skellies mix
          !byte 5       ;boss 1
          !byte 6       ;boss 2
          !byte 7       ;boss 3
          !byte 8       ;boss 4
          !byte 9       ;skellies plus 1
          !byte 9       ;skellies plus 2
          !byte 10      ;roll/mist mix
          !byte 11      ;tonberry
          !byte 11      ;tonberries

FORMATION_ENEMY_COUNT
          !byte 1
          !byte 2
          !byte 1
          !byte 3
          !byte 1       ;orc
          !byte 2       ;orcs
          !byte 1       ;zombie
          !byte 2       ;zombies
          !byte 1       ;spectre
          !byte 1       ;rollo
          !byte 3       ;rollos
          !byte 1       ;mist
          !byte 2       ;mists
          !byte 3       ;skellies mix
          !byte 1       ;boss 1
          !byte 1       ;boss 2
          !byte 1       ;boss 3
          !byte 1       ;boss 4
          !byte 5       ;skellies plus 1
          !byte 5       ;skellies plus 2
          !byte 5       ;roll/mist mix
          !byte 1       ;tonberry
          !byte 2       ;tonberries

NUM_FORMATIONS = FORMATION_ENEMY_COUNT - FORMATION_GROUP


ENEMY_CHAR_COUNT = * - 1
          !byte 6     ;green slime
          !byte 6     ;blue slime
          !byte 9     ;star
          !byte 9     ;skelly
          !byte 9     ;spectre
          !byte 9     ;rollo
          !byte 6     ;mist
          !byte 9     ;yellow skelly
          !byte 32    ;boss 1
          !byte 28    ;boss 2
          !byte 28    ;boss 3
          !byte 32    ;boss 4
          !byte 6     ;tonberry

ENEMY_CHAR_WIDTH = * - 1
          !byte 3     ;green slime
          !byte 3     ;blue slime
          !byte 3     ;star
          !byte 3     ;skelly
          !byte 3     ;spectre
          !byte 3     ;rollo
          !byte 3     ;mist
          !byte 3     ;yellow skelly
          !byte 8     ;boss 1
          !byte 7     ;boss 2
          !byte 7     ;boss 3
          !byte 8     ;boss 4
          !byte 3     ;tonberry

ENEMY_CHARS_DATA_LO = * - 1
          !byte <ENEMY_CHARS_SLIME
          !byte <ENEMY_CHARS_SLIME
          !byte <ENEMY_CHARS_ORC
          !byte <ENEMY_CHARS_SKELLY
          !byte <ENEMY_CHARS_spectre
          !byte <ENEMY_CHARS_ROLLO
          !byte <ENEMY_CHARS_MIST
          !byte <ENEMY_CHARS_SKELLY
          !byte <ENEMY_CHARS_BOSS_1
          !byte <ENEMY_CHARS_BOSS_2
          !byte <ENEMY_CHARS_BOSS_3
          !byte <ENEMY_CHARS_BOSS_4
          !byte <ENEMY_CHARS_TONBERRY

ENEMY_COLOR_DATA_LO = * - 1
          !byte <ENEMY_COLOR_GREEN_SLIME
          !byte <ENEMY_COLOR_BLUE_SLIME
          !byte <ENEMY_COLOR_ORC
          !byte <ENEMY_COLOR_SKELLY
          !byte <ENEMY_COLOR_spectre
          !byte <ENEMY_COLOR_ROLLO
          !byte <ENEMY_COLOR_MIST
          !byte <ENEMY_COLOR_YELLOW_SKELLY
          !byte <ENEMY_COLOR_BOSS_1
          !byte <ENEMY_COLOR_BOSS_2
          !byte <ENEMY_COLOR_BOSS_3
          !byte <ENEMY_COLOR_BOSS_4
          !byte <ENEMY_COLOR_TONBERRY

ENEMY_CHARS_DATA_HI = * - 1
          !byte >ENEMY_CHARS_SLIME
          !byte >ENEMY_CHARS_SLIME
          !byte >ENEMY_CHARS_ORC
          !byte >ENEMY_CHARS_SKELLY
          !byte >ENEMY_CHARS_spectre
          !byte >ENEMY_CHARS_ROLLO
          !byte >ENEMY_CHARS_MIST
          !byte >ENEMY_CHARS_SKELLY
          !byte >ENEMY_CHARS_BOSS_1
          !byte >ENEMY_CHARS_BOSS_2
          !byte >ENEMY_CHARS_BOSS_3
          !byte >ENEMY_CHARS_BOSS_4
          !byte >ENEMY_CHARS_TONBERRY


ENEMY_COLOR_DATA_HI = * - 1
          !byte >ENEMY_COLOR_GREEN_SLIME
          !byte >ENEMY_COLOR_BLUE_SLIME
          !byte >ENEMY_COLOR_ORC
          !byte >ENEMY_COLOR_SKELLY
          !byte >ENEMY_COLOR_spectre
          !byte >ENEMY_COLOR_ROLLO
          !byte >ENEMY_COLOR_MIST
          !byte >ENEMY_COLOR_YELLOW_SKELLY
          !byte >ENEMY_COLOR_BOSS_1
          !byte >ENEMY_COLOR_BOSS_2
          !byte >ENEMY_COLOR_BOSS_3
          !byte >ENEMY_COLOR_BOSS_4
          !byte >ENEMY_COLOR_TONBERRY


ENEMY_CHARS_SLIME
          !byte $00,$01,$0b,$07,$27,$27,$1f,$1f
          !byte $fe,$7d,$bb,$11,$ef,$ff,$ff,$01
          !byte $00,$80,$40,$e0,$d0,$f0,$f8,$f4
          !byte $1c,$1f,$1f,$27,$27,$29,$09,$00
          !byte $7c,$ff,$d7,$ff,$ff,$ff,$ff,$00
          !byte $f4,$f4,$f4,$f8,$d8,$e0,$40,$00



ENEMY_CHARS_ORC
          !byte $00,$00,$00,$00,$02,$01,$09,$0b
          !byte $00,$27,$9f,$9f,$9f,$a7,$67,$59
          !byte $00,$f0,$f8,$74,$ac,$f8,$90,$90
          !byte $27,$27,$1f,$27,$1f,$1f,$25,$6f
          !byte $d6,$75,$7f,$7f,$7f,$6a,$a5,$95
          !byte $f0,$a8,$64,$64,$64,$a4,$58,$54
          !byte $6f,$85,$00,$05,$05,$09,$09,$00
          !byte $a5,$2a,$c0,$f6,$f6,$d5,$ff,$00
          !byte $58,$a0,$00,$d0,$e0,$98,$66,$00

ENEMY_CHARS_spectre
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$20,$30,$37,$09,$1e,$1f,$18
          !byte $00,$08,$18,$e8,$c0,$b0,$f0,$10
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $0c,$03,$3c,$d5,$55,$4f,$ca,$a0
          !byte $30,$c0,$08,$e0,$ea,$a0,$08,$c0
          !byte $0b,$20,$00,$00,$00,$00,$00,$00
          !byte $0f,$7f,$ba,$55,$a8,$04,$40,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00

ENEMY_CHARS_ROLLO
          !byte  $20,$30,$30,$30,$30,$30,$30,$30
          !byte  $00,$00,$00,$00,$00,$00,$00,$00
          !byte  $00,$00,$00,$00,$00,$00,$00,$00
          !byte  $98,$20,$15,$1d,$17,$05,$01,$01
          !byte  $15,$5f,$7f,$f7,$f3,$f3,$73,$f7
          !byte  $00,$40,$d0,$70,$30,$30,$30,$70
          !byte  $01,$01,$00,$02,$01,$01,$01,$00
          !byte  $7f,$d0,$75,$15,$80,$42,$d1,$00
          !byte  $d0,$50,$40,$00,$00,$40,$d0,$00

ENEMY_CHARS_MIST
          !byte $00,$02,$09,$07,$0f,$2f,$9d,$7f
          !byte $00,$7f,$ff,$cf,$f3,$c3,$ff,$7f
          !byte $00,$60,$d0,$c8,$34,$0c,$f6,$dd
          !byte $ff,$ff,$ff,$7f,$1f,$27,$0a,$00
          !byte $ff,$ff,$ff,$ff,$ff,$df,$88,$00
          !byte $ff,$ff,$ff,$ff,$fd,$76,$a8,$00

ENEMY_CHARS_SKELLY
          !byte $01,$03,$03,$03,$03,$03,$03,$01
          !byte $fc,$fe,$ba,$92,$92,$fe,$54,$00
          !byte $08,$0c,$0c,$0c,$0c,$0c,$0c,$15
          !byte $00,$02,$09,$31,$02,$74,$fc,$74
          !byte $fc,$00,$a8,$68,$58,$58,$58,$58
          !byte $08,$3c,$c4,$00,$00,$00,$00,$00
          !byte $74,$74,$10,$01,$01,$03,$07,$0d
          !byte $58,$a0,$00,$04,$04,$0c,$4d,$c7
          !byte $00,$00,$00,$00,$00,$00,$00,$00

ENEMY_CHARS_BOSS_1
          !byte $64,$a8,$64,$30,$13,$a2,$eb,$2c
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $03,$0d,$37,$3c,$1c,$3c,$3c,$3c
          !byte $54,$fd,$03,$00,$cc,$88,$44,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $0e,$cb,$b8,$ec,$20,$2b,$2c,$b0
          !byte $c0,$00,$00,$00,$08,$38,$2c,$2e
          !byte $00,$00,$00,$00,$00,$00,$ec,$b0
          !byte $2c,$20,$e3,$ae,$e8,$2c,$20,$2c
          !byte $00,$00,$00,$00,$00,$03,$3d,$df
          !byte $3c,$34,$0d,$d3,$7c,$f3,$cc,$00
          !byte $03,$03,$cd,$03,$03,$0c,$03,$00
          !byte $00,$03,$0d,$dd,$73,$cc,$00,$00
          !byte $80,$ce,$7b,$40,$40,$c0,$80,$ec
          !byte $2b,$b0,$e0,$2c,$38,$0c,$00,$00
          !byte $b0,$e0,$2c,$38,$03,$00,$00,$00
          !byte $dc,$54,$dc,$30,$10,$20,$20,$20
          !byte $fc,$f3,$fc,$30,$cc,$30,$00,$00
          !byte $c0,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$03,$0c,$33,$0c,$30,$cc,$30
          !byte $0f,$f0,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $20,$ec,$ab,$23,$10,$30,$00,$00
          !byte $00,$30,$cc,$33,$c0,$4c,$04,$00
          !byte $00,$03,$cc,$33,$cc,$00,$00,$00
          !byte $cc,$30,$c0,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00

ENEMY_CHARS_BOSS_2
          !byte $98,$54,$98,$30,$20,$20,$10,$10
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $03,$0e,$3b,$3c,$2c,$3c,$3c,$3c
          !byte $a8,$fe,$03,$00,$cc,$44,$88,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$03,$30,$00,$3f,$ea
          !byte $00,$00,$00,$00,$00,$30,$00,$c3
          !byte $30,$30,$30,$30,$30,$30,$30,$30
          !byte $00,$00,$00,$00,$00,$03,$3e,$ef
          !byte $3c,$38,$0e,$e3,$bc,$f3,$cc,$00
          !byte $03,$03,$ce,$03,$03,$0c,$03,$00
          !byte $00,$03,$0e,$ee,$b3,$cc,$00,$00
          !byte $95,$e5,$95,$59,$95,$e5,$55,$95
          !byte $b3,$6c,$6c,$6c,$6c,$6f,$6c,$b0
          !byte $dc,$54,$dc,$30,$20,$10,$10,$10
          !byte $fc,$f3,$fc,$30,$cc,$30,$00,$00
          !byte $c0,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$03,$0c,$33,$0c,$30,$cc,$30
          !byte $0f,$f0,$00,$00,$00,$00,$00,$00
          !byte $ea,$3f,$c0,$0c,$00,$00,$00,$00
          !byte $c3,$00,$30,$00,$00,$00,$00,$00
          !byte $10,$10,$10,$10,$20,$30,$00,$00
          !byte $00,$30,$cc,$33,$c0,$8c,$08,$00
          !byte $00,$03,$cc,$33,$cc,$00,$00,$00
          !byte $cc,$30,$c0,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00

ENEMY_CHARS_BOSS_3
          !byte $64,$a8,$64,$30,$10,$10,$20,$20
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $03,$0d,$37,$3c,$1c,$3c,$3c,$3c
          !byte $54,$fd,$03,$00,$cc,$88,$44,$00
          !byte $00,$00,$03,$00,$0c,$03,$03,$03
          !byte $0c,$3c,$37,$fb,$d5,$d9,$66,$6a
          !byte $33,$fc,$dc,$6f,$94,$67,$97,$97
          !byte $30,$30,$30,$30,$30,$30,$30,$30
          !byte $00,$00,$00,$00,$00,$03,$3d,$df
          !byte $3c,$34,$0d,$d3,$7c,$f3,$cc,$00
          !byte $03,$03,$cd,$03,$03,$0c,$03,$00
          !byte $00,$03,$0d,$dd,$73,$cc,$00,$00
          !byte $da,$d9,$56,$59,$75,$f7,$ff,$3f
          !byte $5f,$9c,$7c,$73,$fc,$f3,$c0,$30
          !byte $dc,$54,$dc,$30,$10,$20,$20,$20
          !byte $fc,$f3,$fc,$30,$cc,$30,$00,$00
          !byte $c0,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$03,$0c,$33,$0c,$30,$cc,$30
          !byte $0f,$f0,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $20,$20,$20,$20,$10,$30,$00,$00
          !byte $00,$30,$cc,$33,$c0,$4c,$04,$00
          !byte $00,$03,$cc,$33,$cc,$00,$00,$00
          !byte $cc,$30,$c0,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00

ENEMY_CHARS_BOSS_4
          !byte $98,$54,$98,$30,$20,$20,$10,$10
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $03,$0e,$3b,$3c,$2c,$3c,$3c,$3c
          !byte $a8,$fe,$03,$00,$cc,$44,$88,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$03,$0e,$39
          !byte $00,$00,$00,$00,$00,$b0,$5b,$56
          !byte $00,$00,$00,$00,$00,$00,$00,$b0
          !byte $30,$30,$30,$30,$30,$30,$30,$30
          !byte $00,$00,$00,$00,$00,$03,$3e,$ef
          !byte $3c,$38,$0e,$e3,$bc,$f3,$cc,$00
          !byte $03,$03,$ce,$03,$03,$0c,$03,$00
          !byte $00,$03,$0d,$ee,$b3,$cc,$00,$00
          !byte $e5,$d5,$95,$95,$95,$e5,$39,$0e
          !byte $55,$55,$55,$56,$5b,$6c,$b0,$c0
          !byte $6c,$56,$5b,$b0,$00,$00,$00,$00
          !byte $ec,$a8,$ec,$30,$20,$10,$10,$10
          !byte $fc,$f3,$fc,$30,$cc,$30,$00,$00
          !byte $c0,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$03,$0c,$33,$0c,$30,$cc,$30
          !byte $0f,$f0,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $10,$10,$10,$10,$20,$30,$00,$00
          !byte $00,$30,$cc,$33,$c0,$8c,$08,$00
          !byte $00,$03,$cc,$33,$cc,$00,$00,$00
          !byte $cc,$30,$c0,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00
          !byte $00,$00,$00,$00,$00,$00,$00,$00

ENEMY_CHARS_TONBERRY
          !byte  $00,$00,$00,$00,$00,$08,$2e,$39
          !byte  $02,$09,$25,$15,$94,$54,$66,$65
          !byte  $58,$56,$77,$44,$55,$96,$28,$80
          !byte  $29,$09,$32,$c0,$40,$41,$14,$00
          !byte  $65,$85,$20,$fe,$bf,$2f,$8a,$60
          !byte  $e8,$fe,$7e,$2a,$88,$a0,$88,$26

ENEMY_COLOR_BOSS_4
          !byte $0e,$08,$0e,$0e,$08,$0e,$0e,$0e
          !byte $01,$0e,$0e,$0e,$0e,$0e,$0e,$0e
          !byte $0e,$06,$06,$06,$06,$08,$08,$08
          !byte $0e,$0e,$06,$06,$08,$08,$08,$08

ENEMY_COLOR_ROLLO
          !byte $01,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f

ENEMY_COLOR_BLUE_SLIME
          !byte $0b,$03,$0b,$0b,$03,$0b

ENEMY_COLOR_GREEN_SLIME
          !byte $0d,$05,$0d,$0d,$05,$0d


ENEMY_COLOR_ORC
          !byte $0d,$0d,$05,$0d,$0d,$0d,$0d,$0d,$0f

ENEMY_COLOR_MIST
          !byte $09,$09,$09,$09,$09,$09

ENEMY_COLOR_SKELLY
          !byte 9,1,9,9,9,9,9,9;,0  ;fallthrough!

ENEMY_COLOR_spectre
          !byte 0,2,2,0,10,10,10,2,0

ENEMY_COLOR_YELLOW_SKELLY
          !byte 7,7,9,9,15,15,15,15,0

ENEMY_COLOR_BOSS_1
          !byte $0a,$08,$0a,$0a,$08,$0a,$0a,$0a
          !byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
          !byte $0a,$02,$02,$06,$06,$08,$08,$08
          !byte $0a,$0e,$06,$06,$08,$08,$08,$08

ENEMY_COLOR_BOSS_2
          !byte $0d,$08,$0d,$0d,$08,$0e,$06,$01
          !byte $0d,$0d,$0d,$0d,$0e,$0e,$0d,$05
          !byte $05,$06,$06,$0e,$06,$0d,$0e,$06
          !byte $06,$08,$08,$08
ENEMY_COLOR_BOSS_3
          !byte $0c,$08,$0c,$0c,$02,$0a,$0a,$07
          !byte $0c,$0c,$0c,$0c,$0a,$0a,$0c,$04
          !byte $04,$06,$06,$08,$08,$0c,$0e,$06
          !byte $06,$08,$08,$08



ENEMY_COLOR_TONBERRY
          !byte  $0a,$0d,$09,$0a,$09,$09


ENEMY_HP_LO = * - 1
          !byte 5       ;green slime
          !byte 15      ;blue slime
          !byte 30      ;star
          !byte 50      ;skelly
          !byte 100     ;spectre
          !byte 24      ;rollo
          !byte 10      ;mist
          !byte 70      ;yellow skelly
          !byte <10000  ;boss 1
          !byte <10000  ;boss 2
          !byte <10000  ;boss 3
          !byte <7500   ;boss 4
          !byte <500    ;tonberry

ENEMY_HP_HI = * - 1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;orc
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 0       ;mist
          !byte 0       ;yellow skelly
          !byte >10000  ;boss 1
          !byte >10000  ;boss 2
          !byte >10000  ;boss 3
          !byte >7500   ;boss 4
          !byte >500    ;tonberry

ENEMY_LEVEL = * - 1
          !byte 2       ;green slime
          !byte 3       ;blue slime
          !byte 7       ;orc
          !byte 10      ;skelly
          !byte 05      ;spectre
          !byte 5       ;rollo
          !byte 4       ;mist
          !byte 6       ;yellow skelly
          !byte 40      ;boss 1
          !byte 40      ;boss 2
          !byte 40      ;boss 3
          !byte 30      ;boss 4
          !byte 20      ;tonberry

ENEMY_MP_LO = * - 1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;orc
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 200     ;mist
          !byte 0       ;yellow skelly
          !byte <1000   ;boss 1
          !byte <1000   ;boss 2
          !byte <1000   ;boss 3
          !byte <1000   ;boss 4
          !byte 200     ;tonberry

ENEMY_MP_HI = * - 1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;star
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 0       ;mist
          !byte 0       ;yellow skelly
          !byte >1000   ;boss 1
          !byte >1000   ;boss 2
          !byte >1000   ;boss 3
          !byte >1000   ;boss 4
          !byte 0       ;tonberry

ENEMY_SPEED = * - 1
          !byte 10      ;green slime
          !byte 10      ;blue slime
          !byte 10      ;star
          !byte 10      ;skelly
          !byte 10      ;spectre
          !byte 12      ;mist
          !byte 12      ;yellow skelly
          !byte 12      ;boss 1
          !byte 12      ;boss 2
          !byte 12      ;boss 3
          !byte 12      ;boss 4
          !byte 20      ;tonberry

ENEMY_ATTACK = *-1
          !byte 27      ;green slime
          !byte 29      ;blue slime
          !byte 20      ;star
          !byte 34      ;skelly
          !byte 30      ;spectre
          !byte 28      ;rollo
          !byte 15      ;mist
          !byte 30      ;yellow skelly
          !byte 50      ;boss 1
          !byte 50      ;boss 2
          !byte 50      ;boss 3
          !byte 50      ;boss 4
          !byte 40      ;tonberry

ENEMY_DEFENSE = *-1
          !byte 5       ;green slime
          !byte 6       ;blue slime
          !byte 12      ;star
          !byte 14      ;skelly
          !byte 20      ;spectre
          !byte 8       ;rollo
          !byte 100     ;mist
          !byte 8       ;yellow skelly
          !byte 50      ;boss 1
          !byte 50      ;boss 2
          !byte 50      ;boss 3
          !byte 50      ;boss 4
          !byte 30      ;tonberry

ENEMY_MAGIC_DEFENSE = *-1
          !byte 12      ;green slime
          !byte 14      ;blue slime
          !byte 15      ;star
          !byte 15      ;skelly
          !byte 15      ;spectre
          !byte 13      ;rollo
          !byte 2       ;mist
          !byte 12      ;yellow skelly
          !byte 50      ;boss 1
          !byte 50      ;boss 2
          !byte 50      ;boss 3
          !byte 50      ;boss 4
          !byte 50      ;tonberry

ENEMY_EVASION = *-1
          !byte 10      ;green slime
          !byte 12      ;blue slime
          !byte 15      ;star
          !byte 15      ;skelly
          !byte 15      ;spectre
          !byte 10      ;rollo
          !byte 10      ;mist
          !byte 10      ;yellow skelly
          !byte 20      ;boss 1
          !byte 20      ;boss 2
          !byte 20      ;boss 3
          !byte 20      ;boss 4
          !byte 20      ;tonberry

ENEMY_MAGIC_EVASION = *-1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;star
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 10      ;mist
          !byte 0       ;yellow skelly
          !byte 10      ;boss 1
          !byte 10      ;boss 2
          !byte 10      ;boss 3
          !byte 10      ;boss 4
          !byte 20      ;tonberry

ENEMY_XP_LO = *-1
          !byte 5       ;green slime
          !byte 8       ;blue slime
          !byte 50      ;orc
          !byte 50      ;skelly
          !byte 100     ;spectre
          !byte 12      ;rollo
          !byte 15      ;mist
          !byte 120     ;yellow skelly
          !byte <2000   ;boss 1
          !byte <2000   ;boss 2
          !byte <2000   ;boss 3
          !byte <2000   ;boss 4
          !byte <275    ;tonberry

ENEMY_XP_HI = *-1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;orc
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 0       ;mist
          !byte 0       ;yellow skelly
          !byte >2000   ;boss 1
          !byte >2000   ;boss 2
          !byte >2000   ;boss 3
          !byte >2000   ;boss 4
          !byte >275    ;tonberry

!if 0 {
ENEMY_HIT_RATE = * - 1
          !byte 100     ;green slime
          !byte 100     ;blue slime
          !byte 100     ;star
          !byte 100     ;skelly
          !byte 100     ;spectre
          !byte 100     ;rollo
          !byte 100     ;mist
          !byte 100     ;yellow skelly
          !byte 100     ;boss 1
          !byte 100     ;boss 2
          !byte 100     ;boss 3
          !byte 100     ;boss 4
          !byte 100     ;tonberry
}

ENEMY_ELEMENT_WEAKNESS = * - 1
          !byte 0               ;green slime
          !byte 0               ;blue slime
          !byte 0               ;star
          !byte ELEMENT_FIRE    ;skelly
          !byte 0               ;spectre
          !byte 0               ;rollo
          !byte 0               ;mist
          !byte 0               ;yellow skelly
          !byte ELEMENT_EARTH   ;boss 1
          !byte ELEMENT_LIGHTNING ;boss 2
          !byte ELEMENT_ICE     ;boss 3
          !byte ELEMENT_FIRE    ;boss 4
          !byte ELEMENT_EARTH   ;tonberry

!if 0 {
ENEMY_ELEMENT_IMMUNITY = * - 1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;star
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 0       ;mist
          !byte 0       ;yellow skelly
          !byte 0       ;boss 1
          !byte 0       ;boss 2
          !byte 0       ;boss 3
          !byte 0       ;boss 4
          !byte 0       ;tonberry
}

CURRENT_SPECIAL_ATTACK
          !byte 0

CURRENT_DISPLAY_ENEMY
          !byte 0

ENEMY_ELEMENT_RESISTANCE = * - 1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;star
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 0       ;mist
          !byte 0       ;yellow skelly
          !byte ELEMENT_ICE | ELEMENT_FIRE        ;boss 1
          !byte ELEMENT_FIRE | ELEMENT_ICE        ;boss 2
          !byte ELEMENT_EARTH | ELEMENT_LIGHTNING ;boss 3
          !byte ELEMENT_EARTH | ELEMENT_LIGHTNING ;boss 4
          !byte ELEMENT_EARTH | ELEMENT_LIGHTNING | ELEMENT_FIRE | ELEMENT_ICE ;tonberry


ENEMY_ELEMENT_ABSORB = * - 1
          !byte 0       ;green slime
          !byte 0       ;blue slime
          !byte 0       ;orc
          !byte 0       ;skelly
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 0       ;mist
          !byte 0       ;yellow skelly
          !byte ELEMENT_LIGHTNING     ;boss 1
          !byte ELEMENT_EARTH         ;boss 2
          !byte ELEMENT_FIRE          ;boss 3
          !byte ELEMENT_ICE           ;boss 4
          !byte 0       ;tonberry



ENEMY_DROP_ITEM = * - 1
          !byte ITEM_HERBS      ;green slime
          !byte ITEM_ANTIDOTE   ;blue slime
          !byte ITEM_FENIX_DOWN ;orc
          !byte ITEM_SWORD      ;skeleton
          !byte ITEM_FENIX_DOWN ;spectre
          !byte ITEM_HERBS      ;rollo
          !byte ITEM_FENIX_DOWN ;mist
          !byte ITEM_NONE       ;yellow skelly
          !byte ITEM_NONE       ;boss 1
          !byte ITEM_NONE       ;boss 2
          !byte ITEM_NONE       ;boss 3
          !byte ITEM_NONE       ;boss 4
          !byte ITEM_FENIX_DOWN ;tonberry

ENEMY_DROP_ITEM_CHANCE = * - 1
          !byte 20      ;green slime
          !byte 30      ;blue slime
          !byte 10      ;orc
          !byte 10      ;skeleton
          !byte 40      ;spectre
          !byte 20      ;rollo
          !byte 20      ;mist
          !byte 0       ;yellow skelly
          !byte 0       ;boss 1
          !byte 0       ;boss 2
          !byte 0       ;boss 3
          !byte 0       ;boss 4
          !byte 40      ;tonberry

ENEMY_STEAL_ITEM_CHANCE = * - 1
          !byte 30      ;green slime
          !byte 0       ;blue slime
          !byte 30      ;orc
          !byte 0       ;skeleton
          !byte 0       ;spectre
          !byte 0       ;rollo
          !byte 30      ;mist
          !byte 30      ;yellow skelly
          !byte 0       ;boss 1
          !byte 0       ;boss 2
          !byte 0       ;boss 3
          !byte 0       ;boss 4
          !byte 30      ;tonberry

ENEMY_STEAL_ITEM = * - 1
          !byte ITEM_FENIX_DOWN ;green slime
          !byte ITEM_NONE   ;blue slime
          !byte ITEM_STRENGTH_RING  ;orc
          !byte ITEM_NONE   ;skeleton
          !byte ITEM_NONE   ;spectre
          !byte ITEM_NONE   ;rollo
          !byte ITEM_DEFENSE_RING   ;mist
          !byte ITEM_KNIFE  ;yellow skelly
          !byte ITEM_NONE ;boss 1
          !byte ITEM_NONE ;boss 2
          !byte ITEM_NONE ;boss 3
          !byte ITEM_NONE ;boss 4
          !byte ITEM_COAT ;tonberry


ENEMY_TECH = * - 1
          !byte TECH_NONE     ;green slime
          !byte TECH_BIO      ;blue slime
          !byte TECH_NONE     ;orc
          !byte TECH_NONE     ;skeleton
          !byte TECH_NONE     ;spectre
          !byte TECH_NONE     ;rollo
          !byte TECH_NONE     ;mist
          !byte TECH_NONE     ;yellow skelly
          !byte TECH_NONE     ;boss 1
          !byte TECH_NONE     ;boss 2
          !byte TECH_NONE     ;boss 3
          !byte TECH_NONE     ;boss 4
          !byte TECH_QUAKE    ;tonberry

ENEMY_MULTI_COLORS = * - 1
          !byte $8b     ;green slime
          !byte $8b     ;blue slime
          !byte $8b     ;orc
          !byte $8b     ;skeleton
          !byte $8b     ;spectre
          !byte $8b     ;rollo
          !byte $8b     ;mist
          !byte $8b     ;yellow skelly
          !byte $a7     ;boss 1
          !byte $7d     ;boss 2
          !byte $a7     ;boss 3
          !byte $1e     ;boss 4
          !byte $8b     ;tonberry


;attack flags
;xNNN NNNN : NNNNNNN = id of special attack
;Pxxx xxxx : 1 = has simple physical attack


EA_PHYSICAL_ATTACK = $80

ENEMY_ATTACKS = * - 1
          !byte EA_PHYSICAL_ATTACK              ;green slime
          !byte EA_PHYSICAL_ATTACK | $01        ;blue slime
          !byte EA_PHYSICAL_ATTACK              ;star
          !byte EA_PHYSICAL_ATTACK              ;ZOMBIE
          !byte EA_PHYSICAL_ATTACK              ;spectre
          !byte EA_PHYSICAL_ATTACK              ;rollo
          !byte EA_PHYSICAL_ATTACK              ;mist
          !byte EA_PHYSICAL_ATTACK | $02        ;yellow skelly
          !byte EA_PHYSICAL_ATTACK | $03        ;boss 1
          !byte EA_PHYSICAL_ATTACK | $04        ;boss 2
          !byte EA_PHYSICAL_ATTACK | $05        ;boss 3
          !byte EA_PHYSICAL_ATTACK | $06        ;boss 4
          !byte EA_PHYSICAL_ATTACK              ;tonberry

ENEMY_SPECIAL_ATTACK_LIST_HI = * - 1
          !byte >SAL_BLUE_SLIME
          !byte >SAL_STUN
          !byte >SAL_BOSS_1
          !byte >SAL_BOSS_2
          !byte >SAL_BOSS_3
          !byte >SAL_BOSS_4

ENEMY_SPECIAL_ATTACK_LIST_LO = * - 1
          !byte <SAL_BLUE_SLIME
          !byte <SAL_STUN
          !byte <SAL_BOSS_1
          !byte <SAL_BOSS_2
          !byte <SAL_BOSS_3
          !byte <SAL_BOSS_4


