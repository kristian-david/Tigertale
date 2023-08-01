SECTION "Movement", ROM0

; Process the user's inputs and update the game state accordingly
ProcessInput:
    ldh a, [hNewKeys]   ; Load the newly pressed keys byte into A
    bit PADB_LEFT, a    ; Check the state of the LEFT bit in A
    ld bc, $00ff        ; Preload B/C with dy/dx for left movement (0, -1)
    ld d, FACE_LEFT     ; Preload D with the facing value for LEFT
    jr nz, .attemptMove ; If the bit was set, jump to attempt movement in that direction
    bit PADB_RIGHT, a   ; Check the state of the RIGHT bit in A
    ld bc, $0001        ; Preload B/C with dy/dx for left movement (0, +1)
    ld d, FACE_RIGHT    ; Preload D with the facing value for RIGHT
    jr nz, .attemptMove ; If the bit was set, jump to attempt movement in that direction
    bit PADB_UP, a      ; Check the state of the UP bit in A
    ld bc, $ff00        ; Preload B/C with dy/dx for left movement (-1, 0)
    ld d, FACE_UP       ; Preload D with the facing value for UP
    jr nz, .attemptMove ; If the bit was set, jump to attempt movement in that direction
    bit PADB_DOWN, a    ; Check the state of the DOWN bit in A
    ld bc, $0100        ; Preload B/C with dy/dx for left movement (+1, 0)
    ld d, FACE_DOWN     ; Preload D with the facing value for DOWN
    jr nz, .attemptMove ; If the bit was set, jump to attempt movement in that direction
    ret                 ; No inputs to handle, return to main loop

; Attempt a move in a direction defined by the contents of BC and D
; @param: B Delta Y to apply to current player position
; @param: C Delta X to apply to current player position
; @param: D New facing direction value to apply
.attemptMove

    ld a, d             ; Move new facing direction from D to A
    ld [wPlayer.facing], a ; Store new facing direction regardless of move success

    ; Calculate the destination coordinates by applying the deltas
    ld a, [wPlayer.y]   ; Load the current player Y coordinate into A
    add b               ; Add the dY value from B to get the new Y coordinate
    ld b, a             ; Store the new Y coordinate back in B
    ld a, [wPlayer.x]   ; Load the current player X coordinate into A
    add c               ; Add the dX value from C to get the new X coordinate
    ld c, a             ; Store the new Y coordinate back in C

    ; Check if the attempted move is valid
    call GetTileID      ; Call a routine to get the tile ID at the B=y, C=x coordinates
    cp MAX_WALKABLE_TILE_ID ; Compare the tile ID from TilemapData to the maximum walkable tile ID
    ret nc              ; If the tile ID is greater than the maximum walkable tile ID, return

    ; Store the new coordinates
    ld a, b             ; Load the new Y coordinate into A
    ld [wPlayer.y], a   ; Store the new Y coordinate in memory
    ld a, c             ; Load the new X coordinate into A
    ld [wPlayer.x], a   ; Store the new X coordinate in memory

    ; Move the screen along with the player

    ; BUG, only left-right can change the direction

    ld a, [wPlayer.x] ; MAYBE JUST ADD PLAYERPOS.X TO CURRENT rSCX
    add 23             ; Camera offset 47.5 dapat
    add a               ; To convert the Y grid coordinate into screen coordinates we have to multiply
    add a               ;  by 8, which can be done quickly by adding A to itself 3 times
    add a               ;  ...
    ld [rSCX], a                ; Store the result in SCX

    ; xor a

    ld a, [wPlayer.y] ; MAYBE JUST ADD PLAYERPOS.X TO CURRENT rSCX
    sub 40             ; Camera offset 47.5 dapat
    add a               ; To convert the Y grid coordinate into screen coordinates we have to multiply
    add a               ;  by 8, which can be done quickly by adding A to itself 3 times
    add a               ;  ...
    ld [rSCY], a                ; Store the result in SCX

    ret