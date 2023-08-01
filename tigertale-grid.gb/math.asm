; math.asm - Contains math-related functions

SECTION "Math Functions", ROM0

; Inputs:
; B: First 8-bit number (multiplicand)
; C: Second 8-bit number (multiplier)
; Output:
; HL: Result of the multiplication (16-bit product)
MULTIPLY:
    ; Implementation of the multiplication function (same as in the previous example)

    xor a            ; Clear the accumulator to hold the result
    ld hl, 0         ; Initialize HL as the result (HL = 0)

.multiply_loop:
    cp 0             ; Check if C (multiplier) is 0
    ret z            ; If C is 0, the multiplication is done, return with HL as the result

    add hl, hl       ; Shift the current result in HL left (multiply by 2)
    rl c             ; Shift C's MSB into the carry flag (CF)
    jr nc, .skip_add ; If CF is 0, skip the addition

    add hl, de       ; Add A (multiplicand) to the result in HL
.skip_add:
    dec c            ; Decrement C (multiplier)
    jr .multiply_loop ; Loop until C becomes 0

    ret
