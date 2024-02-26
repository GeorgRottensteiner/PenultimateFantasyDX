ITEM_NONE  = 0
ITEM_HERBS = 1
ITEM_ETHER = 2
ITEM_MAGIC_FIRE = 3
ITEM_FENIX_DOWN = 4
ITEM_ANTIDOTE = 5
ITEM_KNIFE = 6
ITEM_NOTHING = 7
ITEM_MAGIC_CURE = 8
ITEM_COAT = 9
ITEM_MAGIC_ICE = 10
ITEM_MAGIC_LIGHTNING  = 11
ITEM_CRYSTAL_ARMOR    = 12
ITEM_MAGIC_RAISE      = 13
ITEM_CRYSTAL          = 14
ITEM_SWORD            = 15
ITEM_STRENGTH_RING    = 16
ITEM_DEFENSE_RING     = 17

ITEM_USE_TARGET_SINGLE  = $01
ITEM_USE_TARGET_GROUP   = $02
ITEM_USE_TARGET_PARTY   = $04
ITEM_USE_TARGET_ENEMY   = $08
ITEM_USE_TARGET_ALL     = $0f
ITEM_USE_TARGET_MASK    = $0f

ITEM_USE_ONE_TIME       = $10
ITEM_USE_IN_BATTLE      = $20
ITEM_USE_IN_MAP         = $40
ITEM_USE_TARGET_ENEMY_FIRST = $80

;for item type


ITEM_TYPE_WEAPON                = $01
ITEM_TYPE_ARMOR                 = $02
ITEM_TYPE_RELIC                 = $04
ITEM_TYPE_MAGIC                 = $10
ITEM_TYPE_ITEM                  = $20


ELEMENT_FIRE        = $01
ELEMENT_ICE         = $02
ELEMENT_EARTH       = $04
ELEMENT_WIND        = $08
ELEMENT_HOLY        = $10
ELEMENT_DARKNESS    = $20
ELEMENT_LIGHTNING   = $40
ELEMENT_POISON      = $80



SPT_STATS = 0
SPT_EQUIP = 1



!zone SetFirstMenuItemToBack
SetFirstMenuItemToBack
          ldy #1
          sty MENU_ITEM_COUNT
          ldy #0
          sty MENU_ENTRY_HI + 1
          lda #$ff
          sta MENU_ITEM_VALUE

          lda #<ITEM_NAME_BACK
          sta MENU_ENTRY_LO
          lda #>ITEM_NAME_BACK
          sta MENU_ENTRY_HI
          rts



;a = item type mask
!zone FillMenuWithItems
FillMenuWithItems
          sta LOCAL1

          jsr SetFirstMenuItemToBack

          ldy #0
          sty LOCAL2

.CheckNextItem
          lda INVENTORY_SLOT,y
          beq .NoItem

          tax
          lda ITEM_TYPE,x
          and LOCAL1
          beq .NotThisItem

          ;add item
          ldy MENU_ITEM_COUNT
          txa
          sta MENU_ITEM_VALUE,y

          lda ITEM_NAME_LO,x
          sta MENU_ENTRY_LO,y
          lda ITEM_NAME_HI,x
          sta MENU_ENTRY_HI,y
          inc MENU_ITEM_COUNT

          ;mark next item as last item
          lda #0
          sta MENU_ENTRY_HI + 1,y

.NotThisItem
.NoItem
          inc LOCAL2
          ldy LOCAL2
          cpy #NUM_INVENTORY_ITEMS
          bne .CheckNextItem
          rts



!zone HandleInventory
HandleInventory
          lda #$ff
          jsr ChooseItem
          beq .NothingChosen


          tax
          ;use item

          lda ITEM_USE,x
          and #ITEM_USE_TARGET_MASK
          cmp #ITEM_USE_TARGET_PARTY
          bne +
          jmp ApplyItemOnParty
+
          and #ITEM_USE_TARGET_SINGLE
          beq +

          lda #SPT_STATS
          sta CHARBOX_DISPLAY_TYPE
          jsr ChooseSinglePartyTarget

          jmp ApplyItemToTarget



+
          ;TODO - does not work?
.NothingChosen
          jmp RestoreMapAndBackToGame



;a = item mask
;returns chosen item type in a
!zone ChooseItem
ChooseItem
          sta ITEM_MASK
          jsr ClearTopPanel

          lda #0
          sta MAP_ACTIVE
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

          ;display items
          lda #1
          sta PARAM1
          lda #4
          sta PARAM2
          jsr SetMenuPointer

          lda #2
          sta PARAM1
          lda #4
          sta PARAM2

          ldx #0
          ldy #0
          sty CURRENT_ITEM
          sty NUM_ITEMS_TO_CHOOSE

