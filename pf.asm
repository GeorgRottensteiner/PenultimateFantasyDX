;CHEAT = 1
MUSIC_ACTIVE = 1

!ifdef CHEAT {
CHEAT_LEVEL99 = 99
CHEAT_FULL_PARTY
CHEAT_FULL_EQUIPMENT
CHEAT_FILLED_INVENTORY
CHEAT_ALL_TECHNICS
!to "pfcheat.prg",cbm
} else {
CHEAT_LEVEL99 = 1

!to "pf.prg",cbm
}

TILE_INDEX_BLOCKING = 11
TILE_FLOOR          = 7
TILE_CHEST_CLOSED   = 16
TILE_CHEST_OPEN     = 17
TILE_SWITCH_DOWN    = 29
TILE_FLOOR_BLOCKING = 30



!ifdef BUILD_CARTRIDGE {
          *=$0810
} else {
          *=$0801
          ;basic start
          !byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00,$00,$00
}


;screen back    = $0400

;battle-charset = $c000 to $c7ff
;screen char    = $cc00
;sprites        = $d000
;charset        = $f800


!ct 'A',0,'B',1,'C',2,'D',3,'E',4,'F',5,'G',6,'H',7,'I',8,'J',9,'K',10,'L',11,'M',12,'N',13,'O',14,'P',15,'Q',16,'R',17,'S',18,'T',19,'U',20,'V',21,'W',22,'X',23,'Y',24,'Z',25,' ',32,
!ct 'a',$80,'b',$81,'c',$82,'d',$83,'e',$84,'f',$85,'g',$86,'h',$87,'i',$88,'j',$89,'k',$8a,'l',$8b,'m',$8c,'n',$8d,'o',$8e,'p',$8f,'q',$90,'r',$91,'s',$92,'t',$93,'u',$94,'v',$95,'w',$96,'x',$97,'y',$98,'z',$99
!ct '0',33,'1',34,'2',35,'3',36,'4',37,'5',38,'6',39,'7',40,'8',41,'9',42,'/',45,'!',46



;DEBUG_MODE = 1

RASTER_END_OF_PANEL_TOP = 73
RASTER_START_OF_PANEL_BOTTOM = 202

SCREEN_CHAR     = $CC00
SCREEN_BACK     = $0400
SCREEN_COLOR    = $d800

SPRITE_INDEX_POINTER            = 0
SPRITE_INDEX_ATTACK_ANIM_FRONT  = 0

CHARSET_LOCATION          = $f800
BATTLE_CHARSET_LOCATION   = $c000
BATTLE_CHARS_START  = 192
BATTLE_CHARS        = BATTLE_CHARSET_LOCATION + BATTLE_CHARS_START * 8
BATTLE_TIMER_CHAR_LOCATION  = BATTLE_CHARSET_LOCATION + 48 * 8

PARAM1                  = $03
PARAM2                  = $04
PARAM3                  = $05
PARAM4                  = $06
PARAM5                  = $07
PARAM6                  = $08
PARAM7                  = $09
PARAM8                  = $0A
PARAM9                  = $0B
PARAM10                 = $0C

LOCAL1                  = $0d
LOCAL2                  = $0e
LOCAL3                  = $0f
LOCAL4                  = $10
LOCAL5                  = $11
CURRENT_INDEX           = $12
CURRENT_TARGET          = $13
MENU_ITEM               = $14
MENU_ITEM_OFFSET        = $15
ATTACK_DAMAGE           = $16 ;to $18
FIGHTER_ACTIVE          = $19 ;to $22
MAP_POS                 = $23
CURRENT_CHAR_INDEX      = $24
ATTACK_ANIM_NO_DISPLAY  = $25
PLAY_ANIM_POS           = $26

ZEROPAGE_POINTER_1 = $27
ZEROPAGE_POINTER_2 = $29
ZEROPAGE_POINTER_3 = $2b
ZEROPAGE_POINTER_4 = $2d
ZEROPAGE_POINTER_5 = $2f
CURRENT_MAP_DATA   = $31

VIC_SPRITE_X_POS        = $d000
VIC_SPRITE_Y_POS        = $d001
VIC_SPRITE_X_EXTEND     = $d010
VIC_CONTROL_MODE        = $d011
VIC_RASTER_POS          = $d012
VIC_SPRITE_ENABLE       = $d015
VIC_CONTROL             = $d016
VIC_SPRITE_EXPAND_Y     = $d017
VIC_MEMORY_CONTROL      = $d018
VIC_SPRITE_PRIORITY     = $d01b
VIC_SPRITE_MULTICOLOR   = $d01c
VIC_SPRITE_EXPAND_X     = $d01d
VIC_SPRITE_MULTICOLOR_1 = $d025
VIC_SPRITE_MULTICOLOR_2 = $d026
VIC_SPRITE_COLOR        = $d027

VIC_BORDER_COLOR        = $d020
VIC_BACKGROUND_COLOR    = $d021
VIC_CHARSET_MULTICOLOR_1= $d022
VIC_CHARSET_MULTICOLOR_2= $d023

KERNAL_GETIN            = $ffe4

IRQ_RETURN_KERNAL       = $ea81
IRQ_RETURN_KERNAL_KEYBOARD  = $ea31

JOYSTICK_PORT_II        = $dc00

CIA_PRA                 = $dd00

PROCESSOR_PORT          = $01


SPRITE_POINTER_BASE           = SCREEN_CHAR + 1016

MD_COLORS                     = 160
MD_EXIT_N                     = 161
MD_EXIT_E                     = 162
MD_EXIT_S                     = 163
MD_EXIT_W                     = 164
MD_LOCAL_FORMATION_GROUP      = 165     ;MSB set means additional data is following

!ifdef BUILD_CARTRIDGE {
          ;testing ALZ
          jsr $fd50
          jsr $fd15

}

          ;LDA $DD00
          ;AND #$FC
          lda #$14
          STA $DD00

          LDA #$3e
          STA VIC_MEMORY_CONTROL

          ; ??
          LDA #$CC
          STA $0288

          lda #00
          sta VIC_BACKGROUND_COLOR
          sta VIC_BORDER_COLOR
          sta ATTACK_ANIM_NO_DISPLAY

          sei
          lda #$34
          sta PROCESSOR_PORT

          ldx #0
-
          lda BATTLE_CHARSET,x
          sta BATTLE_CHARSET_LOCATION,x
          lda BATTLE_CHARSET + 192,x
          sta BATTLE_CHARSET_LOCATION + 192,x
          inx
          cpx #192
          bne -

          LDA #<CHARSET
          STA ZEROPAGE_POINTER_1
          LDA #>CHARSET
          STA ZEROPAGE_POINTER_1+1
          LDA #<CHARSET_LOCATION
          STA ZEROPAGE_POINTER_2
          LDA #>CHARSET_LOCATION
          STA ZEROPAGE_POINTER_2+1

          ;copy normal charset + battle-charset in one go
          ;LDX #$00
          LDY #$00

NEXTLINE  LDA (ZEROPAGE_POINTER_1),Y
          STA (ZEROPAGE_POINTER_2),Y
          ;INX
          INY
          ;CPX #$08
          ;BNE NEXTLINE
          ;CPY #$00
          BNE NCHAR
          INC ZEROPAGE_POINTER_1+1
          INC ZEROPAGE_POINTER_2+1

NCHAR
          lda ZEROPAGE_POINTER_2 + 1
          beq CDONE3
          ;ldx #$00
          bne NEXTLINE

CDONE3


