MENU_ENTRY_COUNT = 20




!zone ClearBattleMenu
ClearBattleMenu
          lda #11
          sta PARAM1
          lda #20
          sta PARAM2
          lda #11
          sta PARAM3
          lda #4
          sta PARAM4
          jmp ClearArea




!zone HandleMenu
;returns chosen item value in MENU_ITEM
HandleMenu
          lda #0
          sta MENU_ITEM
          sta MENU_ITEM_OFFSET

.RedisplayMenu
          jsr ClearBattleMenu
          jsr DisplayMenu

.MovedPointer
          lda #10
          sta PARAM1
          lda #20
          clc
          adc MENU_ITEM
          sta PARAM2
          jsr SetMenuPointer
          lda #20
          sta PARAM2

MenuLoop
          jsr WaitFrame

          jsr JoyReleasedUpPushed
          bne .NotUp

          lda MENU_ITEM
          beq +

          dec MENU_ITEM
          jmp .MovedPointer

+
          ;"scroll" up?
          lda MENU_ITEM_OFFSET
          beq .NoUpScroll

          lda MENU_ITEM_OFFSET
          sec
          sbc MENU_ITEM_VISIBLE_COUNT
          sta MENU_ITEM_OFFSET
          lda MENU_ITEM_VISIBLE_COUNT
          sta MENU_ITEM
          dec MENU_ITEM
          jmp .RedisplayMenu

.NoUpScroll
          ;find proper offset
          lda MENU_ITEM_COUNT
          sec
          sbc #1
          ;HACK - we should use MENU_ITEM_VISIBLE_COUNT, but we know it's four
          and #$fc
          sta MENU_ITEM_OFFSET
          lda MENU_ITEM_COUNT
          sec
          sbc #1
          sbc MENU_ITEM_OFFSET
          sta MENU_ITEM
          jmp .RedisplayMenu

.NotUp
          jsr JoyReleasedDownPushed
          bne .NotDown

          inc MENU_ITEM
          lda MENU_ITEM
          cmp MENU_ITEM_VISIBLE_COUNT
          bne +

          ;visual overflow
          cmp MENU_ITEM_COUNT
          beq .TotalOverflow

          lda MENU_ITEM_OFFSET
          clc
          adc MENU_ITEM_VISIBLE_COUNT
          sta MENU_ITEM_OFFSET
          lda #0
          sta MENU_ITEM
          jmp .RedisplayMenu

+
          lda MENU_ITEM_OFFSET
          clc
          adc MENU_ITEM
          cmp MENU_ITEM_COUNT
          bne .NotWrap

.TotalOverflow
          lda #0
          sta MENU_ITEM
          sta MENU_ITEM_OFFSET
          jmp .RedisplayMenu

.NotWrap
.NotDown
          jsr JoyReleasedFirePushed
          bne .NotFire

          ;disable
          ldx #SPRITE_INDEX_POINTER
          jsr RemoveObject

          ;calc final menu item
          lda MENU_ITEM_OFFSET
          clc
          adc MENU_ITEM
          sta MENU_ITEM

          jmp ClearBattleMenu

.NotFire
          lda PARAM2
          clc
          adc MENU_ITEM
          asl
          asl
          asl
          adc #49
          sta VIC_SPRITE_Y_POS + SPRITE_INDEX_POINTER * 2

          jmp MenuLoop



!zone DisplayTextOnTop
DisplayTextOnTop
          jsr ClearTopPanel
          lda #1
          sta PARAM1
          sta PARAM2
          jmp DisplayText




;PARAM1 = x
;PARAM2 = y
!zone DisplayMenu
DisplayMenu
          lda MENU_ITEM_VISIBLE_COUNT
          sta PARAM9
          ldx MENU_ITEM_OFFSET
-
          lda MENU_ENTRY_LO,x
          sta ZEROPAGE_POINTER_1
          lda MENU_ENTRY_HI,x
          beq .WasLastItem
          sta ZEROPAGE_POINTER_1 + 1

          jsr DisplayText
          inc PARAM2
          dec PARAM9
          beq .AllVisibleItemsDisplayed
          inx
          bne -


.AllVisibleItemsDisplayed
.WasLastItem
          rts


!zone HandleTopMenu
HandleTopMenu
          pla
          pla

          lda #<MENU_TEXT_TOP
          sta ZEROPAGE_POINTER_1
          lda #>MENU_TEXT_TOP
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayTextOnTop

          lda #0
          sta MENU_ITEM
          sta MENU_ITEM_OFFSET

          ;lda #1
          ;sta PARAM1
          ;sta PARAM2
          jsr SetMenuPointer

TopMenuLoop
          jsr WaitFrame

          jsr JoyReleasedFirePushed
          bne .NotFire

          lda VIC_SPRITE_ENABLE
          and #$fe
          sta VIC_SPRITE_ENABLE

          jsr ClearTopPanel

          ldy MENU_ITEM
          lda TOP_MENU_TARGETS_LO,y
          sta ZEROPAGE_POINTER_1
          lda TOP_MENU_TARGETS_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          jmp (ZEROPAGE_POINTER_1)

TOP_MENU_TARGETS_LO
          !byte <HandleInventory
          !byte <HandleEquip
          !byte <HandleUse
          !byte <ClearTopAndBackToGame

TOP_MENU_TARGETS_HI
          !byte >HandleInventory
          !byte >HandleEquip
          !byte >HandleUse
          !byte >ClearTopAndBackToGame


