!zone Title
Title
          jsr WaitFrame
          lda #0
          sta MAP_ACTIVE
!ifdef MUSIC_ACTIVE {
          jsr MUSIC_PLAYER
}
          lda #1
          sta TITLE_ACTIVE

          jsr SetupPanelVisuals

          lda #0
          sta VIC_SPRITE_ENABLE

          ;top box
          lda #0
          sta PARAM1
          sta PARAM2
          lda #40
          sta PARAM3
          lda #25
          sta PARAM4
          jsr DisplayBox

          lda #10
          sta PARAM1
          lda #3
          sta PARAM2
          lda #<TEXT_TITLE
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_TITLE
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda #7
          sta PARAM1
          lda #8
          sta PARAM2
          lda #<TEXT_QUEST
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_QUEST
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          lda #7
          sta PARAM1
          lda #15
          sta PARAM2
          lda #<TEXT_CREDITS_1
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_CREDITS_1
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          ;lda #5
          ;sta PARAM1
          lda #17
          sta PARAM2
          lda #<TEXT_CREDITS_2
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_CREDITS_2
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

          ;lda #5
          ;sta PARAM1
          lda #19
          sta PARAM2
          lda #<TEXT_CREDITS_3
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_CREDITS_3
          sta ZEROPAGE_POINTER_1 + 1
          jsr DisplayText

-
          jsr WaitFrame

          jsr JoyReleasedFirePushed
          bne -

          dec TITLE_ACTIVE
          jmp StartGame