!if 0 {
          ;copy sprites
          ldx #0
-
          lda SPRITES,x
          sta $d000,x
          lda SPRITES + $100,x
          sta $d000 + $100,x
          lda SPRITES + $200,x
          sta $d000 + $200,x
          lda SPRITES + $300,x
          sta $d000 + $300,x

          inx
          bne -
}
          lda #<SPRITES
          sta ZEROPAGE_POINTER_1
          lda #>SPRITES
          sta ZEROPAGE_POINTER_1+1

          ;jsr CopySprites
          ;copy sprites to target
          ldy #$00
          ldx #$00

          lda #00
          sta ZEROPAGE_POINTER_2
          lda #$d0
          sta ZEROPAGE_POINTER_2+1

          ;4 sprites auf einmal
spriteloop
          lda (ZEROPAGE_POINTER_1),y
          sta (ZEROPAGE_POINTER_2),y
          iny
          bne spriteloop
          inx
          inc ZEROPAGE_POINTER_1+1
          inc ZEROPAGE_POINTER_2+1
          cpx #4
          bne spriteloop

          lda #$35
          sta PROCESSOR_PORT


          lda #$7f ;disable cia #1 generating timer irqs
          sta $dc0d ;which are used by the system to flash cursor, etc

          lda $dc0d ;acknowledge any pending cia timer interrupts
          lda $dd0d ;this is just so we're 100% safe

          cli

          lda #$18
          sta VIC_CONTROL

          ;SPRITEFARBEN
          LDA #10
          STA VIC_SPRITE_MULTICOLOR_1
          LDA #9
          STA VIC_SPRITE_MULTICOLOR_2

          ;full volume
          ;lda #15
          ;sta $d418

          ;game init
          jsr ResetGameStats

          ;enable display
          lda #$1b
          sta VIC_CONTROL_MODE

;!ifdef MUSIC_ACTIVE {
;          lda #0
;          jsr MUSIC_PLAYER
;}
          jsr WaitFrame
          jsr InitInGameIRQ

          jmp Title


!zone StartGame
StartGame
          lda #1
          sta NO_DISPLAY

          ;top box
          lda #0
          sta PARAM1
          sta PARAM2
          lda #40
          sta PARAM3
          lda #2
          sta PARAM4
          jsr DisplayBox


          ;menu box
          ;lda #0
          ;sta PARAM1
          lda #19
          sta PARAM2
          lda #10
          sta PARAM3
          lda #6
          sta PARAM4
          jsr DisplayBox

          ;party box
          lda #10
          sta PARAM1
          lda #19
          sta PARAM2
          lda #30
          sta PARAM3
          lda #6
          sta PARAM4
          jsr DisplayBox

          lda #7    ;H
          sta SCREEN_CHAR + 19 * 40 + 30
          lda #15   ;P
          sta SCREEN_CHAR + 19 * 40 + 31
          sta SCREEN_CHAR + 19 * 40 + 36
          lda #12   ;M
          sta SCREEN_CHAR + 19 * 40 + 35

          jsr GenerateRandomNumber
          and #$1f
          sta PARTY_STEPS_TO_AUTO_FIGHT

          jsr DisplayMap

          ;display fighter 1
          lda #38
          sta PARAM1
          lda #19
          sta PARTY_POS_X
          lda #4 + 8
          sta PARAM2
          lda #4
          sta PARTY_POS_Y
          lda #1
          sta PARAM3
          ldx #2
          jsr DoSpawnObject

          lda #(38 / 2 + 8 / 2 * 20)
          sta MAP_POS

          jsr DisplayPlayerNames

          ;clear battle timer chars
          jsr ClearBattleTimerChars

          lda #48
          sta SCREEN_CHAR + 20 * 40 + 22
          lda #49
          sta SCREEN_CHAR + 21 * 40 + 22
          lda #50
          sta SCREEN_CHAR + 22 * 40 + 22
          lda #51
          sta SCREEN_CHAR + 23 * 40 + 22

!ifdef CHEAT_FULL_EQUIPMENT {
          lda #ITEM_CRYSTAL_ARMOR
          sta FIGHTER_ARMOUR
          sta FIGHTER_ARMOUR + 1
          sta FIGHTER_ARMOUR + 2
          sta FIGHTER_ARMOUR + 3

          lda #ITEM_KNIFE
          sta FIGHTER_WEAPON
          sta FIGHTER_WEAPON + 1
          sta FIGHTER_WEAPON + 2
          sta FIGHTER_WEAPON + 3
}

          ldy #ATTACK_HEAL_PARTY
          jsr PlayAttackAnimationWithoutDisplay


          ;display HP/MP
          jsr DisplayPartyValues

          lda #0
          sta NO_DISPLAY

!zone GameLoop
GameLoop
          jsr WaitFrame

          ldy POISON_FLASH_POS
          beq +

          lda POISON_FLASH_TABLE,y
          sta VIC_BORDER_COLOR

          inc POISON_FLASH_POS
          lda POISON_FLASH_POS
          cmp #8
          bne +

          lda #0
          sta POISON_FLASH_POS


+

          lda HAPPENS + 1
          and #$f0
          cmp #$f0
          beq .GameIsSolved

          jsr PlayerControl


          jmp GameLoop


.GameIsSolved
          lda #0
          sta MAP_ACTIVE
          ldy #1
          jmp FinalMessage


!zone ClearTopPanel
ClearTopPanel
          ldy #37
          lda #32
-
          sta SCREEN_CHAR + 41,y
          dey
          bpl -
          rts


!zone InitInGameIRQ
InitInGameIRQ
          ;wait for exact frame so we don't end up on the wrong
          ;side of the raster
          jsr WaitFrame
          sei

          lda #$36 ; make sure that IO regs at $dxxx are visible
          sta PROCESSOR_PORT

          lda #$7f ;disable cia #1 generating timer irqs
          sta $dc0d ;which are used by the system to flash cursor, etc

          lda #$01 ;tell VIC we want him generate raster irqs
          sta $d01a

          lda #RASTER_END_OF_PANEL_TOP
          sta VIC_RASTER_POS

          lda #$1b ;MSB of d011 is the MSB of the requested rasterline
          sta $d011 ;as rastercounter goes from 0-312

          ;set irq vector to point to our routine
          lda #<IrqSetGameDisplay
          sta $0314
          lda #>IrqSetGameDisplay
          sta $0315

          ;acknowledge any pending cia timer interrupts
          ;this is just so we're 100% safe
          lda $dc0d
          lda $dd0d

          cli
          rts


!zone IrqSetGameDisplay
IrqSetGameDisplay
          lda TITLE_ACTIVE
          bne +
          sta VIC_BACKGROUND_COLOR
+

          ldy NO_DISPLAY
          lda VIC_CONTROL_MODE
          and #$9f
          ora VIC_DISPLAY_MASK,y
          sta VIC_CONTROL_MODE

          lda VIC_SPRITE_ENABLE
          sta GAME_VIC_SPRITE_ENABLE


          lda MAP_ACTIVE
          beq +

          ;overworld map
          lda #$3e
          sta VIC_MEMORY_CONTROL

          ldy #MD_COLORS
          lda (CURRENT_MAP_DATA),y
          lsr
          lsr
          lsr
          lsr
          sta VIC_CHARSET_MULTICOLOR_1
          lda (CURRENT_MAP_DATA),y
          and #$0f
          sta VIC_CHARSET_MULTICOLOR_2



          jmp ++

