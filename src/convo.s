.importzp gameState, pointer, GAME_CONVO, nmi_ready, nmi_scroll, nmi_mask
.export convoUpdate, convoInit, convoNmi
.import FamiToneMusicPlay, clear_nametable, oam, ppu_address_tile, palette

.segment "ZEROPAGE"
master_ptr:     .res 2
currentOffset:  .res 1
byteToSay:      .res 1
byteX:          .res 1
byteY:          .res 1 
faceX:          .res 1
faceY:          .res 1
currentFace:    .res 1
faceTile:       .res 1

.segment "RODATA"
convo_palette:
.byte $0F,$30,$16,$00 ; bg0 title text
.byte $0F,$0F,$0F,$0F ; bg1 
.byte $0F,$0F,$1F,$0F ; bg2 
.byte $0F,$0F,$0F,$0F ; bg3 
.byte $0F,$06,$37,$30 ; sp0 
.byte $0F,$15,$37,$30 ; sp1 
.byte $0F,$11,$36,$31 ; sp2 
.byte $0F,$09,$14,$20 ; sp3 

testConvo:
    .asciiz "HEY THIS IS A TEST"
    .asciiz "PHRASE"
    .asciiz "ISNT THAT COOL"
    .byte $ff

STARTX=$06
STARTY=$02

.segment "CODE"
convoInit:
    lda #<testConvo
    sta master_ptr 
    lda #>testConvo
    sta master_ptr+1
    lda #GAME_CONVO 
    sta gameState 
    lda #$04
    jsr FamiToneMusicPlay
    lda #$00
    sta currentOffset
	sta $2001
    sta nmi_mask 
    sta nmi_scroll
    ldx #0
	: ; clear sprites
		sta oam, X
		inx
        sta oam, X
		inx
        sta oam, X
		inx
        sta oam, X
		inx
		bne :-
    ldx #0
	:; store palettes in palette
		lda convo_palette, X
		sta palette, X
		inx
		cpx #32
		bcc :-
    jsr clear_nametable
    lda #$01
	sta	nmi_ready
    lda #STARTX
    sta byteX
    lda #STARTY
    sta byteY 
    rts 

convoNmi:
    ldy byteY 
    ldx byteX
    jsr ppu_address_tile
    lda byteToSay 
    cmp #$20
    beq :+
        sta $2007
    :
    rts 

convoUpdate:
    jsr writeLine
    jsr writeFace
    lda #$01
	sta	nmi_ready
    rts 

writeFace:
    lda #$0E
    sta faceY 
    lda #$01
    sta currentFace 
    jsr drawFace
    rts 

.segment "RODATA"
faces:
    .byte $81, $89, $91, $99
facePalettes:
    .byte $00, $01, $02, $03

START_FACE_X=$10

.segment "CODE"
drawFace:
    lda #START_FACE_X
    sta faceX
    lda currentFace 
    tay 
    lda faces,Y 
    sta faceTile 
    ldx #$00
    jsr drawSingleFaceSprite
    inc faceTile 
    inc faceTile 
    lda faceX 
    clc
    adc #$08
    sta faceX 
    jsr drawSingleFaceSprite
    inc faceTile 
    inc faceTile 
    lda faceX 
    clc
    adc #$08
    sta faceX 
    jsr drawSingleFaceSprite
    inc faceTile 
    inc faceTile 
    lda faceX 
    clc
    adc #$08
    sta faceX 
    jsr drawSingleFaceSprite
    
    ; second row
    lda #START_FACE_X
    sta faceX
    lda faces,Y 
    clc 
    adc #$20
    sta faceTile
    lda faceY
    adc #$10
    sta faceY 
    jsr drawSingleFaceSprite
    inc faceTile 
    inc faceTile 
    lda faceX 
    clc
    adc #$08
    sta faceX 
    jsr drawSingleFaceSprite
    inc faceTile 
    inc faceTile 
    lda faceX 
    clc
    adc #$08
    sta faceX 
    jsr drawSingleFaceSprite
    inc faceTile 
    inc faceTile 
    lda faceX 
    clc
    adc #$08
    sta faceX 
    jsr drawSingleFaceSprite
    rts 

drawSingleFaceSprite:
    lda faceY 
    sta oam,X  
    inx 
    lda faceTile
    sta oam,X 
    inx 
    lda facePalettes,Y 
    sta oam,X 
    inx 
    lda faceX 
    sta oam,X 
    inx 
    rts 

writeLine:
    ldy currentOffset   
    lda (master_ptr),Y 
    bne :+
        inc byteY 
        inc currentOffset
        lda #STARTX 
        sta byteX 
        iny     
        lda (master_ptr),Y 
    :
    cmp #$FF 
    beq :+
        sta byteToSay
        inc byteX 
        inc currentOffset
    :
    bne :+
        lda #$20 
        sta byteToSay
    :
    rts 
