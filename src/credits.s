.importzp gameState, GAME_CREDITS, nmi_ready, nmi_scroll, pointer, nmi_count
.import oam, ppu_address_tile
.import FamiToneMusicPlay, write_text_at_x_y, clear_nametable, clear_lower_nametable, FamiToneMusicStop
.export creditsInit, creditsUpdate
.import drawFace, gamepad_poll, title_init, palette
.importzp startFaceX, currentFace, currentSubFace, faceY, gamepad, PAD_START

.segment "ZEROPAGE"
waitTimer:      .res 1
scrollTimer:    .res 1

.segment "RODATA"
text_palette:
    .byte $0F,$30,$16,$00 ; bg0 title text
line2:
    .asciiz "By Nicole Express 2019"
line3:
    .asciiz "Based on ASPECT STAR"
line4:
    .asciiz "By Nicole 2015"
line5:
    .asciiz "Not licensed or"
line6:
    .asciiz "endorsed by Nintendo"
line7:
    .asciiz "Thanks for" 
line8:
    .asciiz "playing!"

.segment "CODE"
creditsInit:
    lda #$00
    sta $2001 
    sta nmi_scroll
    jsr clear_nametable 
    jsr clear_lower_nametable
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
		lda text_palette, X
		sta palette, X
		inx
		cpx #04
		bcc :-

    jsr write_logo

    lda #<line2
    sta pointer
    lda #>line2
    sta pointer+1 
    ldx #$05
    ldy #$0a
    jsr write_text_at_x_y

    lda #<line3
    sta pointer
    lda #>line3
    sta pointer+1 
    ldx #$06
    ldy #$0e
    jsr write_text_at_x_y

    lda #<line4
    sta pointer
    lda #>line4
    sta pointer+1 
    ldx #$09
    ldy #$10
    jsr write_text_at_x_y

    lda #<line5
    sta pointer
    lda #>line5
    sta pointer+1 
    ldx #$09
    ldy #$17
    jsr write_text_at_x_y

    lda #<line6
    sta pointer
    lda #>line6
    sta pointer+1 
    ldx #$06
    ldy #$18
    jsr write_text_at_x_y

    lda #<line7
    sta pointer
    lda #>line7
    sta pointer+1 
    ldx #$0a
    ldy #$4c
    jsr write_text_at_x_y

    lda #<line8
    sta pointer
    lda #>line8
    sta pointer+1 
    ldx #$0b
    ldy #$4e
    jsr write_text_at_x_y

    lda #GAME_CREDITS
    sta gameState 
    lda #$00 
    sta waitTimer
    jsr FamiToneMusicPlay
    rts 

LOGO_Y = $05
LOGO_X = $09
write_logo:
    ldy #LOGO_Y
    ldx #LOGO_X
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

creditsUpdate:
    lda waitTimer 
    cmp #$d0
    bcs :+
        inc waitTimer 
        lda #$01
        sta nmi_ready
        rts 
    :
    lda nmi_scroll
    cmp #$ef 
    beq :+
        inc nmi_scroll
        lda #$01
        sta nmi_ready
        rts 
    :
    jsr drawHappyFace
    lda waitTimer 
    cmp #$f0
    bcc :++
        jsr drawZip
        jsr gamepad_poll
        lda gamepad 
        and #PAD_START
        beq :+
            jsr FamiToneMusicStop
            jsr title_init
        :
    :
    lda waitTimer 
    cmp #$f0
    bcs :+
        lda nmi_count 
        and #%00000011
        bne :+
        inc waitTimer
    :
    lda #$01
    sta nmi_ready
    rts 

drawHappyFace:
    ldx #$00

    lda #$00
    sta currentFace 
    lda #$02
    sta currentSubFace
    lda #$70
    sta startFaceX 
    lda #$28
    sta faceY 
    jsr drawFace 

    lda #$01
    sta currentFace 
    lda #$04
    sta currentSubFace
    lda #$20
    sta startFaceX 
    lda #$48
    sta faceY 
    jsr drawFace 

    lda #$02
    sta currentFace 
    lda #$08
    sta currentSubFace
    lda #$b0
    sta startFaceX 
    lda #$60
    sta faceY 
    jsr drawFace 
    rts 

drawZip:
    lda #$03
    sta currentFace 
    lda #$ff
    sta currentSubFace
    lda #$90
    sta startFaceX 
    lda #$c8
    sta faceY 
    jsr drawFace 
    rts 