+
          ;battle screen
          lda BATTLE_MULTI_COLOR_1
          sta VIC_CHARSET_MULTICOLOR_1
          lda BATTLE_MULTI_COLOR_2
          sta VIC_CHARSET_MULTICOLOR_2

          ldy NO_DISPLAY
          beq +
          lda #0
          sta VIC_SPRITE_ENABLE
+



          lda VIC_CONTROL
          and #$f8
          ora GAME_SHAKE
          sta VIC_CONTROL

          ;player sprites behind damage texts
          lda #$3c
          sta VIC_SPRITE_PRIORITY

          ;stun effect
          ldx #0
-
          lda FIGHTER_ACTIVE,x
          beq .SkipFighter

          lda FIGHTER_STATE,x
          and #STATUS_FROZEN
          beq .SkipFighter

          txa
          clc
          adc #2
          asl
          tay

          lda VIC_SPRITE_X_POS,y
          and #$fe
          sta LOCAL1

          jsr GenerateRandomNumber
          and #$01
          clc
          adc LOCAL1
          sta VIC_SPRITE_X_POS,y


.SkipFighter
          inx
          cpx #4
          bne -

++

          ;acknowledge VIC irq
          lda $d019
          sta $d019

          ;install top part
          lda #<IrqSetPanelDisplay
          sta $0314
          lda #>IrqSetPanelDisplay
          sta $0315

          ;nr of rasterline we want our irq occur at
          lda #RASTER_START_OF_PANEL_BOTTOM
          sta VIC_RASTER_POS

          JMP IRQ_RETURN_KERNAL



!zone IrqSetPanelDisplay
IrqSetPanelDisplay
          ldx #$30
          ldy #$1b
          lda VIC_CONTROL
          and #$f8
          pha

          lda #RASTER_START_OF_PANEL_BOTTOM + 1
-
          cmp VIC_RASTER_POS
          bne -

          stx VIC_MEMORY_CONTROL
          sty VIC_CONTROL_MODE
          pla
          sta VIC_CONTROL

          jsr SetupPanelVisuals

          lda GAME_VIC_SPRITE_ENABLE
          sta VIC_SPRITE_ENABLE

          ;acknowledge VIC irq
          lda $d019
          sta $d019

          ;install top part
          lda #<IrqSetGameDisplay
          sta $0314
          lda #>IrqSetGameDisplay
          sta $0315

          ;nr of rasterline we want our irq occur at
          lda #RASTER_END_OF_PANEL_TOP
          sta VIC_RASTER_POS

!ifdef MUSIC_ACTIVE {
          jsr MUSIC_PLAYER + 3
}
          JMP IRQ_RETURN_KERNAL



!zone PlayerControl
PlayerControl
          ldx #2


          lda SPRITE_MOVE_POS
          beq .NoAutoMove

          dec SPRITE_MOVE_POS

          ;"animate"
          lda SPRITE_MOVE_POS
          and #$03
          bne +

          lda SPRITE_POINTER_BASE + 2
          eor #$01
          sta SPRITE_POINTER_BASE + 2

+


          lda SPRITE_DIRECTION
          bne +
          jmp .MoveLeft
+
          cmp #1
          bne +
          jmp .MoveRight
+
          cmp #2
          beq .MoveUp
          jmp .MoveDown

.NoAutoMove
          jsr JoyReleasedFirePushed
          bne +

          jmp HandleTopMenu
          ;lda #ITEM_TYPE_USABLE
          ;jsr FillMenuWithItems
          ;jmp HandleMenu

+

          lda #$01
          bit JOYSTICK_PORT_II
          bne .NotUp

          lda PARTY_POS_Y
          bne .CheckUp

          ;can leave n?
          ldy #MD_EXIT_N
          lda (CURRENT_MAP_DATA),y
          bmi .NoExitN

          ;leave n
          sta PARTY_MAP
          lda #7
          sta PARTY_POS_Y
          jmp JumpToMap


.CheckUp
          lda MAP_POS
          sec
          sbc #20
          jsr IsTileBlocking
          beq +
.NoExitN
          rts
+

          jsr OnMoveStarted
          lda #2
          sta SPRITE_DIRECTION
          dec PARTY_POS_Y

          lda MAP_POS
          sec
          sbc #20
          sta MAP_POS

.MoveUp
          ldx #2
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jmp .MoveEndedCheck

.NotUp
          lda #$02
          bit JOYSTICK_PORT_II
          bne .NotDown

          lda PARTY_POS_Y
          cmp #7
          bne .CheckDown

          ;can leave s?
          ldy #MD_EXIT_S
          lda (CURRENT_MAP_DATA),y
          bmi .NoExitS

          ;leave s
          sta PARTY_MAP
          lda #0
          sta PARTY_POS_Y
          jmp JumpToMap

.CheckDown
          lda MAP_POS
          clc
          adc #20
          jsr IsTileBlocking
          beq +
.NoExitS
          rts
+

          jsr OnMoveStarted
          lda #3
          sta SPRITE_DIRECTION
          inc PARTY_POS_Y

          lda MAP_POS
          clc
          adc #20
          sta MAP_POS


.MoveDown
          ldx #2
          jsr MoveSpriteDown
          jsr MoveSpriteDown
          jmp .MoveEndedCheck


.NotDown
          lda #$08
          bit JOYSTICK_PORT_II
          bne .NotRight

          lda PARTY_POS_X
          cmp #19
          bne .CheckRight

          ;can leave east?
          ldy #MD_EXIT_E
          lda (CURRENT_MAP_DATA),y
          bmi .NoExitE

          ;leave east
          sta PARTY_MAP
          lda #0
          sta PARTY_POS_X
          jmp JumpToMap

.CheckRight
          lda MAP_POS
          clc
          adc #1
          jsr IsTileBlocking
          beq +
.NoExitE
          rts
+

          jsr OnMoveStarted
          lda #1
          sta SPRITE_DIRECTION
          inc PARTY_POS_X
          inc MAP_POS

          lda #SPRITE_PLAYER_TIA + 2
          sta SPRITE_POINTER_BASE + 2


.MoveRight
          ldx #2
          jsr MoveSpriteRight
          jsr MoveSpriteRight

          jmp .MoveEndedCheck

.NotRight
          lda #$04
          bit JOYSTICK_PORT_II
          bne .NotLeft

          lda PARTY_POS_X
          bne .CheckLeft

          ;can leave w?
          ldy #MD_EXIT_W
          lda (CURRENT_MAP_DATA),y
          bmi .NoExitW

          ;leave west
          sta PARTY_MAP
          lda #19
          sta PARTY_POS_X
          jmp JumpToMap

.CheckLeft
          lda MAP_POS
          sec
          sbc #1
          jsr IsTileBlocking
          beq +
.NoExitW
          rts
+

          jsr OnMoveStarted
          lda #0
          sta SPRITE_DIRECTION
          dec PARTY_POS_X
          dec MAP_POS
          lda #SPRITE_PLAYER_TIA
          sta SPRITE_POINTER_BASE + 2

.MoveLeft
          ldx #2
          jsr MoveSpriteLeft
          jsr MoveSpriteLeft

          jmp .MoveEndedCheck

.NotLeft
          rts

.MoveEndedCheck
          lda SPRITE_MOVE_POS
          beq .StepEnded
          rts

.StepEnded
          ;stepped on trigger?
          ldx NUM_TRIGGERS_ACTIVE

