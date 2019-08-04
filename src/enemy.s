.importzp nmi_count, FACING_DOWN, FACING_UP, FACING_LEFT, FACING_RIGHT
.import oam
.export enemy_draw, enemy_init

.segment "ZEROPAGE"
enemy_x:    .res 8
enemy_y:    .res 8
enemy_asp:  .res 8
enemy_face: .res 8
enemy_attr: .res 8

.macro iny4
    iny
    iny
    iny
    iny
.endmacro

.macro dey4
    dey
    dey
    dey
    dey
.endmacro 

;
; enemy routines
;
; all enemies are in an array
;
.segment "CODE"
enemy_init:
    ldx #$00
    :
        lda #$FF
        sta enemy_y,X ; Store 255 in the y position
        lda #FACING_DOWN
        sta enemy_face,X 
        inx 
        cpx #$08
        bne :-
    lda #$40
    sta enemy_y
    sta enemy_x
    lda #$01
    sta enemy_asp 

    lda #$38
    sta enemy_y+1
    lda #$80
    sta enemy_x+1
    lda #$02
    sta enemy_asp+1

    lda #$40
    sta enemy_y+2
    lda #$B0
    sta enemy_x+2
    lda #$03
    sta enemy_asp+2

    rts 

enemy_draw:
	; alternate y order each phase
	lda nmi_count
	and #%00000001
    beq :++
    ldx #$00
    ldy #$20
    :
        jsr draw_single_enemy 
        inx 
        cpx #$08
        bne :-
    rts 
    :
    ldx #$07
    ldy #$20
    :
        jsr draw_single_enemy
        dex 
        cpx #$FF
        bne :-
    rts 

;
; call with enemy ID in "X", incrementing location in OAM in Y
;
draw_single_enemy:
    lda enemy_y,X
    cmp #$FF
    bne :+
        rts 
    :
    
    ; aspect icon
    lda enemy_y,X
    sec 
    sbc #$10
    sta oam,Y
    iny 
    lda enemy_asp,X
    sta oam,Y
    iny 
    sta oam,Y
    iny 
    lda enemy_x,X
    sec 
    sbc #$04
    sta oam,Y
    iny 

    ; y position
    lda enemy_y,X
    sec 
    sbc #$08
    sta oam,Y 
    iny4
    sta oam,Y 
    iny4 
    clc 
    adc #$08
    sta oam,Y 
    iny4 
    sta oam,Y 
    dey4
    dey4
    dey4
    iny

    ; frame
    lda #$20
    sta oam,Y 
    iny4
    lda #$21
    sta oam,Y 
    iny4 
    lda #$22
    sta oam,Y
    iny4 
    lda #$23
    sta oam,Y
    dey4
    dey4
    dey4
    iny

    ; aspect color
    lda enemy_asp,X
    sta oam,Y
    iny4 
    sta oam,Y
    iny4 
    sta oam,Y
    iny4 
    sta oam,Y
    dey4
    dey4
    dey4
    iny 

    ; x
    lda enemy_x,X
    sec 
    sbc #$08
    sta oam,Y
    iny4
    iny4 
    sta oam,Y
    dey4
    lda enemy_x,X 
    sta oam,Y
    iny4 
    iny4 
    sta oam,Y
    iny 

    rts 