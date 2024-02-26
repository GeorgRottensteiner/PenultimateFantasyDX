;------------------------------------------------------------
;displays text
;PARAM1 = x
;PARAM2 = y
;ZEROPAGE_POINTER_1 = text
;returns length of text in PARAM5
;------------------------------------------------------------
!zone DisplayText
DisplayText
          lda #0
          sta PARAM5
          ldy PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          clc
          adc PARAM1
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          adc #0
          sta ZEROPAGE_POINTER_2 + 1
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_3 + 1

          ldy #0
-
          inc PARAM5

          lda ATTACK_ANIM_NO_DISPLAY
          bne .NoDisplay

          lda #1
          sta (ZEROPAGE_POINTER_3),y
          lda (ZEROPAGE_POINTER_1),y
          bmi .WasLastChar
          sta (ZEROPAGE_POINTER_2),y
--
          iny
          jmp -

.NoDisplay
          lda (ZEROPAGE_POINTER_1),y
          bpl --
          rts

.WasLastChar
          and #$7f
          sta (ZEROPAGE_POINTER_2),y
          rts



TEXT_YOU_LOST
          !text "YOU HAVE BEEN DEFEATEd"
TEXT_YOU_WON_GAME
          !text " YOU SAVED THE WORLD!",$80 | ' '
TEXT_YOU_WIN
          !text "YOU WIN THE FIGHt"
TEXT_LV_EXP
          !text "LV     Xp"
TEXT_EXP
          !text "EXPERIENCe"
TEXT_NOTHING_SPECIAL
          !text "YOU SEE NOTHING SPECIAl"
TEXT_YOU_FOUND
          !text "YOU FOUNd"

TEXT_YOU_LEARN
          !text "YOU LEARNEd"

TEXT_NOT_ENOUGH_MP
          !text "NOT ENOUGH Mp"

TEXT_TITLE
          !text "PENULTIMATE  FANTASy"

TEXT_QUEST
          !text "RETRIEVE ALL FOUR CRYSTALs"

TEXT_CREDITS_1
          !text "CODE   GEORG ROTTENSTEINEr"
TEXT_CREDITS_2
          !text "GFX         DAVID ERIKSSOn"
TEXT_CREDITS_3
          !text "MUSIC      MIKAEL BACKLUNd"

TECH_NAME_BIO
          !text "BIo"

TECH_NAME_QUAKE
          !text "QUAKe"

TEXT_LEARN
          !text "STUDy"


PLAYER_1_NAME
          !text "TIa"
PLAYER_2_NAME
          !text "CHRIs"
PLAYER_3_NAME
          !text "GROo"
PLAYER_4_NAME
          !text "EMILy"


EN_GREEN_SLIME
          !text "JELLy"
EN_BLUE_SLIME
          !text "SLIMe"
EN_ORC
          !text "ORc"
EN_SKELETON
          !text "ZOMBIe"
EN_SPECTRE
          !text "SPECTRe"
EN_ROLLO
          !text "ROLLo"
EN_MIST
          !text "MISt"
EN_YELLOW_SKELLY
          !text "CORPSe"

EN_BOSS_1
          !text "ISKUr"
EN_BOSS_2
          !text "URAs"
EN_BOSS_3
          !text "NERGAl"
EN_BOSS_4
          !text "UTu"

EN_TONBERRY
          !text "TONBERRy"

ITEM_NAME_EMPTY
          !text "NOTHINg"
ITEM_NAME_HERBS
          !text "HERBs"
ITEM_NAME_ETHER
          !text "ETHEr"
ITEM_NAME_MAGIC_FIRE
          !text "FIRe"
ITEM_NAME_BACK
          !text "BACk"
ITEM_NAME_FENIX_DOWN
          !text "FENIX DOWn"
ITEM_NAME_ANTIDOTE
          !text "ANTIDOTe"
ITEM_NAME_KNIFE
          !text "KNIFe"
ITEM_NAME_MAGIC_CURE
          !text "CURe"
ITEM_NAME_COAT
          !text "COAt"
ITEM_NAME_MAGIC_ICE
          !text "ICe"
ITEM_NAME_MAGIC_LIGHTNING
          !text "LIGHTNINg"
ITEM_NAME_CRYSTAL_ARMOR
          !text "PLATe"
ITEM_NAME_MAGIC_RAISE
          !text "RAISe"
ITEM_NAME_CRYSTAL
          !text "CRYSTAl"
ITEM_NAME_SWORD
          !text "SWORd"
ITEM_NAME_DEFENSE_RING    ;fallthrough!
          !text "EAR"
ITEM_NAME_STRENGTH_RING
          !text "RINg"


TEXT_MISS
          !text "MISs"


MENU_TEXT_FIGHT
          !text "FIGHt"
MENU_TEXT_STEAL
          !text "STEAl"
MENU_TEXT_TECH
          !text "TECh"
