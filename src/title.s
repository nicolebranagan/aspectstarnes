.importzp nmi_ready, PAD_START, gamepad, GAME_TITLE, gameState, nmi_count, nmi_scroll, aspect, facing, moving, xpos, ypos
.importzp FACING_LEFT, FACING_RIGHT, last_gamepad, nmi_mask
.importzp enemy_x, enemy_y, enemy_asp, enemy_face, enemy_attr, lives
.import palette, clear_nametable, ppu_address_tile, gamepad_poll, game_preload, oam, draw_friend, enemy_draw

.export title_init, title_update, write_text_at_x_y, pointer 

.segment "ZEROPAGE"
pointer:    .res 2
temp:       .res 1
timer:      .res 1
titlePhase:	.res 1

TRAIN_PHASE=$00
SCROLL_PHASE=$01
CHASE_PHASE=$02

.segment "RODATA"
title_palette:
.byte $0F,$30,$16,$00 ; bg0 title text
.byte $0F,$0F,$03,$02 ; bg1 
.byte $0F,$04,$19,$09 ; bg2 
.byte $0F,$04,$15,$06 ; bg3 
.byte $0F,$24,$2c,$30 ; sp0 
.byte $0F,$0c,$11,$31 ; sp1 
.byte $0F,$0b,$1a,$3a ; sp2 
.byte $0F,$07,$16,$36 ; sp3 

aspect_pal1:
.byte $00, $03, $09, $06
aspect_pal2:
.byte $00, $02, $1b, $04

PRESS_START:
.asciiz "PRESS START BUTTON"
COPYRIGHT:
.asciiz "COPYRIGHT 2019"
NICOLE_EXPRESS:
.asciiz "NICOLE EXPRESS"

.segment "CODE"
title_init:
    lda #$00
	sta $2001
    sta nmi_mask
    ldx #0
	:; store palettes in palette
		lda title_palette, X
		sta palette, X
		inx
		cpx #32
		bcc :-
    jsr clear_nametable
    jsr write_logo
    jsr draw_title
    jsr draw_grid

    lda #<PRESS_START
    sta pointer
    lda #>PRESS_START
    sta pointer+1 
    ldx #$07
    ldy #TOP_Y+$11
    jsr write_text_at_x_y

    lda #<COPYRIGHT
    sta pointer
    lda #>COPYRIGHT
    sta pointer+1 
    ldx #$09
    ldy #TOP_Y+$14
    jsr write_text_at_x_y

    lda #<NICOLE_EXPRESS
    sta pointer
    lda #>NICOLE_EXPRESS
    sta pointer+1 
    ldx #$09
    ldy #TOP_Y+$15
    jsr write_text_at_x_y
    jsr write_attributes

    jsr init_train
    lda #$00
    sta timer
    lda #GAME_TITLE
    sta gameState
    rts 

LOGO_Y = $0d
LOGO_X = $0a
write_logo:
    ldy #LOGO_Y
    ldx #LOGO_X
    jsr ppu_address_tile
    lda #$B0
    :
        sta $2007
        clc 
        adc #$01
        cmp #$bb
        bne :-
    ldy #LOGO_Y+1
    ldx #LOGO_X+6
    jsr ppu_address_tile
    lda #$de 
    sta $2007
    rts

TOP_Y = $44
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
        cmp #$cf
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

draw_grid:
    lda #$00
    sta temp
    ldy #TOP_Y+5
    @yLoop:
        tya 
        and #%00000001
        sta temp
        ldx #TOP_X-2
        jsr ppu_address_tile
        @loop:
            lda temp
            and #%00000001
            beq :+
                lda #$df
                bne :++
            :
                lda #$cf
            :
            sta $2007
            inc temp
            inx 
            cpx #TOP_X-2+18
            bne @loop
        iny 
        cpy #TOP_Y+5+10
        bne @yLoop
    rts

