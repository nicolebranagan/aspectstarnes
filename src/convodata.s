.export convodata, facedata

.segment "RODATA"
convodata:
.word convo1 
facedata:
.word face1

convo1:
    .asciiz "Hey this is a test"
    .asciiz "phrase, now with"
    .asciiz "punctuation!"
    .byte $ff
    .asciiz "Oh my, Nicole! You"
    .asciiz "managed to do the"
    .asciiz "obvious!"
    .byte $ff
    .asciiz "Haha I bet that was"
    .asciiz "sarcastic"
    .byte $ff
    .asciiz "I'm not keeping track"
    .asciiz "of who's saying what."
    .byte $ff
    .asciiz "I'm a stuffed animal"
    .asciiz "So I shouldn't be"
    .asciiz "saying anything!"
    .byte $ff, $ff

face1:
    .byte $00,$ff
    .byte $01,$ff
    .byte $02,$ff
    .byte $00,$ff
    .byte $03,$ff
    .byte $00,$ff
    .byte $ff
