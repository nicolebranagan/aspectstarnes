;
;
;

.importzp PAD_A, PAD_B, PAD_SELECT, PAD_START, PAD_U, PAD_D, PAD_L, PAD_R, gamepad, nmi_ready, nmi_count
.import gamepad_poll, nmi, palette, oam

.export frame

;
; iNES header
;

.segment "HEADER"

INES_MAPPER = 0 ; 0 = NROM
INES_MIRROR = 1 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $01 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding

;
; CHR ROM
;

.segment "TILES"
.incbin "background.chr"
.incbin "sprite.chr"

.segment "ZEROPAGE"
xpos:			.res 1
ypos:			.res 1
aspect:			.res 1
facing:			.res 1
temp:			.res 1
current_tile:	.res 1

.segment "RODATA"
test_map:
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01
.byte $01,$00,$01,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$01,$00,$01
.byte $01,$00,$01,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$01,$00,$01
.byte $01,$00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

map_tiles:
.byte $08,$04
map_attributes:
.byte %00000001, %00000000
MAP_WIDTH=$10
MAP_HEIGHT=$0F

;
; vectors placed at top 6 bytes of memory area
;

.segment "VECTORS"
.word nmi
.word reset
.word irq

;
; reset routine
;

.segment "CODE"
irq:
	rti 
reset:
	sei       ; mask interrupts
	lda #0
	sta $2000 ; disable NMI
	sta $2001 ; disable rendering
	sta $4015 ; disable APU sound
	sta $4010 ; disable DMC IRQ
	lda #$40
	sta $4017 ; disable APU IRQ
	cld       ; disable decimal mode
	ldx #$FF
	txs       ; initialize stack
	; wait for first vblank
	bit $2002
	:
		bit $2002
		bpl :-
	; clear all RAM to 0
	lda #0
	ldx #0
	:
		sta $0000, X
		sta $0100, X
		sta $0200, X
		sta $0300, X
		sta $0400, X
		sta $0500, X
		sta $0600, X
		sta $0700, X
		inx
		bne :-
	; place all sprites offscreen at Y=255
	lda #255
	ldx #0
	:
		sta oam, X
		inx
		inx
		inx
		inx
		bne :-
	; wait for second vblank
	:
		bit $2002
		bpl :-
	; NES is initialized, ready to begin!
	lda #%10001000
	sta $2000
	jmp main

;
; main
;

.segment "RODATA"
example_palette:
.byte $0F,$04,$14,$2a ; bg0 purple/pink
.byte $0F,$02,$19,$29 ; bg1 floor
.byte $0F,$01,$11,$21 ; bg2 blue
.byte $0F,$00,$10,$30 ; bg3 greyscale
.byte $0F,$0F,$26,$37 ; sp0 floating face
.byte $0F,$0c,$11,$31 ; sp1 aspect plus
.byte $0F,$0b,$1a,$3a ; sp2 aspect x
.byte $0F,$07,$16,$36 ; sp3 aspect circle

main:
	ldx #0
	:; store example palettes in palette
		lda example_palette, X
		sta palette, X
		inx
		cpx #32
		bcc :-
	jsr draw_background
	lda #$01
	sta	nmi_ready	
	lda #$80
	sta xpos
	lda #$60
	sta ypos
	lda	#$01
	sta	aspect
	lda #FACING_DOWN
	sta facing
	:
		nop	
		jmp :-
;
;	frame
;

FACING_UP=$01
FACING_DOWN=$00
FACING_LEFT=$02
FACING_RIGHT=$03

