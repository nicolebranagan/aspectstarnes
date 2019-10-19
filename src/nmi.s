;
; nmi: (runs at vblank)
;

.export palette, nmi, oam
.exportzp nmi_ready, nmi_count, nmi_mask, nmi_scroll

.import frame, FamiToneUpdate, convoNmi
.importzp GAME_CONVO, gameState 

.segment "ZEROPAGE"
nmi_lock:       .res 1 ; prevents NMI re-entry
nmi_count:      .res 1 ; is incremented every NMI
nmi_ready:      .res 1 ; set to 1 to push a PPU frame update, 2 to turn rendering off next NMI
nmi_mask:		.res 1 ; allows setting attribute bits 
nmi_scroll:		.res 1 ; allows scrolling

.segment "BSS"
palette:    .res 32  ; palette buffer for PPU update

.segment "OAM"
oam: .res 256        ; sprite OAM data to be uploaded by DMA

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
	lda gameState 
	cmp #GAME_CONVO
	bne :+
		jsr convoNmi
	:
	; set scroll registers to 0
	lda $2000
	lda #$00
	sta $2005
	lda nmi_scroll
	sta $2005
	lda #%10001000
	sta $2000 ; set horizontal nametable increment
	; enable rendering
	lda #%00011110
	ora nmi_mask 
	sta $2001
	; flag PPU update complete
	lda gameState 
	cmp #GAME_CONVO
	bne :+
		; Use 8x16 sprites
		lda #%10101000
		sta $2000
	:
	ldx #0
	stx nmi_ready
	jsr FamiToneUpdate
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
