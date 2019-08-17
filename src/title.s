.importzp nmi_ready, PAD_START, gamepad, GAME_TITLE, gameState
.import palette, clear_nametable, ppu_address_tile, gamepad_poll, game_init

.export title_init, title_update

.segment "ZEROPAGE"
pointer:    .res 2

.segment "RODATA"
title_palette:
.byte $0F,$30,$16,$00 ; bg0 title text
.byte $0F,$04,$12,$01 ; bg1 
.byte $0F,$04,$19,$09 ; bg2 
.byte $0F,$04,$15,$06 ; bg3 
.byte $0F,$0F,$26,$37 ; sp0 
.byte $0F,$0c,$11,$31 ; sp1 
.byte $0F,$0b,$1a,$3a ; sp2 
.byte $0F,$07,$16,$36 ; sp3 

PRESS_START:
.asciiz "PRESS START BUTTON"

.segment "CODE"
title_init:
    lda #$00
	sta $2001
    ldx #0
	:; store palettes in palette
		lda title_palette, X
		sta palette, X
		inx
		cpx #32
		bcc :-
    jsr clear_nametable
    jsr draw_title
    jsr write_text_at_x_y
    lda #GAME_TITLE
    sta gameState
    rts 

TOP_Y = $05
TOP_X = $09
draw_title:
    ldy #TOP_Y ; starting row
    ldx #TOP_X ; starting column
    jsr ppu_address_tile
    lda #$c0
    :
        sta $2007
        clc 
        adc #$01
        cmp #$ce
        bne :-
    iny 
    jsr ppu_address_tile
    lda #$d0
    :
        sta $2007
        clc 
        adc #$01
        cmp #$de
        bne :-
    iny 
    jsr ppu_address_tile
    lda #$e0
    :
        sta $2007
        clc 
        adc #$01
        cmp #$ee
        bne :-
    iny 
    jsr ppu_address_tile
    lda #$f0
    :
        sta $2007
        clc 
        adc #$01
        cmp #$fe
        bne :-
    rts 

write_text_at_x_y:
    jsr ppu_address_tile
    ldy #$00
    :
        lda (pointer),Y
        beq :+
        sta $2007
        bne :-
    :
    rts 

title_update:
    jsr gamepad_poll
    lda gamepad 
    and #PAD_START
    beq :+
        jsr game_init
    :
    lda #$01
	sta	nmi_ready
    rts 