.segment "CODE"
frame:
	jsr gamepad_poll	; read gamepad
	lda	gamepad
	and #PAD_D
	beq :+
		lda ypos
		clc 
		adc #$08
		tay 
		lda xpos 
		tax 
		jsr is_solid
		bcs :+

		lda xpos 
		clc 
		adc #$06
		tax 
		jsr is_solid
		bcs :+

		lda xpos 
		sec 
		sbc #$06
		tax 
		jsr is_solid
		bcs :+
		lda #FACING_DOWN
		sta facing
		inc ypos
		jsr @done
	:
	lda gamepad
	and #PAD_U
	beq :+
		lda ypos
		sec 
		sbc #$07
		tay 
		lda xpos 
		tax 
		jsr is_solid
		bcs :+

		lda xpos 
		clc 
		adc #$06
		tax 
		jsr is_solid
		bcs :+

		lda xpos 
		sec 
		sbc #$06
		tax 
		jsr is_solid
		bcs :+
		lda #FACING_UP
		sta facing
		dec ypos
		jsr @done
	:		
	lda gamepad
	and #PAD_R
	beq :+
		lda xpos
		clc 
		adc #$07
		tax 
		lda ypos 
		tay 
		jsr is_solid
		bcs :+

		lda ypos 
		clc 
		adc #$07
		tay 
		jsr is_solid
		bcs :+

		lda ypos 
		sec 
		sbc #$06
		tay 
		jsr is_solid
		bcs :+

		lda #FACING_RIGHT
		sta facing
		inc xpos
		jsr @done
	:
	lda gamepad
	and #PAD_L
	beq :+
		lda xpos
		sec 
		sbc #$07
		tax 
		lda ypos 
		tay 
		jsr is_solid
		bcs :+

		lda ypos 
		clc 
		adc #$07
		tay 
		jsr is_solid
		bcs :+

		lda ypos 
		sec 
		sbc #$06
		tay 
		jsr is_solid
		bcs :+

		lda #FACING_LEFT
		sta facing
		dec xpos
		jsr @done
	:
	lda gamepad
	and #PAD_START
	beq :+
		dec aspect
		bne :+
		lda #$03
		sta aspect
	:
	@done:
	jsr draw_friend
	lda #$01
	sta	nmi_ready	
	rts	

is_solid:	; sets carry flag if x, y is solid
	tya 
	pha 
	lsr	
	lsr	
	lsr  
	tay 
	txa 
	pha 
	lsr 
	lsr 
	lsr 
	tax 
	jsr get_map_tile_for_x_y
	lda current_tile
	beq :+
	sec 
	bcs :++
	:  
	clc 
	:
	pla 
	tax 
	pla 
	tay 
	rts 

FLOATING_FACE_L=$00
FLOATING_FACE_R=$01
ASPECT_ICON=$02
SELF_TL=$04
SELF_TR=$05
SELF_BL=$06
SELF_BR=$07

.segment "RODATA"
player_sprites:
	.byte $0C, $0D, $0E, $0F	; facing down
	.byte $10, $11, $12, $13 	; facing up
	.byte $14, $15, $16, $17    ; facing left
	.byte $18, $19, $1A, $1B	; facing left, frame 2

