.export convodata, facedata, convoperlevel

.segment "RODATA"
convoperlevel:
.byte $00,$01,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
convodata:
.word convo1, convo2
facedata:
.word face1 , face2

convo1:
    .asciiz "My name is Nicole."
    .asciiz "I live in this palace,"
    .asciiz "with my good friend"
    .asciiz "Princess Mary."
    .byte $ff
    .asciiz "Nicole you know I'm very"
    .asciiz "busy."
    .asciiz " "
    .asciiz " "
    .asciiz "*gunfire*"
    .byte $ff
    .asciiz " "
    .asciiz "If you're bored, why not"
    .asciiz "try cleaning the palace"
    .asciiz "basement or something."
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
    .asciiz "But I like her anyways."
    .asciiz "Let's go!"
    .byte $ff 
    .asciiz "And be on the lookout for"
    .asciiz "mice. They're the sworn"
    .asciiz "enemy of all cat-kind,"
    .asciiz "after all."
    .byte $ff
    .asciiz "Oh and Nicole, remember"
    .asciiz "you can only shoot an"
    .asciiz "enemy with the same"
    .asciiz "aspect as you!"
    .byte $ff, $ff

face1:
    .byte $00,$00
    .byte $01,$06
    .byte $01,$04
    .byte $00,$01
    .byte $03,$ff
    .byte $00,$02
    .byte $00,$03
    .byte $03,$ff
    .byte $ff

convo2:
    .asciiz "My name isn't Nicole."
    .asciiz "I don't live in this palace,"
    .asciiz "with my girlfriend"
    .asciiz "Princess Mary."
    .byte $ff, $ff

face2:
    .byte $00,$00
    .byte $ff
