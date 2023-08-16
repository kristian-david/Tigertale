SECTION "Movement", ROM0

movementTimer: ds 0 ; 

; Process the user's inputs and update the game state accordingly
ProcessInput:
    ldh a, [hCurrentKeys]      ; Load the newly pressed keys byte into A
    bit PADB_LEFT, a
    ld bc, $00ff
    ld d, FACE_LEFT
    jr nz, .checkMoving    ; If LEFT is pressed, start moving left

    bit PADB_RIGHT, a   ; Check the state of the RIGHT bit in A
    ld bc, $0001        ; Preload B/C with dy/dx for left movement (0, +1)
    ld d, FACE_RIGHT    ; Preload D with the facing value for RIGHT
    jr nz, .checkMoving ; If the bit was set, start moving in that direction

    bit PADB_UP, a      ; Check the state of the UP bit in A
    ld bc, $ff00        ; Preload B/C with dy/dx for left movement (-1, 0)
    ld d, FACE_UP       ; Preload D with the facing value for UP
    jr nz, .checkMoving ; If the bit was set, jump to attempt movement in that direction
    
    bit PADB_DOWN, a    ; Check the state of the DOWN bit in A
    ld bc, $0100        ; Preload B/C with dy/dx for left movement (+1, 0)
    ld d, FACE_DOWN     ; Preload D with the facing value for DOWN
    jr nz, .checkMoving ; If the bit was set, jump to attempt movement in that direction

    ; Add similar checks for other directions (UP, DOWN)

    ret                 ; No inputs to handle, return to main loop

; Check if already moving before attempting to move
.checkMoving
    ld a, [movementState]  ; Load the current movement state into A
    cp MOVEMENT_MOVING   ; Check if the current state is "moving"
    jr nz, .attemptMove  ; If not moving, try to attempt movement

    ; Player is moving, do any animation or updates here if needed
    ; ...

    ; it seems working here so dito muna to
    ; call CheckTimer
    ret


; Attempt a move in a direction defined by the contents of BC and D
; @param: B Delta Y to apply to current player position
; @param: C Delta X to apply to current player position
; @param: D New facing direction value to apply
.attemptMove

    ld hl, moveDir        ; Load the address of the variable moveDirection into HL
    ld [hl], c            ; Store the lower byte of BC (register C) into moveDirection
    inc hl                ; Increment HL to point to the next memory location
    ld [hl], b            ; Store the upper byte of BC (register B) into the next memory location


    ld a, d             ; Move new facing direction from D to A
    ld [wPlayer.facing], a ; Store new facing direction regardless of move success

    ; Calculate the destination coordinates by applying the deltas
    ld a, [wPlayer.y]   ; Load the current player Y coordinate into A
    add b               ; Add the dY value from B to get the new Y coordinate
    ld b, a             ; Store the new Y coordinate back in B
    ld a, [wPlayer.x]   ; Load the current player X coordinate into A
    add c               ; Add the dX value from C to get the new X coordinate
    ld c, a             ; Store the new Y coordinate back in C

    ; Check if there is NPC
    call CheckForNPC      ; Call a routine to get the tile ID at the B=y, C=x coordinates
    cp TRUE ; Compare the tile ID from TilemapData to the maximum walkable tile ID
    ret z              ; If the tile ID is greater than the maximum walkable tile ID, return

    ; Check if the attempted move is valid
    call GetTileID      ; Call a routine to get the tile ID at the B=y, C=x coordinates
    cp MAX_WALKABLE_TILE_ID ; Compare the tile ID from TilemapData to the maximum walkable tile ID
    ret nc              ; If the tile ID is greater than the maximum walkable tile ID, return

.startMoving
    ; Set up movement direction and attempt to move here as before
    ; After a successful move, set movementState to MOVEMENT_MOVING
    ; Example:

    ld a, MOVEMENT_MOVING
    ld [movementState], a
    

    ; Store the new coordinates
    ld a, b             ; Load the new Y coordinate into A
    ld [wPlayer.y], a   ; Store the new Y coordinate in memory
    ld a, c             ; Load the new X coordinate into A
    ld [wPlayer.x], a   ; Store the new X coordinate in memory

    CALL UpdateNpcPosition

    ret


MoveCamera:
    ld hl, camMoveProgress

    ld a, [wPlayer.x]   ; Load current X position of player
    add 23              ; Camera offset
    add a               ; To convert the Y grid coordinate into screen coordinates we have to multiply
    add a               ;  by 8, which can be done quickly by adding A to itself 3 times
    add a               ;  ...
    ld b, a

    ld a, [wPlayer.facing]
    cp FACE_RIGHT
    jr z, .moveRight
    cp FACE_LEFT
    jr z, .moveLeft

    jr .vertical

.moveLeft
    ld a, b
    add 8
    sbc [hl]
    jr .setCamX

.moveRight
    ld a, b
    sub 8
    add [hl]

.setCamX
    ld [rSCX], a        ; Store the converted result in SCX
    jp .done

.vertical
    ld a, [wPlayer.y]   ; Load current Y position of player
    sub 40              ; Camera offset
    add a               ; Convert Y grid coordinate into screen coordinates
    add a               ; Multiply by 8 (add A to itself 3 times)
    add a               ; ...
    ld b, a

    ld a, [wPlayer.facing]
    cp FACE_DOWN
    jr z, .moveDown

; If not horizontal and not down then it's automatically up
.moveUp
    ld a, b
    add 8
    sbc [hl]
    jr .setCamY

.moveDown
    ld a, b
    sub 8
    add [hl]

.setCamY
    ld [rSCY], a        ; Store the converted result in SCX

.done
    ret

