.export convodata, facedata, convoperlevel

.segment "RODATA"
convoperlevel:
.byte $00,$FF,$FF,$01,$FF,$FF,$03,$FF,$FF,$04
convodata:
.word convo1, convo2, convo3, convo4, convo5
facedata:
.word face1 , face2 , face3 , face4 , face5

convo1:
    .asciiz "My name is Nicole."
    .asciiz "I live in this palace,"
    .asciiz "with my good friend"
    .asciiz "Zip and no one else."
    .byte $ff
    .asciiz "          "
    .asciiz "          "
    .asciiz "          "
    .asciiz "          "
    .byte $ff
    .asciiz "Zip is not sentient. It"
    .asciiz "is so lonely here..."
    .asciiz " "
    .asciiz " "
    .byte $ff
    .asciiz "          "
    .asciiz "          "
    .asciiz "          "
    .asciiz "          "
    .byte $ff
    .asciiz "If only I had tried"
    .asciiz "harder..."
    .asciiz " "
    .asciiz " "
    .byte $ff
    .asciiz "          "
    .asciiz "          "
    .asciiz "          "
    .asciiz "          "
    .byte $ff
    .asciiz "Zip isn't very nice"
    .asciiz "sometimes."
    .asciiz "But I like her anyways."
    .asciiz "Let's go!"
    .byte $ff
    .asciiz "I'm your best friend,"
    .asciiz "Nicole!"
    .asciiz "          "
    .asciiz "          "
    .byte $ff, $ff

face1:
    .byte $00,$00,$00,$00
    .byte $03,$ff,$01,$00
    .byte $00,$02,$00,$00
    .byte $03,$ff,$01,$00
    .byte $00,$00,$01,$00
    .byte $03,$ff,$00,$00
    .byte $00,$02,$00,$00
    .byte $03,$ff,$00,$00
    .byte $ff

convo2:
    .asciiz "I can't believe I did"
    .asciiz "that... Don't I have a"
    .asciiz "regret?"
    .byte $ff
    .asciiz "I'm sorry Nicole, I "
    .asciiz "don't know what to say."
    .asciiz " "
    .byte $ff
    .asciiz "You're supposed to make"
    .asciiz "me feel better, Zip!"
    .asciiz " "
    .byte $ff
    .asciiz "But you can't. You're "
    .asciiz "just a stupid toy. You "
    .asciiz "can't help me."
    .byte $ff
    .asciiz "Hey, I'm not stupid!"
    .asciiz "I'm here for you,"
    .asciiz "Nicole. Always."
    .byte $ff
    .asciiz "No you're not. You're"
    .asciiz "just a toy. And I'm "
    .asciiz "alone..."
    .byte $ff,$ff

face2:
    .byte $00,$00,$01,$00
    .byte $03,$ff,$00,$00
    .byte $00,$01,$00,$00
    .byte $00,$00,$01,$00
    .byte $03,$ff,$00,$00
    .byte $00,$02,$01,$00
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

convo5:
    .asciiz "I can't believe it!"
    .asciiz "All of our minutes of"
    .asciiz "scheming and planning"
    .asciiz "ruined!"
    .byte $ff
    .asciiz "All I can say about"
    .asciiz "this is..."
    .asciiz " "
    .asciiz "Wan-wan!"
    .byte $ff
    .asciiz "Wow, Zip, and to think"
    .asciiz "I thought going to the"
    .asciiz "basement would be"
    .asciiz "boring!"
    .byte $ff
    .asciiz "Beginner's luck."
    .asciiz "This is the first"
    .asciiz "Aspect Star game, after"
    .asciiz "all."
    .byte $ff
    .asciiz "I have no idea what"
    .asciiz "you're talking about,"
    .asciiz "Zip."
    .byte $ff
    .asciiz "An extraterrestrial"
    .asciiz "invasion? That sounds"
    .asciiz "terrifying!"
    .byte $ff
    .asciiz "You may have just"
    .asciiz "saved the whole empire,"
    .asciiz "Nicole!"
    .byte $ff
    .asciiz "For the empire, the day"
    .asciiz "I beat the dog aliens"
    .asciiz "from Vega V was a very"
    .asciiz "important day!"
    .byte $ff
    .asciiz "But for me, it was..."
    .asciiz " "
    .asciiz "What day of the week"
    .asciiz "is it again?"
    .byte $ff, $ff

face5:
    .byte $02,$09
    .byte $02,$08
    .byte $00,$02
    .byte $03,$ff
    .byte $00,$00
    .byte $01,$05
    .byte $01,$04
    .byte $00,$02
    .byte $00,$07
    .byte $ff
