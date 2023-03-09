.export convodata, facedata, convoperlevel

.segment "RODATA"
convoperlevel:
.byte $0=0,$FF,$FF,$01,$FF,$FF,$02,$FF,$FF,$03
convodata:
.word convo1, convo2, convo4, convo5
facedata:
.word face1 , face2 , face4 , face5

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

convo4:
    .asciiz "Who's there?!"
    .asciiz "        "
    .asciiz "        "
    .asciiz "        "
    .byte $ff 
    .asciiz "Hi, Nicole. It's me!"
    .asciiz "Your friend, the dog"
    .asciiz "-girl alien from"
    .asciiz "Sirius. How you doing?"
    .byte $ff
    .asciiz "You again?! Why are "
    .asciiz "you here?"
    .asciiz "And weren't you from"
    .asciiz "Vega V?"
    .byte $ff
    .asciiz "I'm just here to keep"
    .asciiz "you company. You look so"
    .asciiz "sad and lonely."
    .asciiz "        "
    .byte $ff
    .asciiz "I don't want your"
    .asciiz "company! Go away!"
    .asciiz "        "
    .asciiz "        "
    .byte $ff
    .asciiz "Oh don't be like that."
    .asciiz "I thought we were"
    .asciiz "friends, aren't we?"
    .asciiz "        "
    .byte $ff
    .asciiz "We're not friends!"
    .asciiz "        "
    .asciiz "        "
    .asciiz "        "
    .byte $ff
    .asciiz "You're just a figment"
    .asciiz "of my imagination,"
    .asciiz "taunting me!"
    .asciiz "        "
    .byte $ff
    .asciiz "Suit yourself. But I'll"
    .asciiz "always be here."
    .asciiz "Watching you."
    .asciiz "        "
    .byte $ff
    .asciiz "Waiting for you to"
    .asciiz "crack.        "
    .asciiz "        "
    .asciiz "        "
    .byte $ff
    .asciiz "No, no, no! I'll never"
    .asciiz "crack! You can't stop me!"
    .asciiz "        "
    .asciiz "        "
    .byte $ff
    .asciiz "Nicole, calm down! It'll"
    .asciiz "be okay!"
    .asciiz "        "
    .asciiz "        "
    .byte $ff
    .asciiz "But it's not okay."
    .asciiz "You'll never be able to"
    .asciiz "undo what you did."
    .asciiz "        "
    .byte $ff
    .asciiz "I can't take it anymore!"
    .asciiz "        "
    .asciiz "        "
    .asciiz "        "
    .byte $ff
    .asciiz "Please Nicole, calm "
    .asciiz "down! Take it one step"
    .asciiz "at a time! You have me"
    .asciiz "still, and you have "
    .asciiz "yourself. Please..."
    .byte $ff,$ff

face4:
    .byte $00,$01,$01,$00
    .byte $02,$08,$00,$00
    .byte $00,$01,$00,$00
    .byte $02,$0b,$00,$00
    .byte $00,$03,$00,$00
    .byte $02,$09,$00,$00
    .byte $00,$01,$00,$00
    .byte $00,$01,$01,$00
    .byte $02,$0a,$00,$00
    .byte $02,$0b,$00,$00
    .byte $00,$01,$01,$00
    .byte $03,$ff,$00,$00
    .byte $02,$0b,$00,$00
    .byte $00,$02,$01,$00
    .byte $03,$ff,$00,$00
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
