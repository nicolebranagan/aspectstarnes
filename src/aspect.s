;
;
;

.importzp nmi_ready, nmi_mask, nmi_scroll
.import game_update, nmi, oam, title_init
.import FamiToneInit, MusicData, FamiToneSfxInit, SfxData

.exportzp gameState, GAME_RUNNING, GAME_INIT, GAME_DEAD, GAME_PAUSE, GAME_TITLE, GAME_PRELEVEL, GAME_WIN, GAME_CONVO, GAME_CREDITS
.export frame, ppu_address_tile, cnrom_bank_switch

.segment "ZEROPAGE"
temp:		.res 1
gameState:  .res 1

GAME_RUNNING=$00
GAME_INIT=$01
GAME_DEAD=$02
GAME_PAUSE=$03
GAME_TITLE=$04
GAME_PRELEVEL=$05
GAME_WIN=$06
GAME_CONVO=$07
GAME_CREDITS=$08

;
; iNES header
;

.segment "HEADER"

INES_MAPPER = 3 ; 3 = CNROM
INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $04 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding

;
; CHR ROM
;

.segment "TILES"
.incbin "../gfx/bank0.chr"
.incbin "../gfx/bank1.chr"

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
main:
	lda #$00
	jsr cnrom_bank_switch
	sta nmi_mask
	sta nmi_scroll
	jsr title_init
	lda #<MusicData 
	tax 
	lda #>MusicData 
	tay 
	lda #$01
	jsr FamiToneInit
	lda #<SfxData 
	tax 
	lda #>SfxData 
	tay 
	lda #$01
	jsr FamiToneSfxInit
	lda #$01
	sta	nmi_ready	
	:
		nop	
		jmp :-

frame:
	jsr game_update
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

cnrom_index:
.byte $0, $1, $2, $3

; put a in thing
; clobbers x
cnrom_bank_switch:
	tax
	sta cnrom_index, x
	rts

;
; end of file
;