.NextTrigger
          dex
          bmi .NoTriggers

          lda MAP_POS
          cmp TRIGGER_POS,x
          bne .NextTrigger

          lda TRIGGER_TYPE,x
          cmp #TT_EXIT
          beq .TakeExit

          ;start fight

          ;check happen index
          stx CURRENT_TARGET
          lda TRIGGER_VALUE_1,x
          jsr IsHappenSet
          bne .AlreadyUsed

          ;mark as used
          ldx CURRENT_TARGET
          lda TRIGGER_VALUE_1,x
          sta FIGHT_WON_HAPPEN
          ;jsr ToggleHappen

          ldx CURRENT_TARGET
          lda TRIGGER_VALUE_2,x
          jmp StartFightWithFormation
          ;happen-index,formation, freetouse


.TakeExit
          lda TRIGGER_VALUE_1,x
          sta PARTY_MAP
          lda TRIGGER_VALUE_2,x
          sta PARTY_POS_X
          lda TRIGGER_VALUE_3,x
          sta PARTY_POS_Y
          jmp JumpToMap

.NoTriggers
.AlreadyUsed
          lda PARTY_STEPS_TO_AUTO_FIGHT
          bne +

          lda #$ff
          sta FIGHT_WON_HAPPEN
          jmp StartFight
+
          dec PARTY_STEPS_TO_AUTO_FIGHT
          rts



!zone OnMoveStarted
OnMoveStarted
          lda #7
          sta SPRITE_MOVE_POS

          ;anyone poisoned?
          lda #0
          sta LOCAL1

          tax
          ;ldx #0
-
          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne +

          lda FIGHTER_STATE,x
          and #STATUS_POISONED
          ora LOCAL1
          sta LOCAL1
+
          inx
          cpx #4
          bne -

          lda LOCAL1
          and #STATUS_POISONED
          beq +

          lda #1
          sta POISON_FLASH_POS

          ;poison hurt
          ldx #0
          stx CURRENT_INDEX
.FighterLoop
          lda FIGHTER_ACTIVE,x
          beq .NextFighter

          lda FIGHTER_STATE,x
          and #STATUS_KO
          bne .NextFighter

          lda FIGHTER_STATE,x
          and #STATUS_POISONED
          beq .NextFighter

          jsr ApplyMapPoison
.NextFighter
          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #4
          bne .FighterLoop

+
          rts


!zone JumpToMap
JumpToMap
          ldx PARTY_POS_X
          ldy PARTY_POS_Y

          jsr CalcPosFromXY
          sta MAP_POS

          lda PARTY_POS_X
          asl
          sta PARAM1
          lda PARTY_POS_Y
          asl
          clc
          adc #4
          sta PARAM2
          lda #1
          sta PARAM3
          ldx #2
          jsr DoSpawnObject

          jmp DisplayMap



;x = x
;y = y
;returns pos in A
!zone CalcPosFromXY
CalcPosFromXY
          stx LOCAL2

          sty LOCAL1
          beq +
-
          lda LOCAL2
          clc
          adc #20
          sta LOCAL2
          dec LOCAL1
          bne -

+
          lda LOCAL2
          rts



;a = POS
;returns PARAM1 = x, PARAM2 = y
!zone CalcXYFromPos
CalcXYFromPos
          ldx #0
          stx PARAM1
          stx PARAM2
-
          sec
          sbc #20
          bcc .End

          inc PARAM2
          jmp -

.End
          adc #20
          sta PARAM1
          rts



;a = offset in map data
;return 1 if free to go
!zone IsTileBlocking
IsTileBlocking
          tay
          lda COLLISION_MAP,y
          cmp #TILE_INDEX_BLOCKING
          bcc .Free

          lda #1
          rts

.Free
          lda #0
          rts


;------------------------------------------------------------
;wait for the raster to reach line $f8
;this is keeping our timing stable
;------------------------------------------------------------
!zone WaitFrame
WaitFrame
          ;are we on line $F8 already? if so, wait for the next full screen
          ;prevents mistimings if called too fast
          lda VIC_RASTER_POS
          cmp #$F8
          beq WaitFrame

          ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
.WaitStep2
          lda VIC_RASTER_POS
          cmp #$F8
          bne .WaitStep2

          rts



!if 0 {
!zone CopySprites
CopySprites
;copy sprites to target
          ldy #$00
          ldx #$00

          lda #00
          sta ZEROPAGE_POINTER_2
          lda #$d0
          sta ZEROPAGE_POINTER_2+1

          ;4 sprites auf einmal
spriteloop
          lda (ZEROPAGE_POINTER_1),y
          sta (ZEROPAGE_POINTER_2),y
          iny
          bne spriteloop
          inx
          inc ZEROPAGE_POINTER_1+1
          inc ZEROPAGE_POINTER_2+1
          cpx #4
          bne spriteloop

          rts
}

;PARAM1 = X
;PARAM2 = Y
;PARAM3 = W
;PARAM4 = H
!zone ClearArea
ClearArea
          lda PARAM2
          sta PARAM5
          lda PARAM4
          sta PARAM6
          lda PARAM3
          clc
          adc PARAM1
          sta LOCAL1

--
          ldy PARAM5
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1


          ldy PARAM1
          lda #32
-
          sta (ZEROPAGE_POINTER_1),y

          iny
          cpy LOCAL1
          bne -

          inc PARAM5
          dec PARAM6
          bne --

          rts



!zone DisplayBox
;PARAM1 = X
;PARAM2 = Y
;PARAM3 = W
;PARAM4 = H

DisplayBox
          ldy PARAM2
          sty PARAM5
          ldy PARAM4
          sty PARAM6

          ldy PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          sta ZEROPAGE_POINTER_2
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_2 + 1

          ;top left corner
          ldy PARAM1

          lda #26
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y

          ldx PARAM3
          cpx #3
          bmi .NoTopCenterNeeded

          dex
          dex

          ;top middle
.NextTop
          iny
          lda #27
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y
          dex
          bne .NextTop

.NoTopCenterNeeded
          ;top right corner
          iny
          lda #1
          sta (ZEROPAGE_POINTER_2),y
          lda #28
          sta (ZEROPAGE_POINTER_1),y

;middle parts
          ldx PARAM6
          cpx #4
          bmi .NoMiddlePartNeeded

          dec PARAM6
          dec PARAM6

;begin middle part
.MiddlePart
          inc PARAM5
          ldy PARAM5
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          sta ZEROPAGE_POINTER_2
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_2 + 1

          ldy PARAM1

          ;middle left
          lda #30
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y

          ldx PARAM3
          cpx #3
          bmi .NoMiddleCenterNeeded

          dex
          dex

          ;middle center
.NextMiddle
          iny
          lda #32
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y
          dex
          bne .NextMiddle

.NoMiddleCenterNeeded
          ;middle right
          iny
          lda #31
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y

.NoMiddlePartNeeded

          dec PARAM6
          bne .MiddlePart


;bottom part
          lda PARAM5
          sec
          adc PARAM6
          tay
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1+1
          clc
          adc #12
          sta ZEROPAGE_POINTER_2+1
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          sta ZEROPAGE_POINTER_2

          ldy PARAM1

          lda #29
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y

          ldx PARAM3
          cpx #3
          bmi .NoBottomCenterNeeded

          dex
          dex

.NextBottom
          iny
          lda #44
          sta (ZEROPAGE_POINTER_1),y
          lda #1
          sta (ZEROPAGE_POINTER_2),y
          dex
          bne .NextBottom

.NoBottomCenterNeeded

          iny
          sta (ZEROPAGE_POINTER_2),y
          lda #43
          sta (ZEROPAGE_POINTER_1),y

          rts



!zone DisplayMap
.EXTRA_DATA_TYPE
          !byte 0