.segment "CODE"
draw_friend:
	; put frame in x
	lda nmi_count
	and #%00010000
	lsr 
	lsr 
	lsr 
	lsr 
	tax 
	; put facing in Y
	ldy facing

	cpy #FACING_LEFT
	bcc :++ ; facing left or right
		txa 
		tay 
		iny 
		iny ; Set frame to frame 	
		ldx #$00
		lda facing
		cmp #FACING_RIGHT
		bne :+
			; Facing right case, use X to flip all
			ldx #$01
		:
	:	

	; top y coordinate
	lda ypos ; center y coordinate
	sta	oam+(SELF_BL*4)+0
	sta	oam+(SELF_BR*4)+0
	sec 
	sbc #$08
	sta	oam+(SELF_TL*4)+0
	sta	oam+(SELF_TR*4)+0
	sec 
	sbc #$08
	sta oam+(ASPECT_ICON*4)+0
	clc 
	adc #$0C
	sta	oam+(FLOATING_FACE_L*4)+0
	sta	oam+(FLOATING_FACE_R*4)+0
	tya 
	and #%00000011
	cmp #%00000001
	bne :+
		lda #$FF
		sta	oam+(FLOATING_FACE_L*4)+0
		sta	oam+(FLOATING_FACE_R*4)+0
	:

	; floating face sprites
	lda facing 
	cmp #FACING_LEFT
	bcc @facing_up
		lda ypos 
		sec 
		sbc #$05
		sta	oam+(FLOATING_FACE_L*4)+0
		sta	oam+(FLOATING_FACE_R*4)+0

		cpy #$03
		beq :+
			lda	#$0A 
			bne :++
		:
			lda #$08
		:
		cpx #$00
		beq :+
			sta	oam+(FLOATING_FACE_R*4)+1
			bne :++
		:
			sta	oam+(FLOATING_FACE_L*4)+1
		:
		cpy #$03
		beq :+
			lda	#$0B
			bne :++
		:
			lda #$09
		:	
		cpx #$00
		beq :+
			sta	oam+(FLOATING_FACE_L*4)+1
			bne :++
		:
			sta	oam+(FLOATING_FACE_R*4)+1
		:
		sec	
		bcs @suit

	@facing_up:
		txa 
		beq :+
			lda	#$06 
			bne :++
		:
			lda #$04
		:
		sta	oam+(FLOATING_FACE_L*4)+1
		txa 
		beq :+
			lda	#$07
			bne :++
		:
			lda #$05
		:	
		sta	oam+(FLOATING_FACE_R*4)+1

	@suit:
	tya 
	and #%00000011
	clc 
	asl 
	asl 
	tay	
	lda facing 
	cmp #FACING_RIGHT 
	bne :+
		lda player_sprites,Y
		sta	oam+(SELF_TR*4)+1
		iny 
		lda player_sprites,Y
		sta	oam+(SELF_TL*4)+1
		bcs :++
	:
		lda player_sprites,Y
		sta	oam+(SELF_TL*4)+1
		iny 
		lda player_sprites,Y
		sta	oam+(SELF_TR*4)+1
	:
	; Y = 1

	iny 
	txa 
	beq :+
		iny ; Y = 3
	:
	lda player_sprites,Y
	sta	oam+(SELF_BL*4)+1
	txa 
	beq :+
		dey 
		bne :++
	:
		iny 
	:	
	lda player_sprites,Y
	sta	oam+(SELF_BR*4)+1

	lda aspect
	sta oam+(ASPECT_ICON*4)+1

	; palette (aspect is the palette for body)
	sta oam+(ASPECT_ICON*4)+2
	txa 
	clc 
	ror 
	ror 
	ror 
	ora aspect 
	sta oam+(SELF_BL*4)+2
	sta oam+(SELF_BR*4)+2
	sta temp 

	lda facing 
	cmp #FACING_LEFT
	bcc :+
		lda temp 
		bcs :++
	:
		lda aspect 
	:
	sta oam+(SELF_TL*4)+2
	sta oam+(SELF_TR*4)+2

	lda facing 
	cmp #FACING_RIGHT
	bne :+
		lda #%01000000
		sta oam+(FLOATING_FACE_L*4)+2
		sta oam+(FLOATING_FACE_R*4)+2
		bne :++
	:
	lda #%00000000
	sta oam+(FLOATING_FACE_L*4)+2
	sta oam+(FLOATING_FACE_R*4)+2
	:

	; left x coordinate
	lda	xpos ; center x coordinate
	sec 
	sbc #$08
	sta oam+(FLOATING_FACE_L*4)+3	; floating face
	sta	oam+(SELF_TL*4)+3
	sta	oam+(SELF_BL*4)+3
	clc	
	adc	#$08
	sta oam+(FLOATING_FACE_R*4)+3 ; floating face
	sta	oam+(SELF_TR*4)+3
	sta	oam+(SELF_BR*4)+3
	sec 
	sbc #$04
	sta oam+(ASPECT_ICON*4)+3
	rts	