.CheckNextItem
          lda INVENTORY_SLOT,x
          beq .NoItem

          ldy INVENTORY_SLOT,x

          ;only items which fit the mask
          lda ITEM_TYPE,y
          beq .AddItem
          and ITEM_MASK
          beq .NoItem
.AddItem
          ldx NUM_ITEMS_TO_CHOOSE
          tya
          sta MENU_ITEM_VALUE,x

          lda ITEM_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          ;item count
          ldx CURRENT_ITEM
          lda PARAM1
          clc
          adc #15
          sta PARAM1
          lda INVENTORY_COUNT,x
          jsr Display2DigitDecimal
          lda PARAM1
          sec
          sbc #15
          sta PARAM1

          ;move display pos
          lda #23
          sec
          sbc PARAM1
          sta PARAM1
          cmp #2
          bne +
          inc PARAM2
+
          inc NUM_ITEMS_TO_CHOOSE

.NoItem
          inc CURRENT_ITEM
          ldx CURRENT_ITEM
          cpx #NUM_INVENTORY_ITEMS
          bne .CheckNextItem

          lda #0
          sta MENU_ITEM

.SetPointer
          lda MENU_ITEM
          lsr
          clc
          adc #4
          sta PARAM2

          lda #1
          sta PARAM1

          lda MENU_ITEM
          and #$01
          beq +
          lda #20
          sta PARAM1
+
          jsr SetMenuPointer

InventoryLoop
          jsr WaitFrame

          jsr JoyReleasedFirePushed
          bne .NotFire

          ;item chosen
          ldy MENU_ITEM
          lda MENU_ITEM_VALUE,y
          rts

.NotFire
          jsr JoyReleasedRightPushed
          bne .NotRight

          inc MENU_ITEM
          lda MENU_ITEM
          cmp NUM_ITEMS_TO_CHOOSE
          bne +
          lda #0
          sta MENU_ITEM
+
          jmp .SetPointer

.NotRight
          jsr JoyReleasedLeftPushed
          bne .NotLeft

          lda MENU_ITEM
          bne +

          lda NUM_ITEMS_TO_CHOOSE
          sta MENU_ITEM
+
          dec MENU_ITEM
          jmp .SetPointer

.NotLeft
          jsr JoyReleasedUpPushed
          bne .NotUp

          lda MENU_ITEM
          sec
          sbc #2
          bpl ++

          ;moved off the top, abort choosing
          lda #ITEM_NONE
          rts

++
          sta MENU_ITEM
          jmp .SetPointer

.NotUp
          jsr JoyReleasedDownPushed
          bne .NotDown

          lda MENU_ITEM
          clc
          adc #2
          cmp NUM_ITEMS_TO_CHOOSE
          bcc ++

          and #$01
++
          sta MENU_ITEM
          jmp .SetPointer

.NotDown
          jmp InventoryLoop


;choose one of three slots
;character in CURRENT_INDEX
;returns chosen slot in CURRENT_TARGET
!zone ChooseEquipmentSlot
ChooseEquipmentSlot
          lda VIC_SPRITE_Y_POS
          clc
          adc #16
          sta VIC_SPRITE_Y_POS
          sta PARAM5

          lda #0
          sta CURRENT_TARGET

.EquipLoop
          jsr WaitFrame

          jsr JoyReleasedFirePushed
          bne .NotDone
          rts

.NotDone
          jsr JoyReleasedDownPushed
          bne .NotDown

          inc CURRENT_TARGET
          lda CURRENT_TARGET
          cmp #3
          bne +
          lda #0
          sta CURRENT_TARGET
+
.SetPointer
          asl
          asl
          asl
          clc
          adc PARAM5
          sta VIC_SPRITE_Y_POS
          jmp .EquipLoop

.NotDown
          jsr JoyReleasedUpPushed
          bne .EquipLoop

          dec CURRENT_TARGET
          bpl +
          lda #2
          sta CURRENT_TARGET
+
          lda CURRENT_TARGET
          jmp .SetPointer



;CHARBOX_DISPLAY_TYPE = what to display in the boxes
;    SPT_STATS = char stats
;    SPT_EQUIP = equip info
;    returns chosen member in CURRENT_INDEX
!zone ChooseSinglePartyTarget
ChooseSinglePartyTarget
          lda MENU_ITEM
          sta PARAM10
          sty PARAM9

          ;display character info boxes
          ldx #0
          stx CURRENT_INDEX

          lda #0
          sta PARAM1
          lda #3
          sta PARAM2