DisplayMap
          ;player sprites above texts
          lda #0
          sta VIC_SPRITE_PRIORITY

          lda #1
          sta MAP_ACTIVE
          sta NO_DISPLAY

          lda #$ff
          sta NEW_CHARACTER_POS

          lda #4
          sta VIC_SPRITE_ENABLE
          sta GAME_VIC_SPRITE_ENABLE

          lda #<( SCREEN_CHAR + 3 * 40 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 3 * 40 )
          sta ZEROPAGE_POINTER_2 + 1

          lda #<( SCREEN_COLOR + 3 * 40 )
          sta ZEROPAGE_POINTER_3
          lda #>( SCREEN_COLOR + 3 * 40 )
          sta ZEROPAGE_POINTER_3 + 1

          ;map
          ldy PARTY_MAP

          lda WORLD_MAP_LIST_LO,y
          sta ZEROPAGE_POINTER_1
          sta CURRENT_MAP_DATA
          lda WORLD_MAP_LIST_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          sta CURRENT_MAP_DATA + 1

          ;copy map
          ldy #0
-
          lda (CURRENT_MAP_DATA),y
          sta COLLISION_MAP,y
          iny
          cpy #20 * 8
          bne -

          lda #0
          sta TILE_X
          sta TILE_Y
          sta CHAR_X
          sta NUM_TRIGGERS_ACTIVE
          sta NUM_LOCAL_CHESTS
          sta NUM_ACTION_SPOTS


          ;line

          ;a tile

.NextTile
          ldy TILE_X
          lda (ZEROPAGE_POINTER_1),y
          tax

          ldy CHAR_X
          lda WORLD_TILE_CHARS_0_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda WORLD_TILE_COLORS_0_0,x
          sta (ZEROPAGE_POINTER_3),y

          iny
          lda WORLD_TILE_CHARS_1_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda WORLD_TILE_COLORS_1_0,x
          sta (ZEROPAGE_POINTER_3),y

          tya
          clc
          adc #39
          tay

          lda WORLD_TILE_CHARS_0_1,x
          sta (ZEROPAGE_POINTER_2),y
          lda WORLD_TILE_COLORS_0_1,x
          sta (ZEROPAGE_POINTER_3),y

          iny
          lda WORLD_TILE_CHARS_1_1,x
          sta (ZEROPAGE_POINTER_2),y
          lda WORLD_TILE_COLORS_1_1,x
          sta (ZEROPAGE_POINTER_3),y

          inc CHAR_X
          inc CHAR_X

          inc TILE_X
          lda TILE_X
          cmp #20
          bne .NextTile

          lda #0
          sta TILE_X
          sta CHAR_X

          lda ZEROPAGE_POINTER_1
          clc
          adc #20
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+
          lda ZEROPAGE_POINTER_2
          clc
          adc #80
          sta ZEROPAGE_POINTER_2
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
+
          lda ZEROPAGE_POINTER_3
          clc
          adc #80
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_3 + 1
+

          inc TILE_Y
          lda TILE_Y
          cmp #8
          bne .NextTile


          ;parse additional data
          ldy #MD_LOCAL_FORMATION_GROUP
          lda (CURRENT_MAP_DATA),y
          bmi .NextAddData
          jmp .NoAddData

.NextAddData
          iny

          ;type
          lda (CURRENT_MAP_DATA),y
          sta .EXTRA_DATA_TYPE
          and #$7f
          sty LOCAL1

          tay
          lda MAP_SPECIAL_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda MAP_SPECIAL_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy LOCAL1
          jmp (ZEROPAGE_POINTER_1)

MAP_SPECIAL_TABLE_LO = * - 1
          !byte <.TriggerExit
          !byte <.Chest
          !byte <.UseScript
          !byte <.TriggerFight
          !byte <.Switch
          !byte <.Happen
          !byte <.Character
          !byte <.UseItemScript

MAP_SPECIAL_TABLE_HI = * - 1
          !byte >.TriggerExit
          !byte >.Chest
          !byte >.UseScript
          !byte >.TriggerFight
          !byte >.Switch
          !byte >.Happen
          !byte >.Character
          !byte >.UseItemScript



.Switch
          ldx NUM_ACTION_SPOTS

          lda #AST_SWITCH
          sta ACTION_SPOT_TYPE,x

          ;pos
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_POS,x

          ;happen index
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_HAPPEN,x

          jmp .UseScript2

.UseScript
          ldx NUM_ACTION_SPOTS
          lda #AST_ANIM
          sta ACTION_SPOT_TYPE,x

          ;pos
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_POS,x

          ;attack anim script
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_SCRIPT,x

.UseScript2
          inc NUM_ACTION_SPOTS

          lda ACTION_SPOT_TYPE,x
          cmp #AST_SWITCH
          bne +


          ;toggle switch image
          sty CURRENT_INDEX
          stx CURRENT_ITEM

          lda ACTION_SPOT_HAPPEN,x
          jsr IsHappenSet
          beq ++

          ldx CURRENT_ITEM
          lda ACTION_SPOT_POS,x
          sec
          sbc #20
          tay
          lda (CURRENT_MAP_DATA),y
          sta PARAM4
          tya
          jsr CalcXYFromPos

          lda PARAM4
          sta PARAM3
          inc PARAM3
          jsr DisplayTile

++
          ldx CURRENT_ITEM
          ldy CURRENT_INDEX

+

          jmp .ContinueAdditionalData


.UseItemScript
          ldx NUM_ACTION_SPOTS
          lda #AST_ITEM
          sta ACTION_SPOT_TYPE,x

          ;pos
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_POS,x

          ;happen index
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_HAPPEN,x

          ;item index
          iny
          lda (CURRENT_MAP_DATA),y
          sta ACTION_SPOT_ITEM,x

          inc NUM_ACTION_SPOTS

          jmp .ContinueAdditionalData

NUM_ACTION_SPOT_SLOTS = 4

AST_ANIM    = 0
AST_SWITCH  = 1
AST_ITEM    = 2

NUM_ACTION_SPOTS
          !byte 0
ACTION_SPOT_POS
          !fill NUM_ACTION_SPOT_SLOTS,0
ACTION_SPOT_SCRIPT
          !fill NUM_ACTION_SPOT_SLOTS,0
ACTION_SPOT_HAPPEN
          !fill NUM_ACTION_SPOT_SLOTS,0
ACTION_SPOT_ITEM
          !fill NUM_ACTION_SPOT_SLOTS,0

;AST_ANIM    = 0
;AST_SWITCH  = 1
;AST_ITEM    = 2
ACTION_SPOT_TYPE
          !fill NUM_ACTION_SPOT_SLOTS,AST_ANIM

SLOT_OFFSET
          !byte 0,NUM_FIGHTERS,2 * NUM_FIGHTERS

EQUIPMENT_ITEM_MASK
          !byte ITEM_TYPE_WEAPON
          !byte ITEM_TYPE_ARMOR
          !byte ITEM_TYPE_RELIC

BIT_TABLE
          !byte 1,2,4,8,16,32,64,128
BIT_TABLE_FILLED
          !byte $00,$80,$c0,$e0,$f0,$f8,$fc,$fe

FIGHT_WON_HAPPEN
          !byte $ff

TYPE_START_COLOR = * - 1
          !byte $87       ;tia
          !byte $81       ;chris
          !byte $82       ;groo
          !byte $8d       ;emily
          !byte $01       ;menu pointer
          !byte $83       ;sword attack


TYPE_START_SPRITE = * - 1
          !byte SPRITE_PLAYER_TIA
          !byte SPRITE_PLAYER_CHRIS
          !byte SPRITE_PLAYER_GROO
          !byte SPRITE_PLAYER_EMILY
          !byte SPRITE_MENU_POINTER
          !byte SPRITE_SWORD_ATTACK

