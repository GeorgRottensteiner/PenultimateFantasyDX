;STATUS_EX_SHELL     = $01     ;magic defense
;STATUS_EX_PROTECT   = $02     ;defense
;STATUS_EX_ZOMBIE    = $04
;STATUS_EX_SHADOW    = $08
;STATUS_EX_SLOW      = $10
;STATUS_EX_STOP      = $20
;STATUS_EX_HASTE     = $40

STATUS_POISONED     = $01
;STATUS_SLEEPING     = $02
STATUS_KO           = $04
;STATUS_CONFUSED     = $08
;STATUS_BERSERK      = $10
STATUS_FROZEN       = $20
;STATUS_PETRIFIED    = $40
STATUS_JUMPED       = $80



!zone ApplyMapPoison
ApplyMapPoison
          lda FIGHTER_HP_LO,x
          sec
          sbc #2
          sta FIGHTER_HP_LO,x
          lda FIGHTER_HP_HI,x
          sbc #0
          sta FIGHTER_HP_HI,x
          bcc .Maxed

          lda FIGHTER_HP_LO,x
          ora FIGHTER_HP_HI,x
          bne +

.Maxed
          ;never below 1
          lda #1
          sta FIGHTER_HP_LO,x
          lda #0
          sta FIGHTER_HP_HI,x
+
          jmp DisplayFighterHP



;current_index or x
!zone ApplyFighterStats
ApplyFighterStats
          lda #0
          sta ATTACK_DAMAGE
          sta ATTACK_DAMAGE + 1

          ldx CURRENT_INDEX

          lda FIGHTER_STATE,x
          and #STATUS_FROZEN
          beq .NotFrozen

          dec FIGHTER_FROZEN_COUNT,x
          ;frozen skips poison stat
          bne .StillFrozen

          ;wake up
          lda FIGHTER_STATE,x
          and #~STATUS_FROZEN
          sta FIGHTER_STATE,x

.NotFrozen
          lda FIGHTER_STATE,x
          and #STATUS_POISONED
          beq .NotPoisoned

          ;Max HP / 32
          lda FIGHTER_HP_MAX_LO,x
          sta ATTACK_DAMAGE
          lda FIGHTER_HP_MAX_HI,x
          sta ATTACK_DAMAGE + 1

          ldy #5
          clc
-
          lsr ATTACK_DAMAGE + 1
          ror ATTACK_DAMAGE

          dey
          bne -

          ;minimum 2
          lda ATTACK_DAMAGE
          ora ATTACK_DAMAGE + 1
          bne +
          lda #2
          sta ATTACK_DAMAGE
+
          stx CURRENT_TARGET

          ldy #ATTACK_POISON_DAMAGE
          jsr PlayAttackAnimation

          ldx CURRENT_INDEX

;          Max Damage = (Max HP * stamina / 1024) + 2 (if this value is greater than
;          255 it is set to 255)
;          Damage = Max Damage * ([224..255]) / 256
;          If a character is poisoned (instead of a monster), Damage = Damage / 2
;
;          This damage is the amount of damage taken from Poison the first time in
;          combat. The second time, the damage is double; the third time it is tripled,
;          etc.  This damage levels off after the eighth round; in other words, the damage
;          taken from Poison in a round (for characters or monsters) can't exceed 8x what
;          it was the first round (random variance aside).
;
;          Outside of combat, the amount of damage done per step is : (Max HP / 32). This
;          will never reduce HP below 1.

.NotPoisoned
.StillFrozen
          rts



!zone LevelUp
LevelUp
          stx CURRENT_INDEX
          inc FIGHTER_LEVEL,x
          lda FIGHTER_LEVEL,x
          sta LOCAL1

          ;calc new HP  LEVEL + ( LEVEL / 8 ) * ( LEVEL / 8 )

          ; / 8
          lsr
          lsr
          lsr
          sta OPERAND_8BIT_1
          sta OPERAND_8BIT_2
          jsr Multiply8By8

          ldx CURRENT_INDEX

          lda OPERAND_16BIT_1
          clc
          adc FIGHTER_LEVEL,x
          sta OPERAND_16BIT_1
          sta LOCAL2
          lda OPERAND_16BIT_1 + 1
          adc #0
          sta OPERAND_16BIT_1 + 1
          sta LOCAL3

          lda OPERAND_16BIT_1
          clc
          adc FIGHTER_HP_MAX_LO,x
          sta FIGHTER_HP_MAX_LO,x
          lda OPERAND_16BIT_1 + 1
          adc FIGHTER_HP_MAX_HI,x
          sta FIGHTER_HP_MAX_HI,x

          ;MP
          lda FIGHTER_MP_MAX_LO,x
          ora FIGHTER_MP_MAX_HI,x
          beq .NoMPUpdate

          ;calc new MP  deltaHP + 2
          lda LOCAL2
          clc
          adc #2
          sta LOCAL2
          bcc +
          inc LOCAL3
+
          lda LOCAL2
          clc
          adc FIGHTER_MP_MAX_LO,x
          sta FIGHTER_MP_MAX_LO,x
          lda LOCAL3
          adc FIGHTER_MP_MAX_HI,x
          sta FIGHTER_MP_MAX_HI,x
.NoMPUpdate
          rts
          