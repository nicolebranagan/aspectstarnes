.export convodata, facedata

.segment "RODATA"
convodata:
.word convo1 
facedata:
.word face1

convo1:
    .asciiz "My name is Nicole."
    .asciiz "I live in this palace,"
    .asciiz "with my girlfriend"
    .asciiz "Princess Mary."
    .byte $ff
    .asciiz "Nicole you know I'm very"
    .asciiz "busy. If you're bored,"
    .asciiz "go clean the basement"
    .asciiz "or something."
    .byte $ff
    .asciiz "That sounded boring, but"
    .asciiz "I decided to ask my "
    .asciiz "stuffed animal Zip."
    .asciiz "She's not sentient."
    .byte $ff
    .asciiz "You should definitely"
    .asciiz "take a look downstairs!"
    .asciiz "Just stop bothering me,"
    .asciiz "okay?"
    .byte $ff
    .asciiz "Zip isn't very nice"
    .asciiz "sometimes."
    .byte $ff, $ff

face1:
    .byte $00,$ff
    .byte $01,$ff
    .byte $00,$ff
    .byte $03,$ff
    .byte $00,$ff
    .byte $ff
