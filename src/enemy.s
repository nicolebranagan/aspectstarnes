.importzp nmi_count, FACING_DOWN, FACING_UP, FACING_LEFT, FACING_RIGHT, xpos, ypos, aspect, current_tile, bullety, bulletx, bulletasp, gameState, GAME_DEAD, pointer, currentLevel, GAME_WIN
.importzp lives
.import oam, is_solid, get_map_tile_for_x_y, map_attributes, game_die, enemy_data
.import FamiToneMusicStop, FamiToneSfxPlay
.import prng
.export enemy_draw, enemy_init, enemy_update, enemy_x, enemy_y, enemy_asp, enemy_face, enemy_attr

.segment "ZEROPAGE"
enemy_x:    .res 8
enemy_y:    .res 8
enemy_asp:  .res 8
enemy_face: .res 8
enemy_attr: .res 8
enemy_ptr:  .res 2

temp:       .res 1
tempx:      .res 1
tempy:      .res 1
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

.macro absSub   del
    .scope 
    sec 
    sbc del
    bpl :+
        eor #$FF
        clc 
        adc #$01
    :
    .endscope 
.endmacro

.macro enemSolidX delx 
    .local @done 
        enemSolidSinglePoint delx, #$00 
    bcs @done 
        enemSolidSinglePoint delx, #$07
    bcs @done 
        enemSolidSinglePoint delx, #$F9
    @done:
.endmacro 

.macro enemSolidY dely 
    .local @done 
        enemSolidSinglePoint #$00, dely
    bcs @done 
        enemSolidSinglePoint #$07, dely
    bcs @done 
        enemSolidSinglePoint #$F9, dely
    @done:
.endmacro 

.macro enemSolidSinglePoint    delx, dely
    .local @done
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
    bcs @done
    @done:
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
        lda #$00
        sta enemy_face,X 
        lda #$00
        sta enemy_attr,X 
        inx 
        cpx #$08
        bne :-
    lda currentLevel
    asl 
    tax 
    lda enemy_data, X 
    sta pointer
    lda enemy_data+1,X 
    sta pointer+1 
    ldx #0
    ldy #0 
        @loop:
        lda (pointer),Y 
        cmp #$FF 
        beq @done
        sta enemy_attr,X 
        iny 
        lda (pointer),Y 
        sta enemy_y,X 
        iny 
        lda (pointer),Y 
        sta enemy_x,X 
        iny 
        lda (pointer),Y 
        sta enemy_asp,X 
        iny 
        inx 
        jmp @loop
    @done:
    rts 

enemy_update:
    ldx #$00
    :
        jsr update_single_enemy
        inx 
        cpx #$08
        bne :-
    lda gameState 
    cmp #GAME_DEAD 
    beq :+
        jsr enemy_enemy_collision
    :
    rts 

update_single_enemy:
    lda enemy_y,X
    cmp #$FF
    bne :+
        rts 
    :

    lda enemy_face,X 
    cmp #$FF ; is this an explosion
    bne :++
    	lda nmi_count
	    and #%00000011
        bne :+ 
        inc enemy_attr,X 
        lda #$08
        cmp enemy_attr,X  
        bne :+
            lda #$FF
            sta enemy_y,X 
            jsr no_enemy_left
        :
        rts 
    :
    jsr check_if_dead
    jsr check_if_player_dead
    lda gameState 
    cmp #GAME_DEAD 
    bne :+
        rts 
    :
    cmp #GAME_WIN 
    bne :+
        rts 
    :
    lda enemy_face,X 
    cmp #$FF ; is this an explosion
    bne :+
        rts 
    :

    jsr check_enemy_aspect

    txa 
    pha 
    lda enemy_attr,X 
    asl 
    tax 
    lda enemyJumpTable+1,X 
    sta enemy_ptr+1 
    lda enemyJumpTable,X 
    sta enemy_ptr 
    pla 
    tax 
    jmp (enemy_ptr)

.segment "RODATA"
enemyJumpTable:
    .word mouse_update, bird_update, dog_update

