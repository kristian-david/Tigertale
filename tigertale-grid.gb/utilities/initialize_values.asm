; initialize_values.asm

SECTION "Initialization", ROM0

InitializeValues:
    ; Setup palettes and scrolling
    ld a, %11100100     ; Define a 4-shade palette from darkest (11) to lightest (00)
    ldh [rBGP], a       ; Set the background palette
    ld a, %11010000     ; Define a 4-shade palette which omits the 10 value to increase player contrast
    ldh [rOBP0], a      ; Set an object palette
    ld a, %11010000     ; Define a 4-shade palette which omits the 10 value to increase player contrast
    ldh [rOBP1], a      ; Set an object palette

    ; Set the scroll position of the camera
    ld a, -56             ; Load the desired X coordinate into A
    ldh [rSCX], a       ; Set the horizontal camera position (SCX) to the desired X coordinate
    ld a, -40             ; Load the desired Y coordinate into A
    ldh [rSCY], a       ; Set the vertical camera position (SCY) to the desired Y coordinate

    ; Set the position of the Window layer
    ld a, 137
    ld [rWY], a
    ld a, 7
    ld [rWX], a

    ldh [hCurrentKeys], a ; Zero our current keys just to be safe (A is already zero from earlier)
    
    ret
