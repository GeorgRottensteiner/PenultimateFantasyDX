*=$8000

!to "Penultimate Fantasy.crt",cart16crt

!byte $09,$80
!byte $19,$80
!byte $C3,$C2,$CD,$38,$30

          ;KERNAL RESET ROUTINE
          STX $D016				; Turn on VIC for PAL / NTSC check
	        JSR $FDA3				; IOINIT - Init CIA chips
	        JSR $FD50				; RANTAM - Clear/test system RAM
	        JSR $FD15				; RESTOR - Init KERNAL RAM vectors
	        ;JSR $FF5B				; CINT   - Init VIC and screen editor
	        ;CLI					; Re-enable IRQ interrupts

          lda #%10001011
          sta $d011

;copy copy code to $0400
          ldx #$00
sa1
          lda movecode1,x
          sta $0400,x
          inx
          bne sa1
          jmp $0400
        ;------------------------------
movecode1

;self modifying copy code, needs to be copied itself
!PSEUDOPC $0400
;!if * > $0400 {
;!error alles falsch
;}
basic_move
          ldx #$00
bm1
          lda main_file_start,x
bm2
          sta $0801,x
          inx
          bne bm1
          ;inc highbyte of source address
          inc bm1+2
          ;inc highbyte of target address
          inc bm2+2

          inc COPY_BLOCK_COUNT
          lda COPY_BLOCK_COUNT
          cmp #64
          bne basic_move

          ;disable display
          lda #$0b
          sta $d011

          ;disable cartridge
          lda #$35
          sta $01

!ifdef PACK_ALZ {
          ;jump to ALZ start
          jmp $080b
} else {
          ;jump to exomizer start
          jmp $080d
}

COPY_BLOCK_COUNT
          !byte 0

!REALPC
main_file_start
          !binary "gamecrunched.bin",,2
main_file_end
main_file_size = main_file_end - main_file_start

!if main_file_size > 16384 {
!error "content too large: ",main_file_size
} else {
!message "content size ",main_file_size
}