.NotFire
          jsr JoyReleasedLeftPushed
          bne .NotLeft

          dec MENU_ITEM
          jmp .PlacePointer

.NotLeft
          jsr JoyReleasedRightPushed
          bne .NotRight

          inc MENU_ITEM

.PlacePointer
          lda MENU_ITEM
          and #$03
          sta MENU_ITEM
          tay

          lda #1
          sta PARAM1
          sta PARAM2

          ;ldy MENU_ITEM
-
          beq .Done

          lda #11
          clc
          adc PARAM1
          sta PARAM1
          dey
          jmp -
.Done
          jsr SetMenuPointer

.NotRight

          jmp TopMenuLoop


;displays character info box (20x8)
;character index in CURRENT_INDEX
;CHARBOX_DISPLAY_TYPE = what to display in the boxes
;    SPT_STATS = char stats
;    SPT_EQUIP = equip info
!zone DisplayCharacterInfoBox
DisplayCharacterInfoBox
          lda #20
          sta PARAM3
          lda #8
          sta PARAM4
          jsr DisplayBox

          lda PARAM1
          sta PARAM9
          lda PARAM2
          sta PARAM10

          ldx CURRENT_INDEX
          lda FIGHTER_ACTIVE,x
          bne +
          jmp .PlayerNotActive
+
          lda PARTY_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda PARTY_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          inc PARAM1
          inc PARAM1
          inc PARAM2
          jsr DisplayText

          lda CHARBOX_DISPLAY_TYPE
          cmp #SPT_STATS
          beq +
          jmp .DisplayForEquip
+
          ;HP
          inc PARAM1
          inc PARAM2
          ldy CURRENT_INDEX
          ldx FIGHTER_HP_LO,y
          lda FIGHTER_HP_HI,y
          jsr Display16BitDecimal

          ;slashes
          ldy PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda PARAM1
          clc
          adc #4
          tay
          lda #45
          sta (ZEROPAGE_POINTER_1),y
          tya
          clc
          adc #40
          tay
          lda #45
          sta (ZEROPAGE_POINTER_1),y


          ;HP Max
          lda PARAM1
          clc
          adc #5
          sta PARAM1
          ldy CURRENT_INDEX
          ldx FIGHTER_HP_MAX_LO,y
          lda FIGHTER_HP_MAX_HI,y
          jsr Display16BitDecimal

          ;MP
          lda PARAM9
          sta PARAM1
          inc PARAM1
          inc PARAM1
          inc PARAM1
          inc PARAM2
          ldy CURRENT_INDEX
          ldx FIGHTER_MP_LO,y
          lda FIGHTER_MP_HI,y
          jsr Display16BitDecimal

          ;MP Max
          lda PARAM1
          clc
          adc #5
          sta PARAM1
          ldy CURRENT_INDEX
          ldx FIGHTER_MP_MAX_LO,y
          lda FIGHTER_MP_MAX_HI,y
          jsr Display16BitDecimal

          ;special states
          inc PARAM2
          inc PARAM2
          ldy CURRENT_INDEX
          lda FIGHTER_STATE,y
          and #STATUS_POISONED
          beq +

          lda #<TEXT_POISONED
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_POISONED
          sta ZEROPAGE_POINTER_1 + 1

          lda PARAM9
          sta PARAM1
          inc PARAM1
          inc PARAM1
          inc PARAM1
          jsr DisplayText

+
          jmp .DisplayStatsDone


.DisplayForEquip
          inc PARAM2
          inc PARAM2

          ;weapon
          lda #<TEXT_WEAPON
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_WEAPON
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda PARAM1
          clc
          adc #8
          sta PARAM1

          ;weapon name
          ldy CURRENT_INDEX
          ldx FIGHTER_WEAPON,y
          lda ITEM_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda PARAM9
          clc
          adc #2
          sta PARAM1
          inc PARAM2

          ;armour
          lda #<TEXT_ARMOUR
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_ARMOUR
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda PARAM1
          clc
          adc #8
          sta PARAM1

          ;armour name
          ldy CURRENT_INDEX
          ldx FIGHTER_ARMOUR,y
          lda ITEM_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda PARAM9
          clc
          adc #2
          sta PARAM1
          inc PARAM2

          ;relic
          lda #<TEXT_RELIC
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_RELIC
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda PARAM1
          clc
          adc #8
          sta PARAM1

          ;relic name
          ldy CURRENT_INDEX
          ldx FIGHTER_RELIC,y
          lda ITEM_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText


.DisplayStatsDone
          lda PARAM10
          sta PARAM2
          lda PARAM9
          sta PARAM1

.PlayerNotActive
          rts


!zone WaitForButton
WaitForButton
          jsr WaitFrame
          jsr JoyReleasedFirePushed
          bne WaitForButton

          rts

MENU_ITEM_COUNT     ;number of total items in menu
          !byte 0
MENU_ITEM_VISIBLE_COUNT
          !byte 0


;MENU_ITEM
;          !byte 0
;MENU_ITEM_OFFSET
;          !byte 0
MENU_ITEM_VALUE
          !fill MENU_ENTRY_COUNT,0
MENU_ENTRY_LO
          !fill MENU_ENTRY_COUNT,0
MENU_ENTRY_HI
          !fill MENU_ENTRY_COUNT,0



