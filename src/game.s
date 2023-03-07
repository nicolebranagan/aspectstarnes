.importzp PAD_A, PAD_B, PAD_SELECT, PAD_START, PAD_U, PAD_D, PAD_L, PAD_R, gamepad, nmi_ready, nmi_count, gameState, GAME_INIT, GAME_RUNNING, GAME_PAUSE, GAME_DEAD, nmi_mask, nmi_scroll, GAME_PRELEVEL, pointer, GAME_WIN
.import palette, bullet_init, enemy_init, gamepad_poll, oam, bullet_fire, bullet_draw, bullet_update, enemy_init, enemy_draw, enemy_update, ppu_address_tile, title_update, write_text_at_x_y, title_init, level_data, convoUpdate
.import FamiToneMusicPlay, FamiToneMusicStop, FamiToneMusicPause, FamiToneSfxPlay
.importzp currentConvo
.import convoInit, convoperlevel, creditsUpdate
.import cnrom_bank_switch, prng

.exportzp aspect, xpos, ypos, facing, FACING_DOWN, FACING_LEFT, FACING_RIGHT, FACING_UP, current_tile, moving, lives, currentLevel
.export is_solid, get_map_tile_for_x_y, map_attributes, game_update, clear_nametable, clear_lower_nametable, draw_friend, game_preload, game_die

.segment "ZEROPAGE"
xpos:			.res 1
ypos:			.res 1
aspect:			.res 1
facing:			.res 1
moving:			.res 1
temp:			.res 1
current_tile:	.res 1
timer:			.res 1
currentLevel:	.res 1
lives:			.res 1
probability: .res 1
alreadyInit: .res 1
stillTimer: .res 1

.segment "BSS"
gamePointer:	.res 2
map:			.res 256
stored_palette: .res 16

.segment "RODATA"
ROUND:
.asciiz "LEVEL -1"
LIFE_COUNT:
.asciiz "   X *"
text_palette:
.byte $0F,$30,$16,$00 ; bg0 title text
level_palette:
.byte $0F,$00,$10,$01 ; bg0 bricks
.byte $0F,$04,$12,$01 ; bg1 floor, aspect plus
.byte $0F,$04,$19,$09 ; bg2 floor, aspect x
.byte $0F,$04,$15,$06 ; bg3 floor, aspect circle
factory_palette:
.byte $06,$0d,$13,$03 ; bg0 bricks
.byte $0B,$11,$10,$00 ; bg1 floor, aspect plus
.byte $0B,$19,$10,$00 ; bg2 floor, aspect x
.byte $0B,$15,$10,$00 ; bg3 floor, aspect circle
space_palette:
.byte $0F,$0C,$1C,$2C ; bg0 bricks, aspect plus
.byte $0D,$00,$10,$20 ; bg1 floor
.byte $0D,$19,$29,$20 ; bg2 floor, aspect x
.byte $0B,$15,$25,$20 ; bg3 floor, aspect circle
sprite_palette:
.byte $0F,$0F,$26,$37 ; sp0 floating face
.byte $0F,$0c,$11,$31 ; sp1 aspect plus
.byte $0F,$0b,$1a,$3a ; sp2 aspect x
.byte $0F,$07,$16,$36 ; sp3 aspect circle

map_tiles:
.byte $08,$04,$0C,$10,$14,$18 ; 0, 1, 2, 3, 4, 5
.byte $84,$1C,$80,$88,$8C,$5C,$BC,$23; 6, 7, 8, 9, A, B, C, D
.byte $98,$90,$94,$9C,$a0,$a4,$a8,$aC, $00; E, F, 10, 11, 12, 13, 14, 15
map_attributes: ; xxxSAAPP - P: Palette, A: Aspect, S: Solid
.byte %00000001, %00010000, %00000101, %00001010, %00001111, %00010000
.byte %00000001, %00010000, %00010000, %00000001, %00000101, %00001010, %00001111, %00010000
.byte %00000001, %00010000, %00010000, %00000100, %00001010, %00001111, %00010000, %00010000, $00
MAP_WIDTH=$10
MAP_HEIGHT=$0F
palette_by_stage:
.byte $00, $00, $00, $01, $01, $01, $02, $02, $02
level_palettes:
.word level_palette, factory_palette, space_palette

