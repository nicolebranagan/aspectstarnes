.export skull_init, skull_update

.import cnrom_bank_switch, clear_nametable, oam
.importzp aspect, pointer, nmi_ready, nmi_scroll, GAME_SKULL, gameState

skull_nametable:
  .incbin "../skull/skull.bin"

skull_init:
  lda #$00
  sta $2001 
  sta nmi_scroll
  sta aspect
  jsr clear_nametable 

  	ldx #0
	: ; clear sprites
		sta oam, X
		inx
		inx
		inx
		inx
		bne :-

  ldx #0
  ldy #0
  lda #<skull_nametable
  sta pointer
  lda #>skull_nametable
  sta pointer+1

 	lda	$2002 ; reset latch
	lda #$20
	sta $2006
	lda #$00
	sta $2006

  :
    lda (pointer),Y
    sta $2007
    iny
  bne :-
    inc pointer+1
    inx
    cpx #4
    bne :-

  lda #3
  jsr cnrom_bank_switch

  lda #GAME_SKULL
  sta gameState

  lda #$01
	sta	nmi_ready
  rts 

skull_update:
  inc aspect

  lda aspect
  and #1
  adc #2
  jsr cnrom_bank_switch

  lda #$01
  sta nmi_ready
  rts 