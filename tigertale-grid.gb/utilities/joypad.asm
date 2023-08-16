;============================================================================================================================
; Joypad Handling
;============================================================================================================================

SECTION "Joypad Variables", HRAM
; Reserve space in HRAM to track the joypad state
hCurrentKeys:   ds 1    ; Current keys
hNewKeys:       ds 1    ; Newly pressed keys

SECTION "Joypad Routine", ROM0

; Update the newly pressed keys (hNewKeys) and the held keys (hCurrentKeys) in memory
; Note: This routine is written to be easier to understand, not to be optimized for speed or size
UpdateJoypad:
    ; Poll half the controller
    ld a, P1F_GET_BTN   ; Load a flag into A to select reading the buttons
    ldh [rP1], a        ; Write the flag to P1 to select which buttons to read
    ldh a, [rP1]        ; Perform a few dummy reads to allow the inputs to stabilize
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ; The final read of the register contains the key state we'll use
    or $f0              ; Set the upper 4 bits, and leave the action button states in the lower 4 bits
    ld b, a             ; Store the state of the action buttons in B

    ld a, P1F_GET_DPAD  ; Load a flag into A to select reading the dpad
    ldh [rP1], a        ; Write the flag to P1 to select which buttons to read
    call .knownRet      ; Call a known `ret` instruction to give the inputs to stabilize
    ldh a, [rP1]        ; Perform a few dummy reads to allow the inputs to stabilize
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ; The final read of the register contains the key state we'll use
    or $f0              ; Set the upper 4 bits, and leave the dpad state in the lower 4 bits

    swap a              ; Swap the high/low nibbles, putting the dpad state in the high nibble
    xor b               ; A now contains the pressed action buttons and dpad directions
    ld b, a             ; Move the key states to B

    ld a, P1F_GET_NONE  ; Load a flag into A to read nothing
    ldh [rP1], a        ; Write the flag to P1 to disable button reading

    ldh a, [hCurrentKeys] ; Load the previous button+dpad state from HRAM
    xor b               ; A now contains the keys that changed state
    and b               ; A now contains keys that were just pressed
    ldh [hNewKeys], a   ; Store the newly pressed keys in HRAM
    ld a, b             ; Move the current key state back to A
    ldh [hCurrentKeys], a ; Store the current key state in HRAM
.knownRet
    ret