-
          ldy PARAM9
          jsr DisplayCharacterInfoBox

          lda #20
          sec
          sbc PARAM1
          sta PARAM1
          bne +
          lda PARAM2
          clc
          adc #8
          sta PARAM2
+

          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #4
          bne -

          ldx #0
          stx CURRENT_INDEX
          jmp .SetPointer

ChooseSinglePartyTargetLoop
          jsr WaitFrame

          jsr JoyReleasedFirePushed
          bne +

          ;is alive?
          ldx CURRENT_INDEX
          lda FIGHTER_ACTIVE,x
          beq ChooseSinglePartyTargetLoop

          rts
+
          jsr JoyReleasedLeftPushed
          beq .XChange
          jsr JoyReleasedRightPushed
          beq .XChange

          jsr JoyReleasedUpPushed
          beq .YChange
          jsr JoyReleasedDownPushed
          beq .YChange

          jmp ChooseSinglePartyTargetLoop

.XChange
          lda CURRENT_INDEX
          eor #$01
          sta CURRENT_INDEX
          jmp .SetPointer

.YChange
          lda CURRENT_INDEX
          eor #$02
          sta CURRENT_INDEX

.SetPointer
          lda #1
          sta PARAM1

          lda CURRENT_INDEX
          and #$01
          beq +
          lda #21
          sta PARAM1
+

          lda #4
          sta PARAM2

          lda CURRENT_INDEX
          cmp #2
          bcc +
          lda #4 + 8
          sta PARAM2
+
          jsr SetMenuPointer
          jmp ChooseSinglePartyTargetLoop



!zone ApplyItemOnParty
ApplyItemOnParty
          jmp RestoreMapAndBackToGame


