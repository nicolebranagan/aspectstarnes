.export convodata, facedata, convoperlevel

.segment "RODATA"
convoperlevel:
.byte $00,$01,$FF,$02,$FF,$FF,$FF,$FF,$FF,$FF
convodata:
.word convo4, convo2, convo3, convo4
facedata:
.word face4 , face2 , face3 , face4

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
    .asciiz "There sure are a lot of"
    .asciiz "mice here..."
    .byte $ff
    .asciiz "Maybe I should ask the"
    .asciiz "Princess what to do"
    .asciiz "about them all."
    .byte $ff
    .asciiz "Isn't she busy?"
    .asciiz "Can't you take care of"
    .asciiz "them yourself?"
    .byte $ff
    .asciiz "Good call, Zip!"
    .asciiz "Those mice are no match"
    .asciiz "for a well trained cat!"
    .byte $ff
    .asciiz "So I should do a half"
    .asciiz "decent job at least,"
    .asciiz "right?"
    .byte $ff,$ff

face2:
    .byte $00,$03
    .byte $00,$00
    .byte $03,$ff
    .byte $00,$02
    .byte $00,$07
    .byte $ff

convo3:
    .asciiz "Hey Nicole, look over"
    .asciiz "here, behind this wall!"
    .byte $ff
    .asciiz "How'd you manage to see"
    .asciiz "that from within my"
    .asciiz "pocket, Zip--"
    .byte $ff
    .asciiz "Holy crap! It's an"
    .asciiz "entire hidden base!"
    .byte $ff
    .asciiz "We're in trouble now!"
    .asciiz "The mice have joined"
    .asciiz "with the birds to"
    .asciiz "wipe out all felinity!"
    .byte $ff
    .asciiz "And only I can save"
    .asciiz "the day!"
    .byte $ff
    .asciiz "Well, cats had a good"
    .asciiz "run."
    .byte $ff, $ff 

face3:
    .byte $03,$ff
    .byte $00,$07 
    .byte $00,$01
    .byte $03,$ff 
    .byte $00,$02
    .byte $03,$ff
    .byte $ff

convo4:
    .asciiz "Well, Zip, we fought off"
    .asciiz "the birds, but who could"
    .asciiz "be behind all of this?"
    .byte $ff 
    .asciiz "Maybe it's just rational"
    .asciiz "self-interest; we do eat"
    .asciiz "mice and birds, after"
    .asciiz "all."
    .byte $ff
    .asciiz "No, no, there has to be"
    .asciiz "someone behind this..."
    .byte $ff
    .asciiz "Wan-wan!"
    .byte $ff
    .asciiz "Oh my gosh! The dog"
    .asciiz "aliens from Sirius, the"
    .asciiz "dog star! Of course!"
    .byte $ff
    .asciiz "We're not from Sirius,"
    .asciiz "we're from Vega V!"
    .byte $ff
    .asciiz "But... that has nothing"
    .asciiz "to do with dogs. I"
    .asciiz "don't get it."
    .byte $ff
    .asciiz "Look. You may have"
    .asciiz "ruined our plans here,"
    .asciiz "but we're still going to"
    .asciiz "take over the world!"
    .byte $ff
    .asciiz "But I live in the world!"
    .byte $ff
    .asciiz "Too bad!"
    .byte $ff
    .asciiz "We'll be hiding in the"
    .asciiz "one place that hasn't"
    .asciiz "been corrupted by"
    .asciiz "cat-ipalism..."
    .byte $ff
    .asciiz "SPACE!"
    .asciiz " "
    .asciiz " "
    .asciiz "Wan-wan!"
    .byte $ff,$ff

face4:
    .byte $00,$00
    .byte $03,$ff
    .byte $00,$03
    .byte $02,$08
    .byte $00,$01
    .byte $02,$0b
    .byte $00,$07
    .byte $02,$0a 
    .byte $00,$01
    .byte $02,$08
    .byte $02,$0a
    .byte $02,$08
    .byte $ff
