;
;
;

.importzp PAD_A, PAD_B, PAD_SELECT, PAD_START, PAD_U, PAD_D, PAD_L, PAD_R, gamepad
.import gamepad_poll

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

.segment "OAM"
oam: .res 256        ; sprite OAM data to be uploaded by DMA

.segment "ZEROPAGE"
nmi_lock:       .res 1 ; prevents NMI re-entry
nmi_count:      .res 1 ; is incremented every NMI
nmi_ready:      .res 1 ; set to 1 to push a PPU frame update, 2 to turn rendering off next NMI
xpos:			.res 1
ypos:			.res 1
aspect:			.res 1
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
	:
		nop	
		jmp :-
;
;	frame
;

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
		inc ypos
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
		dec ypos
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

		inc xpos
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
		dec xpos
	:
	lda gamepad
	and #PAD_START
	beq :+
		dec aspect
		bne :+
		lda #$03
		sta aspect
	:
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

draw_friend:
	; draw horrifying floating face
	lda ypos
	sec	
	sbc	#$04
	sta	oam+(0*4)+0
	sta	oam+(1*4)+0
	lda	#$04
	sta	oam+(0*4)+1
	lda	#$05
	sta	oam+(1*4)+1
	lda #%00000000
	sta oam+(0*4)+2
	sta oam+(1*4)+2
	; draw body and suit
	lda ypos ; center y coordinate
	sec 
	sbc #$08
	sta	oam+(4*4)+0
	sta	oam+(5*4)+0
	clc	
	adc #$08
	sta	oam+(6*4)+0
	sta	oam+(7*4)+0
	lda #$08
	sta	oam+(4*4)+1
	lda #$09
	sta	oam+(5*4)+1
	lda #$0A
	sta	oam+(6*4)+1
	lda #$0B
	sta	oam+(7*4)+1
	lda aspect
	sta oam+(4*4)+2
	sta oam+(5*4)+2
	sta oam+(6*4)+2
	sta oam+(7*4)+2
	lda	xpos ; center x coordinate
	sec 
	sbc #$08
	sta oam+(0*4)+3	; floating face
	sta	oam+(4*4)+3
	sta	oam+(6*4)+3
	clc	
	adc	#$08
	sta oam+(1*4)+3 ; floating face
	sta	oam+(5*4)+3
	sta	oam+(7*4)+3
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
; nmi: (runs at vblank)
;

.segment "BSS"
nmt_update: .res 256 ; nametable update entry buffer for PPU update
palette:    .res 32  ; palette buffer for PPU update

.segment "CODE"
nmi:
	; save registers
	pha
	txa
	pha
	tya
	pha
	; prevent NMI re-entry
	lda nmi_lock
	beq :+
		jmp @nmi_end
	:
	lda #1
	sta nmi_lock
	; increment frame counter
	inc nmi_count
	;
	lda nmi_ready
	bne :+ ; nmi_ready == 0 not ready to update PPU
		jmp @ppu_update_end
	:
	cmp #2 ; nmi_ready == 2 turns rendering off
	bne :+
		lda #%00000000
		sta $2001
		ldx #0
		stx nmi_ready
		jmp @ppu_update_end
	:
	; sprite OAM DMA
	ldx #0
	stx $2003
	lda #>oam
	sta $4014
	; palettes
	lda #%10001000
	sta $2000 ; set horizontal nametable increment
	lda $2002
	lda #$3F
	sta $2006
	stx $2006 ; set PPU address to $3F00
	ldx #0
	:
		lda palette, X
		sta $2007
		inx
		cpx #32
		bcc :-
	; set scroll registers to 0
	lda $2000
	lda #$00
	sta $2005
	lda #$00
	sta $2005
	lda #%10001000
	sta $2000 ; set horizontal nametable increment
	; enable rendering
	lda #%00011110
	sta $2001
	; flag PPU update complete
	ldx #0
	stx nmi_ready
	jsr frame
@ppu_update_end:
	; if this engine had music/sound, this would be a good place to play it
	; unlock re-entry flag
	lda #0
	sta nmi_lock
@nmi_end:
	; restore registers and return
	pla
	tay
	pla
	tax
	pla
	rti

;
; end of file
;
