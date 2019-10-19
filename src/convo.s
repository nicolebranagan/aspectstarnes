.importzp gameState, pointer, GAME_CONVO, nmi_ready, nmi_scroll, nmi_mask
.importzp PAD_A, gamepad, currentLevel, last_gamepad, PAD_START
.exportzp currentConvo
.export convoUpdate, convoInit, convoNmi
.import FamiToneMusicPlay, clear_nametable, oam, ppu_address_tile, palette
.import FamiToneMusicStop, FamiToneSfxPlay
.import gamepad_poll, game_preload
.import convodata, facedata

.segment "ZEROPAGE"
master_ptr:     .res 2
currentConvo:   .res 1
currentOffset:  .res 1
byteToSay:      .res 1
byteX:          .res 1
byteY:          .res 1 
faceX:          .res 1
faceY:          .res 1
currentFace:    .res 1
faceTile:       .res 1
phraseCount:    .res 1
temp:           .res 1
convoDone:      .res 1

.segment "BSS"
faceStorage:    .res 100

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

STARTX=$06
STARTY=$02

.segment "CODE"
convoInit:
    lda #GAME_CONVO 
    sta gameState 
    lda #$04
    jsr FamiToneMusicPlay
    lda #$00
    sta currentOffset
	sta $2001
    sta nmi_mask 
    sta nmi_scroll
    sta phraseCount
    sta convoDone
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
    jsr loadConvo
    lda #$01
	sta	nmi_ready
    lda #STARTX
    sta byteX
    lda #STARTY
    sta byteY 
    rts 

loadConvo:
    lda currentConvo 
    asl 
    tax 
    lda convodata,X 
    sta master_ptr 
    lda convodata+1,X 
    sta master_ptr+1 
    lda facedata,X 
    sta pointer 
    lda facedata+1,X 
    sta pointer+1 
    ldy #$00
    :
        lda (pointer),Y 
        sta faceStorage,Y 
        iny 
        lda (pointer),Y 
        sta faceStorage,Y 
        iny 
        lda (pointer),Y 
        cmp #$FF
        bne :-
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
    jsr handleInput
    lda #$01
	sta	nmi_ready
    rts 

writeFace:
    lda #$0E
    sta faceY 
    lda #$00
    sta temp 
    ldx #$00
    :
        txa 
        pha 
        lda temp
        asl 
        tax 
        lda faceStorage,X 
        sta currentFace 
        pla 
        tax 
        jsr drawFace
        lda #$18
        clc 
        adc faceY 
        sta faceY
        inc temp 
        lda temp 
        sec 
        sbc #$01
        cmp phraseCount 
        bcc :-
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
    beq :++
        sta byteToSay
        inc byteX 
        inc currentOffset
        bne :+
            inc master_ptr+1
        :
    :
    bne :+
        lda #$20 
        sta byteToSay
    :
    rts 

handleInput:
    jsr gamepad_poll
    lda gamepad 
    and #PAD_START
    beq :+
        lda last_gamepad 
        and #PAD_START 
        bne :+
        jmp goToLevel
    :
    lda convoDone 
    beq :++
        lda gamepad 
        and #PAD_A 
        beq :+
            jmp goToLevel
        :
        rts 
    :
    lda gamepad
    and #PAD_A
    beq @padAdone
        ldy currentOffset 
        lda (master_ptr),Y 
        cmp #$FF
        bne @padAdone
        inc currentOffset
        iny 
        bne :+
            inc master_ptr+1
        :
        lda (master_ptr),Y 
        cmp #$FF
        beq @convoDone
        inc phraseCount
        ldx phraseCount 
        lda #STARTY
        :
            clc 
            adc #$05
            dex 
            bne :-
        sta byteY 
    @padAdone:
    rts 
    @convoDone:
        lda #$01
        sta convoDone
    rts 

goToLevel:
    jsr FamiToneMusicStop
    lda #$04
    ldx #$00
    jsr FamiToneSfxPlay
    lda currentLevel
    jmp game_preload