.segment "CODE"
game_init:
	lda #$00
	jsr cnrom_bank_switch
	sta $2001
	sta probability
	sta stillTimer
	sta alreadyInit
	lda currentLevel
	tax 
	lda palette_by_stage,X 
	asl 
	tax 
	lda level_palettes+1,X 
	sta pointer+1 
	lda level_palettes,X 
	sta pointer 
    ldy #0
	:; store level palettes in palette
		lda (pointer),Y 
		sta stored_palette,Y 
		iny
		cpy #16
		bcc :-
	ldx #0
	:; store sprite palettes in palette
		lda sprite_palette,X  
		sta palette,Y 
		iny 
		inx 
		cpy #32
		bcc :-
	lda currentLevel 
	asl 
	tax 
	lda level_data+1,X 
	sta pointer+1 
	lda level_data,X 
	sta pointer 
	ldy #0
	:
		lda (pointer),Y 
		sta map,Y  
		iny 
		cpy #$F0 
		bcc :-
	lda #$ff
	sta alreadyInit
partial_game_init:
	lda #$00
	sta $2001

	lda currentLevel
	tax
	pha 
		lda palette_by_stage,X 
		jsr FamiToneMusicPlay
	pla 
	asl
	tax

	ldy #0
	:; store level palettes in palette
		lda stored_palette,Y 
		sta palette,Y 
		iny
		cpy #16
	bcc :-


	jsr draw_background
	lda #$80
	sta xpos
	lda #$60
	sta ypos
	lda	#$01
	sta	aspect
	lda #FACING_DOWN
	sta facing
	sta moving
	jsr bullet_init
	jsr enemy_init
	lda #GAME_INIT
	sta gameState 
	lda #$00
	sta timer 
	rts 

game_preload:
	sta currentLevel
	lda #$00
	sta $2001
	sta nmi_scroll
	sta nmi_mask
	ldx #0
	: ; clear sprites
		sta oam, X
		inx
		inx
		inx
		inx
		bne :-
	ldx #$00
	:
		lda text_palette,X 
		sta palette,X 
		inx 
		cpx #$04
		bne :-
	ldx #0
	:; store sprite palettes in palette
		lda sprite_palette,X  
		sta palette+16,X 
		iny 
		inx 
		cpy #32
		bcc :-
	lda #$0F
	sta palette+$10 ; clear background color
	jsr clear_nametable

	lda #<ROUND
	sta pointer 
	lda #>ROUND
	sta pointer+1
	ldx #$0C
	ldy #$0B
	jsr write_text_at_x_y

	lda #<LIFE_COUNT
	sta pointer 
	lda #>LIFE_COUNT
	sta pointer+1
	ldx #$0D
	ldy #$0E
	jsr write_text_at_x_y

	lda #GAME_PRELEVEL
	sta gameState
	lda #$00
	sta facing  
	lda #$72
	sta ypos  
	lda #$74
	sta xpos
	lda #$01
	sta aspect 
	sta moving
	sta nmi_ready 
	lda #$AF
	sta timer
	rts	

game_die:
	jsr FamiToneMusicStop
	; dec lives 
	ldx #$00
	lda #$02
	jsr FamiToneSfxPlay
	lda #GAME_DEAD
	sta gameState 
	ldx #0
	lda #$FF
	: ; clear sprites
		sta oam, X
		inx
		inx
		inx
		inx
		bne :-
	lda #$00
	sta timer 
	sta ypos
	jsr draw_friend
	rts 

;
;	frame
;

FACING_UP=$01
FACING_DOWN=$00
FACING_LEFT=$02
FACING_RIGHT=$03