.segment "CODE"

mouse_update:
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
    bne :+
        rts 
    :
enemy_move:
    lda enemy_face,X
    cmp #FACING_DOWN
    bne :+
        inc enemy_y,X
        enemSolidY #$08
        bcc :+
        dec enemy_y,X
    :
    lda enemy_face,X
    cmp #FACING_UP
    bne :+
        dec enemy_y,X
        enemSolidY #$F8
        bcc :+
        inc enemy_y,X
    :
    lda enemy_face,X
    cmp #FACING_RIGHT
    bne :+
        inc enemy_x,X
        enemSolidX #$08
        bcc :+
        dec enemy_x,X
    :
    lda enemy_face,X
    cmp #FACING_LEFT
    bne :+
        dec enemy_x,X 
        enemSolidX #$F8
        bcc :+
        inc enemy_x,X  
    :
    rts 

bird_update:
    jsr prng
    cmp #$f0 
    bcc @done
        jsr prng 
        and #%00000011
        sta enemy_face,X 
    @done:
    jsr prng  
    cmp #$50
    bcc :+
        jmp enemy_move
    :
    rts 

dog_update:
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
    lda nmi_count
    and #%00000111
    bne :+
        rts 
    :
    jmp enemy_move

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
    sta enemy_asp,X
    txa 
    pha 
    ldx #$00
	lda #$01
	jsr FamiToneSfxPlay
    pla 
    tax   
    :
    rts 
    @done:
    pla 
    tax 
    rts 

check_if_dead:
    lda enemy_face,X 
    cmp #$FF 
    bne :+
        rts 
    :
    lda enemy_x,X 
    absSub bulletx 
    cmp #$08
    bcc :+
        rts 
    :
    lda enemy_y,X 
    absSub bullety 
    cmp #$08
    bcc :+
        rts 
    :
    lda #$FF 
    sta bullety
    lda enemy_asp,X 
    cmp bulletasp 
    beq :+
        rts 
    :
    lda #$FF 
    sta enemy_face,X 
    lda #$00
    sta enemy_asp,X 
    sta enemy_attr,X 
    txa 
    pha 
    lda #$03
    ldx #$00
    jsr FamiToneSfxPlay
    pla 
    tax  
    rts 

check_if_player_dead:
    lda gameState 
    cmp #GAME_WIN 
    bne :+
        rts 
    :
    lda enemy_x,X 
    absSub xpos 
    cmp #$0c
    bcc :+
        rts 
    :
    lda enemy_y,X 
    absSub ypos  
    cmp #$0C
    bcc :+
        rts 
    :
    ldx #$01
    :
        lda #$FF
        sta enemy_y,X ; Store 255 in the y position
        lda #$00
        sta enemy_face,X 
        lda #$00
        sta enemy_attr,X 
        inx 
        cpx #$08
        bne :-
    ldx #$01

    lda ypos 
    sta enemy_y 
    sta enemy_y,X 
    inc enemy_y
    inc enemy_y
    inc enemy_y

    lda xpos 
    sta enemy_x 
    sta enemy_x,X 

    lda #$02 
    sta enemy_face 
    sta enemy_face,X 

    lda #$04
    sta enemy_attr 
    lda #$05
    sta enemy_attr,X 

    lda aspect
    sta enemy_asp,X 
    lda #$00
    sta enemy_asp 

    jmp game_die

