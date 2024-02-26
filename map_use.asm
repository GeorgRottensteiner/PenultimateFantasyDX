!zone HandleUse
HandleUse
          ;check for character
          lda NEW_CHARACTER_POS
          cmp #$ff
          beq .NoCharacter

          clc
          adc #20
          cmp MAP_POS
          bne .NoCharacter

          ldx NEW_CHARACTER_ID
          dex
          jsr AddFighterToParty

          ldx NEW_CHARACTER_ID
          dex
          lda PARTY_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda PARTY_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1
          lda #1
          sta PARAM1
          sta PARAM2
          jsr DisplayText

          lda PARAM5
          sec
          adc PARAM1
          sta PARAM1

          lda #<TEXT_JOINS
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_JOINS
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText


          jsr DisplayPartyValues
          jsr DisplayPlayerNames
          jsr DisplayMap

          jsr WaitForButton

          jmp ClearTopAndBackToGame


.NoCharacter
          ;check for action spot
          ldx #0
-
          stx CURRENT_INDEX
          cpx NUM_ACTION_SPOTS
          beq .NoMoreActionSlots

          lda ACTION_SPOT_POS,x
          cmp MAP_POS
          bne .NotThisSpot

          lda ACTION_SPOT_TYPE,x
          cmp #AST_ANIM
          beq .Anim

          cmp #AST_ITEM
          bne .NotItem

          ;these types work only once
          lda ACTION_SPOT_HAPPEN,x
          jsr IsHappenSet
          bne .NotThisSpot

          ldx CURRENT_INDEX
          lda ACTION_SPOT_ITEM,x
          jsr RemoveItemFromInventory
          beq .NotThisSpot
          ldx CURRENT_INDEX

.NotItem
          ;toggle happen
          lda ACTION_SPOT_HAPPEN,x
          jsr ToggleHappen

          jsr DisplayMap
          jmp GameLoop


.Anim
          lda #ATTACK_TARGET_PARTY
          sta ATTACK_TARGET

          ldy ACTION_SPOT_SCRIPT,x
          jsr PlayAttackAnimation
          jmp ClearTopAndBackToGame


.NotThisSpot
          ldx CURRENT_INDEX
          inx
          jmp -



.NoMoreActionSlots
          ;check for chests
          ldx #0
-
          cpx NUM_LOCAL_CHESTS
          beq .NoMoreChests

          lda CHEST_INDEX,x
          beq .ChestIsEmpty

          lda PARTY_POS_X
          cmp CHEST_X,x
          sta PARAM1
          bne +

          lda PARTY_POS_Y
          sec
          sbc #1
          cmp CHEST_Y,x
          sta PARAM2
          bne +

          ;found chest, open it
          lda CHEST_INDEX,x
          tay
          dey

          ;mark as open locally
          lda #0
          sta CHEST_INDEX,x

          ;mark as open globally
          lda CHEST_CONTENT,y
          bmi .ChestIsEmpty
          sta PARAM9
          ora #$80
          sta CHEST_CONTENT,y
          and #$7f
          jsr AddItemToInventory

          ldx PARAM1
          ldy PARAM2
          jsr CalcPosFromXY
          lda #TILE_CHEST_OPEN
          sta PARAM3

          jsr DisplayTile

          lda #<TEXT_YOU_FOUND
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_YOU_FOUND
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayTextOnTop

          lda #11
          sta PARAM1
          ldy PARAM9
          lda ITEM_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda ITEM_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          jsr WaitForButton

          jmp ClearTopAndBackToGame

+
.ChestIsEmpty
          inx
          jmp -




.NoMoreChests
          ;display nothing special
          lda #<TEXT_NOTHING_SPECIAL
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_NOTHING_SPECIAL
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayTextOnTop
          jsr WaitForButton
          jmp ClearTopAndBackToGame