write_text_at_x_y:
    jsr ppu_address_tile
    ldy #$00
    :
        lda (pointer),Y
        beq :+
        sta $2007
        iny 
        bne :-
    :
    rts 

write_attributes:
	lda $2002 ; reset latch
	lda	#$2b
	sta	$2006
	lda	#$d0
	sta	$2006
	ldx #0 ; start at byte 0
	:
		lda #%01010101
        sta $2007
		inx	
		cpx #$18
		bcc :-
    rts

.segment "RODATA"
titleUpdate:
	.word train_update, scroll_update, chase_update

.segment "CODE"
title_update: 
	lda titlePhase  
	asl
	tax
	lda titleUpdate+1,X 
	sta pointer+1 
	lda titleUpdate,X 
	sta pointer
	jmp (pointer)

train_update:
    jsr enemy_draw
    inc enemy_x 
    bne :+
        jsr init_scroll
    :
    jsr gamepad_poll
    lda gamepad 
    and #PAD_START
    beq :+
        jsr init_chase
    :
    lda #$01
	sta	nmi_ready
    rts 

scroll_update:
    inc nmi_scroll
    lda nmi_scroll
    cmp #$ef
    bne :+
        jsr init_chase
    :
    lda #$01
	sta	nmi_ready
    rts 

chase_update:
    inc timer
    lda timer
    cmp #200
    bne @done
        inc aspect 
        lda aspect 
        cmp #$04
        bne :+
            lda #$01
            sta aspect
        :
        dec enemy_asp 
        lda enemy_asp
        cmp #$00
        bne :+
            lda #$03
            sta enemy_asp
        :
        lda enemy_asp 
        cmp aspect 
        bne :+
            lda #FACING_RIGHT
            sta enemy_face 
            sta facing
            jmp :++
        :
            lda #FACING_LEFT
            sta enemy_face 
            sta facing
        :
        ldx aspect 
        lda aspect_pal1,X 
        sta palette+6
        lda aspect_pal2,X 
        sta palette+7 
        lda #$00
        sta timer
    @done:
    jsr gamepad_poll
    lda gamepad 
    and #PAD_START
    beq :+
        lda last_gamepad ; get the gamepad only on the rising edge
        and #PAD_START
        bne :+
        lda #$03
        sta lives
        lda #$00
        jmp game_preload
    :
    jsr draw_friend
    jsr enemy_draw
    lda enemy_asp
    cmp aspect 
    bne :+
        inc xpos
        inc enemy_x
        jmp :++
    :
        dec xpos
        dec enemy_x
    :
    lda #$01
	sta	nmi_ready
    rts 

init_train:
    ldx #$00
    :
        lda #$FF
        sta enemy_y,X ; Store 255 in the y position
        lda #$00
        sta enemy_face,X 
        lda #$00
        sta enemy_attr,X 
        inx 
        cpx #$08
        bne :-
    lda #$00
    sta enemy_asp 
    lda #$5b 
    sta enemy_y 
    lda #$08
    sta enemy_x 
    lda #$03
    sta enemy_attr
    lda #FACING_LEFT
    sta enemy_face
    lda #TRAIN_PHASE
    sta titlePhase
    rts 

init_scroll:
    lda #$ff 
    sta enemy_y
    jsr enemy_draw
    lda #SCROLL_PHASE
    sta titlePhase
    rts 

init_chase:
    lda #$ef 
    sta nmi_scroll
    lda #$00
    sta timer
    lda #$0F
    sta palette+17
    lda #$26 
    sta palette+18
    lda #$37
    sta palette+19
    lda #$01
    sta aspect
    lda #$70
    sta xpos 
    sta ypos 
    lda #FACING_LEFT
    sta facing 
    lda #$01
    sta moving
    lda #$00
    sta enemy_attr 
    lda #$02
    sta enemy_asp 
    lda #$70 
    sta enemy_y 
    lda #$B0
    sta enemy_x 
    lda #FACING_LEFT
    sta enemy_face
    lda #CHASE_PHASE
    sta titlePhase
    rts 