enemy_enemy_collision:
    ldy #$00
    ldx #$01
    innerLoop:
        lda enemy_y,Y 
        cmp #$FF 
        beq doneComparison
        lda enemy_y,X 
        cmp #$FF 
        beq doneComparison 
        sta temp 
        lda enemy_y,Y 
        absSub temp 
        sta tempy 
        cmp #$0C
        bcs doneComparison
        lda enemy_x,X 
        sta temp 
        lda enemy_x,Y 
        absSub temp
        sta tempx 
        cmp #$0C
        bcs doneComparison
            lda tempx 
            cmp tempy 
            bcs @ygreater
                ; del x > del y
                lda enemy_x,X 
                cmp enemy_x,Y 
                bcc :+
                    inc enemy_x,X 
                    txa 
                    pha 
                    tya 
                    tax 
                    dec enemy_x,X 
                    pla 
                    tax 
                    jmp doneComparison
                :
                    dec enemy_x,X 
                    txa 
                    pha 
                    tya 
                    tax 
                    inc enemy_x,X 
                    pla 
                    tax 
                    jmp doneComparison 
            @ygreater:
                lda enemy_y,X 
                cmp enemy_y,Y 
                bcc :+
                    inc enemy_y,X 
                    txa 
                    pha 
                    tya 
                    tax 
                    dec enemy_y,X  
                    pla 
                    tax 
                    jmp doneComparison
                :
                    dec enemy_y,X 
                    txa 
                    pha 
                    tya 
                    tax 
                    inc enemy_y,X 
                    pla 
                    tax 
                    jmp doneComparison 
        doneComparison:
        inx 
        cpx #$08 
        beq :+
            jmp innerLoop 
        :
        iny 
        tya 
        tax 
        inx 
        cpy #$07 
        beq :+
            jmp innerLoop 
        :
    rts 

no_enemy_left:
    lda gameState 
    cmp #GAME_DEAD 
    bne :+
        rts 
    :
    ldx #$00
    :
        lda enemy_y,X 
        cmp #$FF 
        bne @enemyalive
        inx 
        cpx #$08
        bne :-
    lda #GAME_WIN 
    sta gameState
    jsr FamiToneMusicStop 
    txa 
    pha 
    lda #$04
    ldx #$00
    jsr FamiToneSfxPlay
    pla 
    txa 
    inc lives
    inc lives 
    inc lives
    lda lives 
    cmp #$09
    bcc :+
        lda #$09
        sta lives
    :
    rts 
    @enemyalive:
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
    .byte $20, $21, $22, $23 ; mouse
    .byte $24, $25, $26, $27
    .byte $28, $29, $2a, $2b
    .byte $2c, $2d, $2e, $2f
    .byte $30, $31, $32, $33 ; bird
    .byte $34, $35, $36, $37
    .byte $38, $39, $3a, $3b
    .byte $3c, $3d, $3e, $3f
    .byte $60, $61, $62, $63 ; dog
    .byte $64, $65, $66, $67
    .byte $68, $69, $6a, $6b
    .byte $6c, $6d, $6e, $6f
    .byte $20, $21, $22, $23 ; train
    .byte $24, $25, $26, $27
    .byte $58, $59, $5a, $5b
    .byte $5c, $5d, $5e, $5f
    .byte $20, $21, $22, $23 ; death
    .byte $24, $25, $26, $27
    .byte $4c, $4d, $00, $00
    .byte $4e, $4f, $00, $00
    .byte $20, $21, $22, $23 ; death2
    .byte $24, $25, $26, $27
    .byte $50, $51, $52, $53
    .byte $54, $55, $56, $57
    .byte $e0, $e1, $e2, $e3 ; explosion  frames
    .byte $e4, $e5, $e6, $e7
    .byte $e8, $e9, $ea, $eb 
    .byte $ec, $ed, $ee, $ef
    .byte $f0, $f1, $f2, $f3 ; explosion 1
    .byte $f4, $f5, $f6, $f7
    .byte $f8, $f9, $fa, $fb 
    .byte $fc, $fd, $fe, $ff

.segment "CODE"
;
; call with enemy ID in "X", incrementing location in OAM in Y
;
draw_single_enemy:
    lda enemy_face,X 
    cmp #$FF 
    bne :+
        lda enemy_attr,X 
        clc 
        adc #$18
        sta frame 
        lda #$00
        sta flipped 
        jmp @got_frame_and_flipped
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
    ; choose enemy type
    lda enemy_attr,X 
    asl 
    asl 
    clc 
    adc frame
    sta frame

    @got_frame_and_flipped:
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
