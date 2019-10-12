; prng
;
; Returns a random 8-bit number in A (0-255), clobbers Y (0).
;
; Requires a 2-byte value on the zero page called "seed".
; Initialize seed to any value except 0 before the first call to prng.
; (A seed value of 0 will cause prng to always return 0.)
;
; This is a 16-bit Galois linear feedback shift register with polynomial $0039.
; The sequence of numbers it generates will repeat after 65535 calls.
;
; Execution time is an average of 125 cycles (excluding jsr and rts)
;
; Source: https://wiki.nesdev.com/w/index.php/Random_number_generator

.exportzp seed 
.export prng

.segment "ZEROPAGE"
seed: .res 2       ; initialize 16-bit seed to any value except 0

.segment "CODE"
prng:
	ldy #8     ; iteration count (generates 8 bits)
	lda seed+0
:
	asl        ; shift the register
	rol seed+1
	bcc :+
	eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out
:
	dey
	bne :--
	sta seed+0
	cmp #0     ; reload flags
	rts