.segment "RODATA"
gameUpdate:
	.word running_update, init_update, dead_update, pause_update, title_update, preload_update, win_update, convoUpdate, creditsUpdate

.segment "CODE"
game_update: 
	lda gameState  
	asl
	tax
	lda gameUpdate+1,X 
	sta gamePointer+1 
	lda gameUpdate,X 
	sta gamePointer
	jmp (gamePointer)

init_update:
	lda #%00000001
	sta nmi_mask
	lda #$00
	sta nmi_scroll
	inc timer
	lda timer 
	cmp #$10
	bcc :+
		lda #$00
		sta nmi_mask 
		sta timer 
		sta temp 
		lda #GAME_RUNNING
		sta gameState 
		jmp @timer_mask_set
	:
	cmp #$0D
	bcc :+
		lda #%00100000
		sta nmi_mask
		jmp @timer_mask_set
	:
	cmp #$08
	bcc :+
		lda #%01100000
		sta nmi_mask
		jmp @timer_mask_set
	:
	cmp #$04
	bcc :+
		lda #%11100000
		sta nmi_mask
		jmp @timer_mask_set
	:
	@timer_mask_set:
	lda #$01
	sta	nmi_ready	
	rts 

running_update:
	inc stillTimer
	bne :+
		jsr game_die
	:
	jsr check_player_aspect
	jsr bullet_update
	jsr enemy_update
	lda gameState 
	cmp #GAME_DEAD 
	bne :+
		jmp @done
	: 
	lda gameState 
	cmp #GAME_WIN
	bne :+
		jmp @done
	:
	jsr gamepad_poll	; read gamepad
	lda gamepad
	beq :+
		lda #$00
		sta stillTimer
		lda gamepad
	:
	and #PAD_A
	beq :+
		jsr bullet_fire
	:
	lda	gamepad
	and #PAD_D
	beq :+
		lda #FACING_DOWN
		sta facing

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
		lda #$01
		sta moving
		jmp @done
	:
	lda gamepad
	and #PAD_U
	beq :+
		lda #FACING_UP
		sta facing

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
		lda #$01
		sta moving
		jmp @done
	:		
	lda gamepad
	and #PAD_R
	beq :+
		lda #FACING_RIGHT
		sta facing

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
		lda #$01
		sta moving
		jmp @done
	:
	lda gamepad
	and #PAD_L
	beq :+
		lda #FACING_LEFT
		sta facing

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
		lda #$01
		sta moving
		jmp @done
	:
	lda #$00
	sta moving
	lda temp 
	beq :+
		dec temp
		jmp @done
	:
	lda gamepad
	and #PAD_START
	beq :++ 
		lda #255
		ldx #0
		: ; clear sprites while paused
			sta oam, X
			inx
			inx
			inx
			inx
			bne :-
		lda #$10
		sta temp 
		jsr FamiToneMusicPause
		lda #GAME_PAUSE 
		sta gameState 
		lda #$01
		sta	nmi_ready	
		rts 
	:
	@done:
	jsr draw_friend
	jsr bullet_draw
	jsr enemy_draw
	lda #$01
	sta	nmi_ready	
	rts	

check_player_aspect:
	lda ypos
	lsr	
	lsr	
	lsr  
	tay 
	lda xpos 
	lsr 
	lsr 
	lsr 
	tax 
	jsr get_map_tile_for_x_y
	lda current_tile
	tay 
	lda map_attributes,Y
	and #%00001100 ; Mask off aspect bits
	beq @done
	lsr 
	lsr 
	cmp aspect
	beq @done
	sta aspect
	ldx #$00
	lda #$01
	jsr FamiToneSfxPlay 
	@done:
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
	tay 
	lda map_attributes,Y
	and #%00010000 ; Mask off solidity bit
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

dead_update:
	lda #$00
	sta nmi_scroll
	inc timer
	lda timer 
	cmp #$90
	bne :+
		jsr title_init
	:
	lda timer 
	cmp #$5A	
	bne :++
		lda #%11100001
		sta nmi_mask
		inc probability
		jsr prng
		cmp probability
		bcc :+
			lda currentLevel
			jmp game_preload
		:
			jsr title_init
	:
	lda timer 
	cmp #$40
	bcs :+
		jsr enemy_draw
	:
	lda #$01
	sta	nmi_ready	
	rts 

