SECTION "NPC Sprite", ROM0

; Set the attributes for the static sprite
RenderNpcSprite:
    ld hl, wShadowOAM + 32 ; Point HL at the entry in wShadowOAM reserved for the static sprite

    ld a, [camMoveProgress]
    ld d, a

    ; Set the Y coordinate
    ld a, [wNPC.offsetY]  ; Y = 40 (adjust this value as needed)
    add CAM_X_OFFSET 
    sub 4               ; Offset to synchronize world position with player
    add a               ; To convert the Y grid coordinate into screen coordinates we have to multiply
    add a               ;  by 8, which can be done quickly by adding A to itself 3 times
    add a               ;  ...
    add $10+OBJ_Y_OFFSET ; Add the sprite offset ($10), plus the centering offset

    ld b, a                 ; Place a unto b since a will be used for comparing

    ; Set the X coordinate to the left of the screen
    ld a, [wNPC.offsetX]   ; X = 8
    add CAM_X_OFFSET
    sub 2               ; Offset to synchronize world position with player
    add a               ; Multiply the X coordinate by 8 the same as we did for Y above
    add a               ;  ...
    add a               ;  ...
    add $08+OBJ_X_OFFSET ; Add the sprite offset ($08), plus the centering offset

    ld c, a

    call MoveSprite

    ld a, 0
    add a               ; The player tiles have been stored in VRAM such that the facing direction multiplied
    add a               ;  by 4 will yield the tile ID for the first sprite, so multiply by 4 using adds
    ld [hli], a         ; Store the sprite's tile ID in shadow OAM
    add 2               ; Add 2 to the tile ID for the second sprite
    ld d, a             ; Cache the tile ID in D for use by the second sprite
    xor a               ; Set A to zero
    ld [hli], a         ; Store the sprite's attributes in shadow OAM

    ; Second sprite - Left Side
    ld a, b              ; Load the prepared Y coordinate (0) from A to A
    ld [hli], a          ; Store the sprite's Y coordinate in shadow OAM
    ld a, c             ; Load the prepared X coordinate from C to A
    add 8               ; Make the 2nd sprite appear on right side
    ld [hli], a         ; Store the sprite's X coordinate in shadow OAM
    ld a, d             ; Load the prepared tile ID from D to A
    ld [hli], a         ; Store the sprite's tile ID in shadow OAM
    xor a               ; Set A to zero
    ld [hli], a         ; Store the sprite's attributes in shadow OAM

    ret

; NPC Position in World space 
UpdateNpcPosition:
    ; Save value of BC
    push bc
    
    ld hl, moveDir  ; Load the address of the variable moveDirection into HL
    ld c, [hl]            ; Load the lower byte of moveDirection into register C
    inc hl                ; Increment HL to point to the next memory location
    ld b, [hl]            ; Load the upper byte of moveDirection into register B


    ; Calculate the destination coordinates by applying the deltas
    ld a, [wNPC.offsetY]   ; Load the current player Y coordinate into A
    sub b               ; Add the dY value from B to get the new Y coordinate
    ld b, a             ; Store the new Y coordinate back in B
    ld a, [wNPC.offsetX]   ; Load the current player X coordinate into A
    sub c               ; Add the dX value from C to get the new X coordinate
    ld c, a             ; Store the new Y coordinate back in C

    ; Store the new coordinates
    ld a, b             ; Load the new Y coordinate into A
    ld [wNPC.offsetY], a   ; Store the new Y coordinate in memory
    ld a, c             ; Load the new X coordinate into A
    ld [wNPC.offsetX], a   ; Store the new X coordinate in memory

    ; Restore value of BC
    pop bc
    ret

; Move NPC along with the background when player moves
MoveSprite:
    ld a, [wPlayer.facing]
    cp FACE_UP
    jr z, .moveUp
    cp FACE_DOWN
    jr z, .moveDown
    jr .horizontal

.moveUp
    ld a, b
    add d
    sub 8
    jr .setPosY

.moveDown
    ld a, b
    sub d
    add 8

.setPosY
    dec a                       ; Help NPC stay in place when player switches moving vertically-horizontally
    ld b, a                     ; Save Y value to B

    jr .setPos
    ret

.horizontal
    ld a, [wPlayer.facing]
    cp FACE_RIGHT
    jr z, .moveRight

.moveLeft
    ld a, c
    add d
    sub 8
    jr .setPosX

.moveRight
    ld a, c
    sub d
    add 8

.setPosX
    ; inc a                       ; Help NPC stay in place when player switches moving vertically-horizontally
    ld c, a                     ; Save X value to C

.setPos:
    ld a, b
    ld [hli], a             ; Store Y coordinate in shadow OAM
    ld a, c
    ld [hli], a             ; Store X coordinate in shadow OAM
    ret