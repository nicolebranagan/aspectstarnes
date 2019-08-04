.importzp nmi_count, FACING_DOWN, FACING_UP, FACING_LEFT, FACING_RIGHT, xpos, ypos, current_tile
.import oam, is_solid, get_map_tile_for_x_y, map_attributes
.export enemy_draw, enemy_init, enemy_update

.segment "ZEROPAGE"
enemy_x:    .res 8
enemy_y:    .res 8
enemy_asp:  .res 8
enemy_face: .res 8
enemy_attr: .res 8

temp:       .res 1
frame:      .res 1
flipped:    .res 1

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

.macro enemSolid    delx, dely
    txa 
    pha ; save X
    lda enemy_x,X 
    clc 
    adc delx 
    pha 
    lda enemy_y,X 
    clc 
    adc dely 
    tay 
    pla 
    tax 
    jsr is_solid 
    pla 
    tax 
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

enemy_update:
    ldx #$00
    :
        jsr update_single_enemy
        inx 
        cpx #$08
        bne :-
    rts 

update_single_enemy:
    lda enemy_y,X
    cmp #$FF
    bne :+
        rts 
    :
    jsr check_enemy_aspect
    lda nmi_count 
    adc enemy_y,X 
    and #%01010100
    bne @done
        lda ypos 
        sec 
        sbc enemy_y,X
        bpl :+ ; half-assed absolute value
            eor #$FF
            clc 
            adc #$01
        :
        sta frame 
        lda xpos 
        sec 
        sbc enemy_x,X 
        bpl :+
            eor #$FF
            clc 
            adc #$01
        :
        cmp frame 
        bcc :++
            ; X is the smaller dimension
            lda enemy_x,X
            cmp xpos 
            bcs :+
                lda #FACING_RIGHT 
                sta enemy_face,X
                jmp @done 
            :
            lda #FACING_LEFT
            sta enemy_face,X
            jmp @done
        :
            ; Y is the smaller dimension
            lda enemy_y,X
            cmp ypos 
            bcs :+
                lda #FACING_DOWN
                sta enemy_face,X
                jmp @done 
            :
            lda #FACING_UP
            sta enemy_face,X
            jmp @done
    @done:
    ; movement
    lda nmi_count
    and enemy_asp,X
    beq @finish
        lda enemy_face,X
        cmp #FACING_DOWN
        bne :+
            enemSolid #$00, #$08
            bcs @finish
            inc enemy_y,X
            jmp @finish
        :
        cmp #FACING_UP
        bne :+
            enemSolid #$00, #$F8
            bcs @finish
            dec enemy_y,X
            jmp @finish
        :
        cmp #FACING_RIGHT
        bne :+
            enemSolid #$08, #$00
            bcs @finish
            inc enemy_x,X
            jmp @finish
        :
        enemSolid #$F8, #$00
        bcs @finish
        dec enemy_x,X  
    @finish:
    rts 

check_enemy_aspect:
    txa 
    pha 
    lda enemy_x,X 
    lsr 
    lsr 
    lsr 
    pha 
    lda  enemy_y,X 
    lsr 
    lsr 
    lsr 
    tay 
    pla 
    tax 
    jsr get_map_tile_for_x_y
    lda current_tile
    tay 
    lda map_attributes,Y 
    and #%00001100 ; mask off aspect
    beq @done
    lsr 
    lsr 
    tay 
    pla 
    tax 
    tya 
    cmp enemy_asp,X
    beq :+
    ; TODO: play sound effect
    sta enemy_asp,X
    :
    rts 
    @done:
    pla 
    tax 
    rts 

enemy_draw:
    lda #$00
    sta temp
	; flicker
	lda nmi_count
	and #%00000111
    tax 
    ldy #$20
    :
        jsr draw_single_enemy 
        inx 
        cpx #$08
        bne :+
            ldx #$00
        :
        inc temp
        lda temp 
        cmp #$08
        bne :--
    rts 

.segment "RODATA"
enemy_sprites:
    .byte $20, $21, $22, $23
    .byte $24, $25, $26, $27
    .byte $28, $29, $2a, $2b
    .byte $2c, $2d, $2e, $2f

.segment "CODE"
;
; call with enemy ID in "X", incrementing location in OAM in Y
;
draw_single_enemy:
    lda enemy_y,X
    cmp #$FF
    bne :+
        rts 
    :
    ; get the animation cycle
    lda nmi_count
	and #%00001000
	lsr 
	lsr 
	lsr 
	sta flipped 

    ; get the frame 
    lda enemy_face,X 
    cmp #FACING_DOWN
    bne :+
        lda #$00
        sta frame 
    :
    lda enemy_face,X 
    cmp #FACING_UP
    bne :+
        lda #$01
        sta frame 
    :
    lda enemy_face,X 
    cmp #FACING_LEFT 
    bcc :++  ; Left or right
        lda #$02
        sta frame 
        lda flipped
        beq :+ 
            lda #$03
            sta frame
        :
        lda enemy_face,X 
        sec 
        sbc #$02
        sta flipped 
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

    ; save X
    txa
    pha
    ; get the frame
    lda frame
    ; multiply by 4
    clc 
    adc frame 
    adc frame
    adc frame
    tax 

    ; frame
    lda flipped
    beq :+
        ; X = 0
        inx ; X = 1
        lda enemy_sprites,X 
        sta oam,Y 
        dex  ; X = 0
        iny4
        lda enemy_sprites,X 
        sta oam,Y 
        inx ; X = 1
        inx ; X = 2
        inx ; X = 3
        iny4 
        lda enemy_sprites,X 
        sta oam,Y
        dex  
        iny4 
        lda enemy_sprites,X 
        sta oam,Y
        dey4
        dey4
        dey4
        iny
        jmp :++ 
    :
        lda enemy_sprites,X 
        sta oam,Y 
        inx 
        iny4
        lda enemy_sprites,X 
        sta oam,Y 
        inx 
        iny4 
        lda enemy_sprites,X 
        sta oam,Y
        inx 
        iny4 
        lda enemy_sprites,X 
        sta oam,Y
        dey4
        dey4
        dey4
        iny
    :

    ; get X back
    pla 
    tax 

    ; aspect color and attributes
    lda flipped 
    clc 
    ror 
    ror 
    ror 
    ora enemy_asp,X
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