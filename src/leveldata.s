.export enemy_data, level_data

.segment "RODATA"
level_data:
.word level1, level2, level3
enemy_data:
.word enemy1, enemy2, enemy3

level1: ; 16x15
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$05,$05,$00,$00,$00,$00,$00,$00,$05,$05,$00,$00,$01
.byte $01,$00,$01,$00,$00,$00,$01,$05,$05,$01,$00,$00,$00,$01,$00,$01
.byte $01,$00,$05,$00,$02,$00,$01,$00,$00,$01,$00,$02,$00,$05,$00,$01
.byte $01,$00,$00,$00,$00,$00,$05,$00,$00,$05,$00,$00,$00,$00,$00,$01
.byte $01,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$05,$05,$05,$00,$00,$00,$00,$00,$00,$05,$05,$05,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

enemy1:
; attr, Y coordinate, X coordinate, aspect
.byte $01, $a0, $80, $01
.byte $00, $c0, $40, $02
.byte $00, $c0, $b0, $03
.byte $ff

level2: ; 16x15
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$01,$01
.byte $01,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$01
.byte $01,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$01
.byte $01,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$01
.byte $01,$05,$05,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$05,$05,$01
.byte $01,$00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$05,$05,$05,$05,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$05,$05,$05,$01,$00,$00,$00,$00,$00,$00,$01,$05,$05,$05,$01
.byte $01,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$01
.byte $01,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

enemy2:
; attr, Y coordinate, X coordinate, aspect
.byte $00, $30, $20, $02
.byte $00, $30, $d9, $02
.byte $00, $80, $1a, $02
.byte $00, $80, $e0, $02
.byte $ff

level3:
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$01
.byte $01,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$01
.byte $01,$00,$00,$01,$00,$00,$02,$00,$00,$02,$00,$00,$01,$00,$00,$01
.byte $01,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$02,$00,$00,$02,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$00,$00,$00,$05,$01,$05,$05,$05,$05,$01,$05,$00,$00,$00,$01
.byte $01,$00,$03,$00,$00,$05,$00,$00,$00,$00,$05,$00,$00,$03,$00,$01
.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

enemy3:
.byte $00, $b0, $30, $03
.byte $00, $b0, $c0, $03
.byte $00, $40, $1a, $03
.byte $00, $40, $e0, $03
.byte $ff 