pause_update:
	inc timer 
	lda timer 
	cmp #$90
	bcc :+
		lda #$00
		sta timer 
	:
	cmp #$60
	bcc :+
		lda #%00100000
		sta nmi_mask
		jmp @timer_mask_set
	:
	cmp #$30
	bcc :+
		lda #%01000000
		sta nmi_mask
		jmp @timer_mask_set
	:
		lda #%10000000
		sta nmi_mask
		jmp @timer_mask_set
	@timer_mask_set:
	lda temp 
	cmp #$00
	beq :+
		dec temp 
		lda #$01
		sta	nmi_ready
		rts 
	:
	jsr gamepad_poll 
	lda gamepad
	and #PAD_START
	beq :+
		lda #$10
		sta temp 
		lda #$00
		sta timer 
		sta nmi_mask 
		jsr FamiToneMusicPause
		lda #GAME_RUNNING 
		sta gameState 
	:
	lda #$01
	sta	nmi_ready
	rts 

preload_update:
	dec timer 
	bne :++
		lda alreadyInit
		beq :+
			jsr glitch_map_tile
			jsr glitch_map_tile
			jsr glitch_palette
			jsr partial_game_init
			jmp :++
		:
		jsr glitch_map_tile
		jsr game_init
	:
	jsr draw_friend
	lda #$01
	sta nmi_ready 
	rts 

win_update:
	lda #$00
	sta alreadyInit
	inc currentLevel 
	lda currentLevel
	tax 
	lda convoperlevel,X 
	cmp #$FF
	beq :+
		sta currentConvo 
		jsr convoInit
		rts 
	:
	lda #$04
    ldx #$00
    jsr FamiToneSfxPlay
	lda currentLevel
	jsr game_preload
	lda #$01 
	sta nmi_ready
	rts

FLOATING_FACE_L=$01
FLOATING_FACE_R=$02
ASPECT_ICON=$03
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
	and #%00001000
	lsr 
	lsr 
	lsr 
	tax 

	; Change frame back to 0 if the player is not "moving"
	lda moving
	bne :+
		tax 
	:

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
		sbc #$04
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
		bcs @donetop
	:
		lda player_sprites,Y
		pha 
		txa 
		beq :+
			pla 
			sta	oam+(SELF_TR*4)+1
			bne :++
		:
			pla 
			sta	oam+(SELF_TL*4)+1
		:
		iny 
		lda player_sprites,Y
		pha 
		txa 
		beq :+
			pla 
			sta	oam+(SELF_TL*4)+1
			bne @donetop
		:
			pla 
			sta	oam+(SELF_TR*4)+1
	@donetop:
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

clear_lower_nametable:
	; clear nametable
	lda	$2002 ; reset latch
	lda #$28
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
	lda	map,Y ; the current map byte
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
	lda map,X	
	tay	
	lda	map_attributes,Y	
	and #%00000011
	sta temp	
	inx	
	lda	map,X
	tay	
	lda	map_attributes,Y
	and #%00000011
	asl	
	asl 
	ora	temp
	sta	temp
	; we got the first two bytes
	txa	
	clc	
	adc	#MAP_WIDTH-1
	tax	
	lda	map,X
	tay	
	lda	map_attributes,Y
	and #%00000011
	asl	
	asl 
	asl	
	asl	
	ora	temp
	sta temp
	inx	
	lda	map,X
	tay	
	lda	map_attributes,Y
	and #%00000011
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

glitch_map_tile:
	jsr prng
	tax
	jsr prng
	and #3
	sta map,X
	rts

glitch_palette:
	jsr prng
	and #15
	tax
	jsr prng
	cmp #$0d
	beq :+
		sta stored_palette,X
	:
	rts