MENU_TEXT_JUMP
          !text "JUMp"
MENU_TEXT_MIMIC
          !text "MIMIc"

MENU_TEXT_MAGIC
          !text "MAGIc"
MENU_TEXT_ITEM
          !text "ITEm"

MENU_TEXT_TOP
          !text " ITEMS      EQUIP      EXAM       GAMe"

TEXT_WEAPON
          !text "WEAPOn"
TEXT_ARMOUR
          !text "ARMOUr"
TEXT_RELIC
          !text "RELIc"
TEXT_POISONED
          !text "POISONEd"

TEXT_JOINS
          !text "JOINs"



PARTY_NAME_LO
          !byte <PLAYER_1_NAME
          !byte <PLAYER_2_NAME
          !byte <PLAYER_3_NAME
          !byte <PLAYER_4_NAME

MENU_TEXT_SPECIALS_LO
          !byte <MENU_TEXT_STEAL
          !byte <MENU_TEXT_TECH
          !byte <MENU_TEXT_JUMP
          !byte <MENU_TEXT_MIMIC

ENEMY_NAME_LO = *-1
          !byte <EN_GREEN_SLIME
          !byte <EN_BLUE_SLIME
          !byte <EN_ORC
          !byte <EN_SKELETON
          !byte <EN_SPECTRE
          !byte <EN_ROLLO
          !byte <EN_MIST
          !byte <EN_YELLOW_SKELLY
          !byte <EN_BOSS_1
          !byte <EN_BOSS_2
          !byte <EN_BOSS_3
          !byte <EN_BOSS_4
          !byte <EN_TONBERRY

ITEM_NAME_LO = * - 1
          !byte <ITEM_NAME_HERBS
          !byte <ITEM_NAME_ETHER
          !byte <ITEM_NAME_MAGIC_FIRE
          !byte <ITEM_NAME_FENIX_DOWN
          !byte <ITEM_NAME_ANTIDOTE
          !byte <ITEM_NAME_KNIFE
          !byte <ITEM_NAME_EMPTY
          !byte <ITEM_NAME_MAGIC_CURE
          !byte <ITEM_NAME_COAT
          !byte <ITEM_NAME_MAGIC_ICE
          !byte <ITEM_NAME_MAGIC_LIGHTNING
          !byte <ITEM_NAME_CRYSTAL_ARMOR
          !byte <ITEM_NAME_MAGIC_RAISE
          !byte <ITEM_NAME_CRYSTAL
          !byte <ITEM_NAME_SWORD
          !byte <ITEM_NAME_STRENGTH_RING
          !byte <ITEM_NAME_DEFENSE_RING


TECH_NAME_LO
          !byte <TECH_NAME_BIO
          !byte <TECH_NAME_QUAKE

TECH_NAME_HI
          !byte >TECH_NAME_BIO
          !byte >TECH_NAME_QUAKE

ENEMY_NAME_HI = *-1
          !byte >EN_GREEN_SLIME
          !byte >EN_BLUE_SLIME
          !byte >EN_ORC
          !byte >EN_SKELETON
          !byte >EN_SPECTRE
          !byte >EN_ROLLO
          !byte >EN_MIST
          !byte >EN_YELLOW_SKELLY
          !byte >EN_BOSS_1
          !byte >EN_BOSS_2
          !byte >EN_BOSS_3
          !byte >EN_BOSS_4
          !byte >EN_TONBERRY

PARTY_NAME_HI
          !byte >PLAYER_1_NAME
          !byte >PLAYER_2_NAME
          !byte >PLAYER_3_NAME
          !byte >PLAYER_4_NAME

ITEM_NAME_HI = * - 1
          !byte >ITEM_NAME_HERBS
          !byte >ITEM_NAME_ETHER
          !byte >ITEM_NAME_MAGIC_FIRE
          !byte >ITEM_NAME_FENIX_DOWN
          !byte >ITEM_NAME_ANTIDOTE
          !byte >ITEM_NAME_KNIFE
          !byte >ITEM_NAME_EMPTY
          !byte >ITEM_NAME_MAGIC_CURE
          !byte >ITEM_NAME_COAT
          !byte >ITEM_NAME_MAGIC_ICE
          !byte >ITEM_NAME_MAGIC_LIGHTNING
          !byte >ITEM_NAME_CRYSTAL_ARMOR
          !byte >ITEM_NAME_MAGIC_RAISE
          !byte >ITEM_NAME_CRYSTAL
          !byte >ITEM_NAME_SWORD
          !byte >ITEM_NAME_STRENGTH_RING
          !byte >ITEM_NAME_DEFENSE_RING

MENU_TEXT_SPECIALS_HI
          !byte >MENU_TEXT_STEAL
          !byte >MENU_TEXT_TECH
          !byte >MENU_TEXT_JUMP
          !byte >MENU_TEXT_MIMIC



