SECTION "Process Input", ROM0

; Process the user's inputs and update the game state accordingly
ProcessInput:
    ldh a, [hCurrentKeys]      ; Load the newly pressed keys byte into A
    bit PADB_LEFT, a
    ld bc, $00ff
    ld d, FACE_LEFT
    jp nz, CheckMoving    ; If LEFT is pressed, start moving left

    bit PADB_RIGHT, a   ; Check the state of the RIGHT bit in A
    ld bc, $0001        ; Preload B/C with dy/dx for left movement (0, +1)
    ld d, FACE_RIGHT    ; Preload D with the facing value for RIGHT
    jp nz, CheckMoving ; If the bit was set, start moving in that direction

    bit PADB_UP, a      ; Check the state of the UP bit in A
    ld bc, $ff00        ; Preload B/C with dy/dx for left movement (-1, 0)
    ld d, FACE_UP       ; Preload D with the facing value for UP
    jp nz, CheckMoving ; If the bit was set, jump to attempt movement in that direction
    
    bit PADB_DOWN, a    ; Check the state of the DOWN bit in A
    ld bc, $0100        ; Preload B/C with dy/dx for left movement (+1, 0)
    ld d, FACE_DOWN     ; Preload D with the facing value for DOWN
    jp nz, CheckMoving ; If the bit was set, jump to attempt movement in that direction

    ; Check if A button is pressed (bit 0)
    bit PADB_A, a
    jr nz, PressA

    ; Check if B button is pressed (bit 4)
    bit PADB_B, a
    jr nz, PressB

   ret 

PressA:
    call TryDialogueA
ret

PressB:
    call TryDialogueB

ret