POISON_FLASH_TABLE
          !byte 0,6,4,2,2,4,6,0

;special attack list
;1 byte special attack id
;1 byte chance  ($80 set if last entry)

SAL_BLUE_SLIME
          !byte ATTACK_POISON_BITE, $80 | 20

SAL_BOSS_3
          !byte ATTACK_MAGIC_FIRE, 20
          !byte ATTACK_STUN, $80 | 20
SAL_BOSS_4
          !byte ATTACK_MAGIC_ICE, 20
          !byte ATTACK_STUN, $80 | 20
SAL_BOSS_1
          !byte ATTACK_MAGIC_LIGHTNING, 20
          !byte ATTACK_STUN, $80 | 20
SAL_BOSS_2
          !byte ATTACK_MAGIC_EARTH, 20
          !byte ATTACK_STUN, $80 | 20

SAL_STUN
          !byte ATTACK_STUN, $80 | 50



lsmf
!ifdef MUSIC_ACTIVE {
* = $1000
MUSIC_PLAYER
          !bin "20.PNLTMT OST_2F.prg",,2
          ;!bin "music.bin",,2
          ;!bin "music-1-song.bin",,2
}


.Chest
          ;x,y,chest no

          ;x
          iny
          lda (CURRENT_MAP_DATA),y
          sta PARAM1

          ;y
          iny
          lda (CURRENT_MAP_DATA),y
          sta PARAM2

          ;chest no
          iny
          lda (CURRENT_MAP_DATA),y
          tax

          lda CHEST_CONTENT,x
          bmi .IsEmpty

          stx LOCAL1

          ldx NUM_LOCAL_CHESTS
          lda PARAM1
          sta CHEST_X,x
          lda PARAM2
          sta CHEST_Y,x
          lda LOCAL1
          clc
          adc #1
          sta CHEST_INDEX,x
          inc NUM_LOCAL_CHESTS

          lda #TILE_CHEST_CLOSED
          jmp +

.IsEmpty
          lda #TILE_CHEST_OPEN
+
          sta PARAM3

          tya
          pha

          ldx PARAM1
          ldy PARAM2
          jsr CalcPosFromXY
          tay
          lda PARAM3
          sta COLLISION_MAP,y

          jsr DisplayTile

          pla
          tay

          jmp .ContinueAdditionalData



.TriggerFight
          lda #TT_FIGHT
          ;jmp ++
          bne ++

.TriggerExit
          ;exit     pos, target, x, y
          ;fight    pos, happen-index, formation, freetouse
          lda #TT_EXIT
++
          ldx NUM_TRIGGERS_ACTIVE
          sta TRIGGER_TYPE,x

          iny
          lda (CURRENT_MAP_DATA),y
          sta TRIGGER_POS,x

          iny
          lda (CURRENT_MAP_DATA),y
          sta TRIGGER_VALUE_1,x

          iny
          lda (CURRENT_MAP_DATA),y
          sta TRIGGER_VALUE_2,x

          iny
          lda (CURRENT_MAP_DATA),y
          sta TRIGGER_VALUE_3,x

          inc NUM_TRIGGERS_ACTIVE

          jmp .ContinueAdditionalData



.ContinueAdditionalData
          lda .EXTRA_DATA_TYPE
          bpl +
          jmp .NextAddData
+
.NoAddData
          lda #0
          sta NO_DISPLAY
          rts


;x7=character pos, index
.Character
          ;pos
          iny
          lda (CURRENT_MAP_DATA),y
          sta LOCAL1

          ;index
          iny
          lda (CURRENT_MAP_DATA),y
          sta NEW_CHARACTER_ID
          tax

          sty CURRENT_INDEX

          lda FIGHTER_ACTIVE - 1,x
          bne .CharacterAlreadyAdded

          lda LOCAL1
          sta NEW_CHARACTER_POS
          jsr CalcXYFromPos

          asl PARAM1
          asl PARAM2
          inc PARAM2
          inc PARAM2
          inc PARAM2
          inc PARAM2

          ldx NEW_CHARACTER_ID
          stx PARAM3
          inx
          inx
          jsr DoSpawnObject
          jmp +



.CharacterAlreadyAdded
          ;copy floor piece from below
          lda LOCAL1
          clc
          adc #20
          tay
          lda COLLISION_MAP,y
          ldy LOCAL1
          sta COLLISION_MAP,y
+
          ldy CURRENT_INDEX
          jmp .ContinueAdditionalData



;x6=happen, index, pos, tile
.Happen
          ;happen index
          iny
          lda (CURRENT_MAP_DATA),y
          tax
          sty CURRENT_INDEX

          jsr IsHappenSet
          beq .HappenNotSet

          ;pos
          ldy CURRENT_INDEX
          iny
          lda (CURRENT_MAP_DATA),y
          sta LOCAL1

          ;tile
          iny
          lda (CURRENT_MAP_DATA),y
          sta PARAM3

          ;x,y from pos
          sty CURRENT_INDEX
          ldy LOCAL1
          lda PARAM3
          sta COLLISION_MAP,y
          lda LOCAL1
          jsr CalcXYFromPos


          jsr DisplayTile

          ldy CURRENT_INDEX
          jmp .ContinueAdditionalData


.HappenNotSet
          ldy CURRENT_INDEX
          iny
          iny
          jmp .ContinueAdditionalData



;PARAM1 = x
;PARAM2 = y
;PARAM3 = tile
!zone DisplayTile
DisplayTile
          lda PARAM2
          asl
          clc
          adc #3
          tay

          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_3
          sta ZEROPAGE_POINTER_4
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_3 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_4 + 1

          lda PARAM1
          asl
          tay
          ldx PARAM3

          lda WORLD_TILE_CHARS_0_0,x
          sta (ZEROPAGE_POINTER_3),y
          lda WORLD_TILE_COLORS_0_0,x
          sta (ZEROPAGE_POINTER_4),y

          iny
          lda WORLD_TILE_CHARS_1_0,x
          sta (ZEROPAGE_POINTER_3),y
          lda WORLD_TILE_COLORS_1_0,x
          sta (ZEROPAGE_POINTER_4),y

          tya
          clc
          adc #39
          tay

          lda WORLD_TILE_CHARS_0_1,x
          sta (ZEROPAGE_POINTER_3),y
          lda WORLD_TILE_COLORS_0_1,x
          sta (ZEROPAGE_POINTER_4),y

          iny
          lda WORLD_TILE_CHARS_1_1,x
          sta (ZEROPAGE_POINTER_3),y
          lda WORLD_TILE_COLORS_1_1,x
          sta (ZEROPAGE_POINTER_4),y

          rts





!zone DisplayPlayerNames
DisplayPlayerNames
          ;names
          lda #24
          sta PARAM1
          lda #20
          sta PARAM2

          ldx #0
.DisplayName
          lda FIGHTER_ACTIVE,x
          beq .NextName

          lda PARTY_NAME_LO,x
          sta ZEROPAGE_POINTER_1
          lda PARTY_NAME_HI,x
          sta ZEROPAGE_POINTER_1 + 1

          jsr DisplayText
.NextName
          inc PARAM2
          inx
          cpx #4
          bne .DisplayName

          rts


!zone DisplayPartyValues
DisplayPartyValues
          ldx #0
          stx CURRENT_INDEX
          lda #20
          sta PARAM2
