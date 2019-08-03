.importzp aspect, xpos, ypos, facing, FACING_UP, FACING_DOWN, FACING_LEFT, FACING_RIGHT
.import is_solid, oam

.export bullet_init, bullet_draw, bullet_fire, bullet_update

.segment "ZEROPAGE"
bulletx:    .res 1
bullety:    .res 1
bulletasp:  .res 1
bulletface: .res 1

;
; bullet routines
;
.segment "CODE"
bullet_init:
    lda #$FF 
    sta bullety 
    rts 

BULLET_SPRITE=$00

bullet_draw:
    lda bullety
    sec 
    sbc #$03
    sta oam+(BULLET_SPRITE*4)+0
    lda #$1C
    clc 
    adc bulletasp
    sta oam+(BULLET_SPRITE*4)+1
    lda bulletasp
    sta oam+(BULLET_SPRITE*4)+2
    lda bulletx
    sec 
    sbc #$03
    sta oam+(BULLET_SPRITE*4)+3
    rts

bullet_fire:
    lda #$FF
    cmp bullety
    beq :+
    rts ; only fire if there's no bullet already
    :
    lda aspect
    sta bulletasp
    lda xpos
    sta bulletx
    lda ypos
    sta bullety
    lda facing
    sta bulletface
    rts 

bullet_update:
    lda #$FF
    cmp bullety
    bne @bullet_exists
    rts ; don't run anything if there's no bullet
    @bullet_exists:
    ldy bullety
    ldx bulletx
    jsr is_solid
    bcc :+
        lda #$FF ; bullet hit a wall
        sta bullety 
        rts 
    :
    lda bulletface
    cmp #FACING_DOWN
    bne :+
        inc bullety
        inc bullety
    :
    cmp #FACING_UP
    bne :+
        dec bullety
        dec bullety
    :
    cmp #FACING_RIGHT
    bne :+
        inc bulletx
        inc bulletx
    :
    cmp #FACING_LEFT
    bne :+
        dec bulletx
        dec bulletx
    :
    rts 