clear_nametable:
	; clear nametable
	lda	$2002 ; reset latch
	lda #$20
	sta $2006
	lda #$00
	sta $2006
	; empty nametable
	lda #0
	ldy #30 ; 30 rows
	:
		ldx #32 ; 32 columns
		:
			sta $2007
			dex
			bne :-
		dey
		bne :--
	; set all attributes to 0
	ldx #64 ; 64 bytes
	:
		sta $2007
		dex
		bne :-
	rts	

get_map_tile_for_x_y:
	txa	
	pha	; put x on the stack
	lsr	
	tax	
	tya	
	pha	; put y on the stack
	lsr	
	tay	
	txa	
	cpy #$00
	beq :++
	:
	clc	
	adc	#MAP_WIDTH
	dey	
	bne :-
	:
	tay	
	lda	test_map,Y ; the current map byte
	sta	current_tile
	pla	
	tay	
	pla	
	tax	
	rts	

write_map_bytes:
	jsr get_map_tile_for_x_y
	tya	
	pha	
	lda current_tile
	tay	
	lda	map_tiles,Y ; convert to offset in chr-ram
	sta temp	
	pla	
	tay	
	and	#%00000001 ; is this the second row?
	beq :+
	inc	temp
	inc temp
	:
	lda	temp
	sta $2007
	inx	
	inc temp
	lda temp
	sta $2007
	inx	
	rts	

write_attribute_byte:
	txa	
	pha	
	tay	
	lda #$00
	sta	temp
	txa	
	asl	; multiply by 2
	tax	
	tya	
	lsr	
	lsr	
	lsr	; divide by 8
	tay	
	txa	
	cpy	#$00
	beq :++
	:
	clc	
	adc	#MAP_WIDTH
	dey	
	bne :-
	:
	tax	
	lda test_map,X	
	tay	
	lda	map_attributes,Y	
	sta temp	
	inx	
	lda	test_map,X
	tay	
	lda	map_attributes,Y
	asl	
	asl 
	ora	temp
	sta	temp
	; we got the first two bytes
	txa	
	clc	
	adc	#MAP_WIDTH-1
	tax	
	lda	test_map,X
	tay	
	lda	map_attributes,Y
	asl	
	asl 
	asl	
	asl	
	ora	temp
	sta temp
	inx	
	lda	test_map,X
	tay	
	lda	map_attributes,Y
	asl	
	asl 
	asl	
	asl	
	asl	
	asl	
	eor	temp
	sta	$2007
	pla	
	tax	
	rts	

draw_background:
	jsr	clear_nametable
		; fill in an area in the middle with 1/2 checkerboard
	ldy #0 ; start at row 0
	:
		ldx #0
		jsr ppu_address_tile
		; write a line of checkerboard
		:
			jsr write_map_bytes	
			cpx #MAP_WIDTH*2
			bcc :-
		iny
		cpy #MAP_HEIGHT*2
		bcc :--

	; attributes
	lda $2002 ; reset latch
	lda	#$23
	sta	$2006
	lda	#$c0
	sta	$2006
	ldx #0 ; start at byte 0
	:
		jsr write_attribute_byte
		inx	
		cpx #$40
		bcc :-
	rts	

; ppu_address_tile: use with rendering off, sets memory address to tile at X/Y, ready for a $2007 write
;   Y =  0- 31 nametable $2000
;   Y = 32- 63 nametable $2400
;   Y = 64- 95 nametable $2800
;   Y = 96-127 nametable $2C00
ppu_address_tile:
	lda $2002 ; reset latch
	tya
	lsr
	lsr
	lsr
	ora #$20 ; high bits of Y + $20
	sta $2006
	tya
	asl
	asl
	asl
	asl
	asl
	sta temp
	txa
	ora temp
	sta $2006 ; low bits of Y + X
	rts

;
; end of file
;