-
          lda FIGHTER_ACTIVE,x
          beq .FighterInactive

          jsr DisplayFighterHP
          ldx CURRENT_INDEX
          jsr DisplayFighterMP

.FighterInactive
          inc PARAM2

          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #4
          bne -

          rts


!zone GenerateRandomNumber
GenerateRandomNumber
          lda $dc04
          eor $dc05
          eor $dd04
          adc $dd05
          eor $dd06
          eor $dd07
          rts

;a = lower end
;y = higher end
GenerateRangedRandom
          sta LOCAL2
          sty LOCAL1
          tya
          sec
          sbc LOCAL2
          clc
          adc #1
          sta LOCAL1

          jsr GenerateRandomNumber
.CheckValue
          cmp LOCAL1
          bcc .ValueOk

          ;too high
          sec
          sbc LOCAL1
          jmp .CheckValue

.ValueOk
          clc
          adc LOCAL2
          rts


;checks if fire button is released then pushed
;return 0 if pushed
;return 1 if not pushed
!zone JoyReleasedFirePushed
JoyReleasedFirePushed
          lda #$10
          bit JOYSTICK_PORT_II
          bne .NotPushed

          lda BUTTON_RELEASED
          beq .NotReleased

          lda #0
          sta BUTTON_RELEASED
          rts

.NotPushed
          lda #1
          sta BUTTON_RELEASED
          rts

.NotReleased
          lda #1
          rts



;checks if left is released then pushed
;return 0 if pushed
;return 1 if not pushed
!zone JoyReleasedLeftPushed
JoyReleasedLeftPushed
          lda #$04
          bit JOYSTICK_PORT_II
          bne .NotPushed

          lda LEFT_RELEASED
          beq .NotReleased

          lda #0
          sta LEFT_RELEASED
          rts

.NotPushed
          lda #1
          sta LEFT_RELEASED
          rts

.NotReleased
          lda #1
          rts



;checks if up is released then pushed
;return 0 if pushed
;return 1 if not pushed
!zone JoyReleasedUpPushed
JoyReleasedUpPushed
          lda #$01
          bit JOYSTICK_PORT_II
          bne .NotPushed

          lda UP_RELEASED
          beq .NotReleased

          lda #0
          sta UP_RELEASED
          rts

.NotPushed
          lda #1
          sta UP_RELEASED
          rts

.NotReleased
          lda #1
          rts



;checks if down is released then pushed
;return 0 if pushed
;return 1 if not pushed
!zone JoyReleasedDownPushed
JoyReleasedDownPushed
          lda #$02
          bit JOYSTICK_PORT_II
          bne .NotPushed

          lda DOWN_RELEASED
          beq .NotReleased

          lda #0
          sta DOWN_RELEASED
          rts

.NotPushed
          lda #1
          sta DOWN_RELEASED
          rts

.NotReleased
          lda #1
          rts



;checks if right is released then pushed
;return 0 if pushed
;return 1 if not pushed
!zone JoyReleasedRightPushed
JoyReleasedRightPushed
          lda #$08
          bit JOYSTICK_PORT_II
          bne .NotPushed

          lda RIGHT_RELEASED
          beq .NotReleased

          lda #0
          sta RIGHT_RELEASED
          rts

.NotPushed
          lda #1
          sta RIGHT_RELEASED
          rts

.NotReleased
          lda #1
          rts



!zone SetupPanelVisuals
SetupPanelVisuals
          lda #$30
          sta VIC_MEMORY_CONTROL
          lda #6
          sta VIC_BACKGROUND_COLOR
          lda #15
          sta VIC_CHARSET_MULTICOLOR_1
          lda #14
          sta VIC_CHARSET_MULTICOLOR_2
          rts



;a = happen index
;returns 1 if set, 0 if not set
!zone IsHappenSet
IsHappenSet
          jsr CalcHappenIndex

          lda HAPPENS,y
          and BIT_TABLE,x
          beq .NotSet

          lda #1
.NotSet
          rts


;a = happen index
!zone ToggleHappen
ToggleHappen
          jsr CalcHappenIndex

          lda HAPPENS,y
          eor BIT_TABLE,x
          sta HAPPENS,y
          rts




;a = happen index
;returns x = bit no
;        y = happen byte no
!zone CalcHappenIndex
CalcHappenIndex
          tax
          ;/ 8
          lsr
          lsr
          lsr
          tay

          txa
          and #$07
          tax

          rts



!zone ResetGameStats
ResetGameStats
          lda #0
          sta PARTY_MAP

          ;reset inventory
          ;ldx #0
          tax
-
          sta INVENTORY_SLOT,x
          sta INVENTORY_COUNT,x
          inx
          cpx #NUM_INVENTORY_ITEMS
          bne -

          lda #ITEM_NOTHING
          jsr AddItemToInventory

          ;initial inventory
          lda #ITEM_HERBS
          jsr AddItemToInventory
          lda #5
          sta INVENTORY_COUNT + 1

          lda #ITEM_ETHER
          jsr AddItemToInventory
          lda #5
          sta INVENTORY_COUNT + 2

!ifdef CHEAT_FILLED_INVENTORY {
          ;HACKACHEAT
          lda #ITEM_MAGIC_FIRE
          sta INVENTORY_SLOT + 3
          lda #1
          sta INVENTORY_COUNT + 3

          lda #ITEM_MAGIC_ICE
          sta INVENTORY_SLOT + 4
          lda #1
          sta INVENTORY_COUNT + 4

          lda #ITEM_CRYSTAL
          sta INVENTORY_SLOT + 5
          lda #4
          sta INVENTORY_COUNT + 5

          lda #ITEM_COAT
          jsr AddItemToInventory
          lda #ITEM_MAGIC_LIGHTNING
          jsr AddItemToInventory
          lda #ITEM_MAGIC_CURE
          jsr AddItemToInventory
          lda #ITEM_MAGIC_RAISE
          jsr AddItemToInventory
          lda #ITEM_FENIX_DOWN
          jsr AddItemToInventory
}


          lda #ITEM_NOTHING
          sta FIGHTER_WEAPON
          sta FIGHTER_WEAPON + 1
          sta FIGHTER_WEAPON + 2
          sta FIGHTER_WEAPON + 3

          ldx #0
          txa
          ;lda #0
-
          sta FIGHTER_ACTIVE,x
          sta FIGHTER_TYPE,x
          inx
          cpx #NUM_FIGHTERS
          bne -

          ;clean out
          tax
          ;ldx #0
          stx NUM_LEARNED_TECHS
-
          sta FIGHTER_LEVEL,x
          sta FIGHTER_STATE,x
          ;sta FIGHTER_STATE_EX,x
          sta FIGHTER_HP_HI,x
          sta FIGHTER_HP_MAX_HI,x
          sta FIGHTER_HP_LO,x
          sta FIGHTER_HP_MAX_LO,x
          sta PARTY_XP_1,x
          sta PARTY_XP_2,x
          sta PARTY_XP_3,x
          sta FIGHTER_ATTACK,x
          sta FIGHTER_DEFENSE,x
          sta FIGHTER_EVASION,x
          sta FIGHTER_MAGIC_EVASION,x
          sta FIGHTER_STRENGTH,x
          sta FIGHTER_SPEED,x
          sta FIGHTER_SPEED_POS,x
          sta TECH_LEARNED,x
          sta TECH_LEARNED + 4,x

          inx
          cpx #4
          bne -

          ;reset happens
          ;lda #0
          ;ldx #0
          tax
-
          sta HAPPENS,x
          inx
          cpx #( ( NUM_HAPPENS + 7 ) / 8 )
          bne -

          ;reset chests
          ldx #0