!zone HandleEquip
HandleEquip
          lda #0
          sta MAP_ACTIVE
          sta VIC_SPRITE_ENABLE
          lda #SPT_EQUIP
          sta CHARBOX_DISPLAY_TYPE
          jsr ChooseSinglePartyTarget

          ;puts slot in CURRENT_TARGET
          jsr ChooseEquipmentSlot

          ldx CURRENT_TARGET
          lda EQUIPMENT_ITEM_MASK,x
          jsr ChooseItem
          sta LOCAL1
          cmp #ITEM_NONE
          beq .AbortEquip

          ;slot * NUM_FIGHTERS + index
          ldy CURRENT_TARGET
          lda CURRENT_INDEX
          clc
          adc SLOT_OFFSET,y
          tay

          ;indices into armor/relic! (handled by adding 10
          lda FIGHTER_WEAPON,y
          sta LOCAL2
          lda LOCAL1
          sta FIGHTER_WEAPON,y
          jsr RemoveItemFromInventory

          lda LOCAL2
          jsr AddItemToInventory
.AbortEquip
          jmp RestoreMapAndBackToGame



!zone RestoreMapAndBackToGame
RestoreMapAndBackToGame
          lda VIC_SPRITE_ENABLE
          and #$fe
          sta VIC_SPRITE_ENABLE

          ;return to map
          jsr JumpToMap

ClearTopAndBackToGame
          jsr ClearTopPanel
          jmp GameLoop


;add item (in A)
!zone AddItemToInventory
AddItemToInventory
          sta LOCAL1

          ;try to stack first
          ldx #0
-
          lda INVENTORY_SLOT,x
          cmp LOCAL1
          beq .AddHere

          inx
          cpx #NUM_INVENTORY_ITEMS
          bne -

          ;add in free slot
          ldx #0
-
          lda INVENTORY_SLOT,x
          bne +

          lda LOCAL1
          sta INVENTORY_SLOT,x
          jmp .AddHere2
+
          inx
          cpx #NUM_INVENTORY_ITEMS
          bne -

          ;should never ever happen, inventory full
          rts

.AddHere
          ;do not inc count for "empty"
          cmp #ITEM_NOTHING
          bne +
          rts
+


.AddHere2
          lda INVENTORY_COUNT,x
          cmp #99
          beq .SkipOverflow

          inc INVENTORY_COUNT,x

.SkipOverflow
          rts



;remove item (in A)
;returns 0 if failed, 1 if successfully removed
!zone RemoveItemFromInventory
RemoveItemFromInventory
          sta LOCAL1
          cmp #ITEM_NOTHING
          bne +

          ;already returns 0
          rts
+

          ldx #0
-
          lda INVENTORY_SLOT,x
          cmp LOCAL1
          beq .RemoveHere

          inx
          cpx #NUM_INVENTORY_ITEMS
          bne -

          lda #0
          rts

.RemoveHere
          dec INVENTORY_COUNT,x
          bne +

          ;was last item
          lda #0
          sta INVENTORY_SLOT,x
+
          lda #1
          rts



;item index is MENU_ITEM
;target index is CURRENT_INDEX
!zone ApplyItemToTarget
ApplyItemToTarget
          ldy MENU_ITEM
          lda MENU_ITEM_VALUE,y

          tax
          lda ITEM_ANIMATION,x
          cmp #ATTACK_NONE
          beq .DoNothing

          lda ITEM_USE,x
          and #ITEM_USE_ONE_TIME
          beq .ItemCanBeReused

          txa
          jsr RemoveItemFromInventory

          ldy MENU_ITEM
          ldx MENU_ITEM_VALUE,y

.ItemCanBeReused
          lda ITEM_ANIMATION,x
          tay
          ldx CURRENT_INDEX
          stx CURRENT_TARGET

          jsr PlayAttackAnimationWithoutDisplay

.DoNothing
          jmp RestoreMapAndBackToGame


;a = lo
;y = hi
;x = index
!zone IncreaseFighterMP
IncreaseFighterMP
          sta LOCAL1

          lda FIGHTER_ACTIVE,x
          beq .NothingToDo

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne .NothingToDo

          lda LOCAL1
          clc
          adc FIGHTER_MP_LO,x
          sta FIGHTER_MP_LO,x
          tya
          adc FIGHTER_MP_HI,x
          sta FIGHTER_MP_HI,x

CapFighterMP
          ;hit max?
          lda FIGHTER_MP_MAX_LO,x
          sec
          sbc FIGHTER_MP_LO,x
          lda FIGHTER_MP_MAX_HI,x
          sbc FIGHTER_MP_HI,x
          bcs +

          ;hit max
          lda FIGHTER_MP_MAX_LO,x
          sta FIGHTER_MP_LO,x
          lda FIGHTER_MP_MAX_HI,x
          sta FIGHTER_MP_HI,x

+
.NothingToDo
          jsr DisplayFighterMP
          rts



;a = lo
;y = hi
;x = index
!zone IncreaseFighterHP
IncreaseFighterHP
          sta LOCAL1

          lda FIGHTER_ACTIVE,x
          beq .NothingToDo

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne .NothingToDo

          lda LOCAL1
          clc
          adc FIGHTER_HP_LO,x
          sta FIGHTER_HP_LO,x
          tya
          adc FIGHTER_HP_HI,x
          sta FIGHTER_HP_HI,x

CapFighterHP
          ;hit max?
          lda FIGHTER_HP_MAX_LO,x
          sec
          sbc FIGHTER_HP_LO,x
          lda FIGHTER_HP_MAX_HI,x
          sbc FIGHTER_HP_HI,x
          bcs +

          ;hit max
          lda FIGHTER_HP_MAX_LO,x
          sta FIGHTER_HP_LO,x
          lda FIGHTER_HP_MAX_HI,x
          sta FIGHTER_HP_HI,x

+
          jsr DisplayFighterHP
.NothingToDo
          rts





ITEM_TYPE = * - 1
          !byte ITEM_TYPE_ITEM                    ;herbs
          !byte ITEM_TYPE_ITEM                    ;ether
          !byte ITEM_TYPE_MAGIC                   ;fire
          !byte ITEM_TYPE_ITEM                    ;fenix down
          !byte ITEM_TYPE_ITEM                    ;antidote
          !byte ITEM_TYPE_WEAPON                  ;knife
          !byte ITEM_TYPE_WEAPON | ITEM_TYPE_ARMOR | ITEM_TYPE_RELIC   ;empty slot (equipment)
          !byte ITEM_TYPE_MAGIC                   ;cure
          !byte ITEM_TYPE_ARMOR                   ;coat
          !byte ITEM_TYPE_MAGIC                   ;ice
          !byte ITEM_TYPE_MAGIC                   ;lightning
          !byte ITEM_TYPE_ARMOR                   ;crystal armor
          !byte ITEM_TYPE_MAGIC                   ;raise
          !byte ITEM_TYPE_ITEM                    ;crystal
          !byte ITEM_TYPE_WEAPON                  ;sword
          !byte ITEM_TYPE_RELIC                   ;strength ring
          !byte ITEM_TYPE_RELIC                   ;defense ring

ITEM_USE = * - 1
          !byte ITEM_USE_TARGET_SINGLE | ITEM_USE_ONE_TIME | ITEM_USE_IN_BATTLE | ITEM_USE_IN_MAP     ;herbs
          !byte ITEM_USE_TARGET_SINGLE | ITEM_USE_ONE_TIME | ITEM_USE_IN_BATTLE | ITEM_USE_IN_MAP     ;ether
          !byte ITEM_USE_TARGET_ALL | ITEM_USE_TARGET_ENEMY_FIRST                                     ;fire
          !byte ITEM_USE_TARGET_SINGLE | ITEM_USE_ONE_TIME | ITEM_USE_IN_BATTLE | ITEM_USE_IN_MAP     ;fenix down
          !byte ITEM_USE_TARGET_SINGLE | ITEM_USE_ONE_TIME | ITEM_USE_IN_BATTLE | ITEM_USE_IN_MAP     ;antidote
          !byte ITEM_USE_TARGET_ENEMY_FIRST                                                           ;knife
          !byte 0                                                                                     ;empty equipment slot
          !byte ITEM_USE_TARGET_ALL | ITEM_USE_IN_MAP                                                 ;cure
          !byte 0                                                                                     ;coat
          !byte ITEM_USE_TARGET_ALL | ITEM_USE_TARGET_ENEMY_FIRST                                     ;ice
          !byte ITEM_USE_TARGET_ALL | ITEM_USE_TARGET_ENEMY_FIRST                                     ;lightning
          !byte 0                                                                                     ;armor
          !byte ITEM_USE_TARGET_SINGLE                                                                ;raise
          !byte 0                                                                                     ;crystal
          !byte ITEM_USE_TARGET_ENEMY_FIRST                                                           ;sword
          !byte 0                                                                                     ;strength ring
          !byte 0                                                                                     ;defense ring



ITEM_ANIMATION = * - 1
          !byte ATTACK_ITEM_HERBS
          !byte ATTACK_ITEM_ETHER
          !byte ATTACK_MAGIC_FIRE
          !byte ATTACK_ITEM_FENIX_DOWN
          !byte ATTACK_ITEM_ANTIDOTE          ;antidote
          !byte ATTACK_SWORD
          !byte ATTACK_NONE
          !byte ATTACK_MAGIC_CURE
          !byte ATTACK_NONE                   ;coat
          !byte ATTACK_MAGIC_ICE
          !byte ATTACK_MAGIC_LIGHTNING
          !byte ATTACK_NONE                   ;armor
          !byte ATTACK_MAGIC_RAISE            ;magic raise
          !byte ATTACK_NONE                   ;crystal
          !byte ATTACK_SWORD                  ;sword
          !byte ATTACK_NONE                   ;strength ring
          !byte ATTACK_NONE                   ;defense ring


ITEM_HIT_RATE = * - 1
ITEM_HP_VALUE = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 180     ;knife
          !byte 100     ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 210     ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring


ITEM_ATTACK_POWER = * - 1
ITEM_MP_VALUE = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 25      ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 50      ;sword
          !byte 10      ;strength ring
          !byte 0       ;defense ring


ITEM_DEFENSE = * - 1
ITEM_STATE_ADD = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 140     ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 210     ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 10      ;defense ring

ITEM_MASK
          !byte 0
CURRENT_ITEM
          !byte 0
NUM_ITEMS_TO_CHOOSE
          !byte 0



ITEM_MAGIC_DEFENSE = * - 1
ITEM_STATE_REMOVE = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 3       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 150     ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 10      ;defense ring

!if 0 {
ITEM_EVASION = * - 1
ITEM_STATE_EX_ADD = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring

ITEM_ELEMENT = * - 1
ITEM_STATE_EX_REMOVE = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring

ITEM_ELEMENT_WEAK = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring
}

ITEM_ELEMENT_RESISTANCE = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte ELEMENT_EARTH | ELEMENT_FIRE | ELEMENT_ICE | ELEMENT_LIGHTNING ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring

!if 0 {
ITEM_ELEMENT_ABSORB = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring

ITEM_ELEMENT_IMMUNE = * - 1
          !byte 0       ;herbs
          !byte 0       ;ether
          !byte 0       ;magic fire
          !byte 0       ;fenix down
          !byte 0       ;antidote
          !byte 0       ;knife
          !byte 0       ;empty
          !byte 0       ;magic cure
          !byte 0       ;coat
          !byte 0       ;magic ice
          !byte 0       ;magic lightning
          !byte 0       ;crystal armor
          !byte 0       ;magic raise
          !byte 0       ;crystal
          !byte 0       ;sword
          !byte 0       ;strength ring
          !byte 0       ;defense ring
}