-
          lda CHEST_CONTENT,x
          and #$7f
          sta CHEST_CONTENT,x
          inx
          cpx #NUM_CHESTS
          bne -

!ifdef CHEAT_ALL_TECHNICS {
          ;HACKACHEAT
          lda #1
          sta NUM_LEARNED_TECHS
          sta TECH_LEARNED + 3
}


          ldx #0
          jsr AddFighterToParty

!if CHEAT_LEVEL99 = 1 {
          ldx #0
          jsr LevelUp
} else {
!ifdef CHEAT_LEVEL99 {
          lda #CHEAT_LEVEL99
          sta PARAM10
-
          ldx #0
          jsr LevelUp

          dec PARAM10
          bne -
}
}

          ;HACKACHEAT
!ifdef CHEAT_FULL_PARTY {
          ldx #1
          jsr AddFighterToParty
          ldx #2
          jsr AddFighterToParty
          ldx #3
          jsr AddFighterToParty
}

          rts

CHARSET
          ;!binary "pf.chr"
          !media "Penultimate Fantasy.charsetproject",char,0,174
BATTLE_CHARSET
          !media "battle.charsetproject",char,0,48

SPRITES
          !media "Penultimate Fantasy.spriteproject",sprite,0,16

INITIAL_PARTY_ATTACK
          !byte 12,5,8,2
INITIAL_PARTY_STRENGTH
          !byte 13,11,16,5
INITIAL_PARTY_DEFENSE
          !byte 7,8,9,5
INITIAL_PARTY_EVASION
          !byte 10,7,5,8
;INITIAL_PARTY_MAGIC_EVASION
;          !byte 8,8,8,8
;INITIAL_PARTY_SPEED
;          !byte 11,11,11,11
INITIAL_PARTY_HP
          !byte 21,18,29,19
INITIAL_PARTY_MP
          !byte 10,40,12,60

SCREEN_LINE_OFFSET_TABLE_LO
          !byte 000
          !byte 040
          !byte 080
          !byte 120
          !byte 160
          !byte 200
          !byte 240
          !byte 024
          !byte 064
          !byte 104
          !byte 144
          !byte 184
          !byte 224
          !byte 008
          !byte 048
          !byte 088
          !byte 128
          !byte 168
          !byte 208
          !byte 248
          !byte 032
          !byte 072
          !byte 112
          !byte 152
          !byte 192
SCREEN_LINE_OFFSET_TABLE_HI
          !byte $cc
          !byte $cc
          !byte $cc
          !byte $cc
          !byte $cc
          !byte $cc
          !byte $cc
          !byte $cd
          !byte $cd
          !byte $cd
          !byte $cd
          !byte $cd
          !byte $cd
          !byte $ce
          !byte $ce
          !byte $ce
          !byte $ce
          !byte $ce
          !byte $ce
          !byte $ce
          !byte $cf
          !byte $cf
          !byte $cf
          !byte $cf
          !byte $cf

MAP_ACTIVE
          !byte 0

PARTY_STEPS_TO_AUTO_FIGHT
          !byte 0


STORED_PARTY_HP_MAX_LO
          !byte 0,0,0,0
STORED_PARTY_HP_MAX_HI
          !byte 0,0,0,0
STORED_PARTY_MP_MAX_LO
          !byte 0,0,0,0
STORED_PARTY_MP_MAX_HI
          !byte 0,0,0,0

PARTY_XP_1
          !byte 0,0,0,0
PARTY_XP_2
          !byte 0,0,0,0
PARTY_XP_3
          !byte 0,0,0,0

TILE_X
          !byte 0
TILE_Y
          !byte 0
CHAR_X
          !byte 0

PARTY_MAP
          !byte 0
PARTY_POS_X
          !byte 0
PARTY_POS_Y
          !byte 0
;MAP_POS
;          !byte 0

LEFT_RELEASED
          !byte 0
RIGHT_RELEASED
          !byte 0
UP_RELEASED
          !byte 0
DOWN_RELEASED
          !byte 0
BUTTON_RELEASED
          !byte 0

;CURRENT_INDEX
;          !byte 0

NUM_TRIGGER_SLOTS = 4

NUM_TRIGGERS_ACTIVE
          !byte 0

TRIGGER_POS
          !fill NUM_TRIGGER_SLOTS,0

COLLISION_MAP
          !fill 160,0

TT_EXIT = 0
TT_FIGHT = 1

TRIGGER_TYPE
          !fill NUM_TRIGGER_SLOTS,0
TRIGGER_VALUE_1   ;exit map, formation type
          !fill NUM_TRIGGER_SLOTS,0
TRIGGER_VALUE_2   ;exit target x, x pos
          !fill NUM_TRIGGER_SLOTS,0
TRIGGER_VALUE_3   ;exit target y, y pos
          !fill NUM_TRIGGER_SLOTS,0

NUM_LOCAL_CHEST_SLOTS = 2
NUM_LOCAL_CHESTS
          !byte 0

CHEST_X
          !fill NUM_LOCAL_CHEST_SLOTS,0
CHEST_Y
          !fill NUM_LOCAL_CHEST_SLOTS,0
CHEST_INDEX
          !fill NUM_LOCAL_CHEST_SLOTS,0




TITLE_ACTIVE
          !byte 0
POISON_FLASH_POS
          !byte 0



;battle shake effect
GAME_SHAKE
          !byte 0
NEW_CHARACTER_ID
          !byte 0
NEW_CHARACTER_POS
          !byte $ff



NUM_CHESTS = 15

CHEST_CONTENT
          !byte ITEM_KNIFE
          !byte ITEM_MAGIC_FIRE
          !byte ITEM_COAT
          !byte ITEM_MAGIC_RAISE
          !byte ITEM_CRYSTAL
          !byte ITEM_MAGIC_CURE
          !byte ITEM_CRYSTAL_ARMOR
          !byte ITEM_CRYSTAL
          !byte ITEM_MAGIC_ICE
          !byte ITEM_CRYSTAL
          !byte ITEM_CRYSTAL        ;10 - fire shrine
          !byte ITEM_CRYSTAL_ARMOR  ;11
          !byte ITEM_MAGIC_LIGHTNING;12
          !byte ITEM_STRENGTH_RING
          !byte ITEM_DEFENSE_RING

;TODO - 2x crystal armour
;     - 2x coat

;Happen 0 = spectre in dungeons
;       1 = switch door in dungeons
;       2 = switch right door in earth shrine
;       3 = switch left door in earth shrine
;       4 = boss 1 encountered
;       5 = boss 2 encountered
;       6 = ice shrine e door
;       7 = ice shrine w door
;       8 = ice shrine s door
;       9 = boss 4 encountered
;      10 = fire shrine bridge
;      11 = boss 3 encountered
;      12 = crystal 1 inserted
;      13 = crystal 2 inserted
;      14 = crystal 3 inserted
;      15 = crystal 4 inserted



NUM_HAPPENS = 16

HAPPENS
          !fill ( NUM_HAPPENS + 7 ) / 8,0

NO_DISPLAY
          !byte 0
GAME_VIC_SPRITE_ENABLE
          !byte 0

VIC_DISPLAY_MASK
          !byte 0
          !byte $60


!source "objects.asm"
!source "items.asm"
!source "fight.asm"
!source "enemies.asm"
!mediasrc "Overworld.mapproject",WORLD_,maptile
!source "texts.asm"
!source "map_use.asm"
!source "title.asm"
!source "menu.asm"

!source "attack_anims.asm"
!source "technics.asm"
!source "stats.asm"
