SECTION "Player Animation", ROM0

; Player animation

; At the top of your code, define the variable



; Populate ShadowOAM with sprites based on the game state
PopulateShadowOAM:
    ld hl, wShadowOAM   ; Point HL at the beginning of wShadowOAM   

    ; First sprite - Right Side
    ld a, 72            ; Load the initial Y coordinate of the player
    add a               ; To convert the Y grid coordinate into screen coordinates we have to multiply
    add a               ;  by 8, which can be done quickly by adding A to itself 3 times
    add a               ;  ...
    add $10+OBJ_Y_OFFSET ; Add the sprite offset ($10), plus the centering offset
    ld [hli], a         ; Store the sprite's Y coordinate in shadow OAM
    ld b, a             ; Cache the Y coordinate in B for use by the second sprite
    ld a, 41            ; Load the initial X coordinate of the player
    add a               ; Multiply the X coordinate by 8 the same as we did for Y above
    add a               ;  ...
    add a               ;  ...
    add $08+OBJ_X_OFFSET ; Add the sprite offset ($08), plus the centering offset
    ld [hli], a         ; Store the sprite's X coordinate in shadow OAM
    add $08             ; Add 8 to the X coordinate for the second sprite
    ld c, a             ; Cache the X coordinate in C for use by the second sprite
    ld a, [wPlayer.facing] ; Load the player's facing direction into A

    ; Check if facing right
    cp FACE_RIGHT
    jr nz, .noFlip
    ld a, FACE_LEFT     ; Change sprite to FACE_LEFT since we will just flip this

.noFlip
    add a               ; The player tiles have been stored in VRAM such that the facing direction multiplied
    add a               ;  by 4 will yield the tile ID for the first sprite, so multiply by 4 using adds
    ld [hli], a         ; Store the sprite's tile ID in shadow OAM
    add 2               ; Add 2 to the tile ID for the second sprite
    ld d, a             ; Cache the tile ID in D for use by the second sprite
    xor a               ; Set A to zero
    ld [hli], a         ; Store the sprite's attributes in shadow OAM

    ; Second sprite - Left Side
    ld a, b             ; Load the prepared Y coordinate from B to A
    ld [hli], a         ; Store the sprite's Y coordinate in shadow OAM
    ld a, c             ; Load the prepared X coordinate from C to A
    ld [hli], a         ; Store the sprite's X coordinate in shadow OAM
    ld a, d             ; Load the prepared tile ID from D to A
    ld [hli], a         ; Store the sprite's tile ID in shadow OAM
    xor a               ; Set A to zero
    ld [hli], a         ; Store the sprite's attributes in shadow OAM

    xor a
    ld a, [wPlayer.facing] ; Load the player's facing direction into A
    cp FACE_LEFT           ; Compare it with the value for facing left
    jr nz, .flipRight  ; If not facing left, skip the flipping code
    jp .flipLeft ; Call the function to flip the first sprite horizontally

    ; Zero the remaning shadow OAM entries
    ; Note: Since we're only using 2/40 sprites, we could just loop 38 times, but the following approach will scale better if
    ;  additional sprites are added. This will also clear previously used entires in cases where the number of sprites used
    ;  each frame varies (which isn't the case here).
    ld b, a             ; Load zero (from the prior use) into B, since A will be used to check loop completion
.clearOAM
    ld [hl], b          ; Set the Y coordinate of this OAM entry to zero to hide it
    inc l               ; Advance 4 bytes to the next OAM entry
    inc l               ;  ...
    inc l               ;  ...
    inc l               ;  ...
    ld a, l             ; Load the low byte of the shadow OAM pointer into A
    cp LOW(wShadowOAM.end) ; Compare the low byte to the end of wShadowoAM
    jr nz, .clearOAM    ; Loop until we've hidden every unused sprite
    
    ret

.flipLeft
    ; 1st Sprite
    ld   a, %00000000           ; Clear the flip
    ld   [wShadowOAM + 3], a    ; flip the sprite horizontally

    ; 2nd Sprite

    ld   a, %00000000           ; Clear the flip
    ld   [wShadowOAM + 7], a    ; flip the sprite horizontally
    ret                 ; Return from the function

.flipRight
    ; 1st Sprite
    ld a, b                     ; b contains the x position
    sub OBJ_X_OFFSET            ; 1st sprite is in right side, subtracting the offset puts it to left
    add 8                       ; add 8 since the whole sprite gets shifted 1 tile left
    ld [wShadowOAM + 1], a      ; set new position of sprite

    ld   a,OAMF_XFLIP
    ld   [wShadowOAM + 3], a    ; flip the sprite horizontally

    ; 2nd Sprite
    ld a, b
    add OBJ_X_OFFSET            ; 2nd sprite is in left side, adding the offset puts it to right
    add 8                       ; add 8 since the whole sprite gets shifted 1 tile left
    ld [wShadowOAM + 5], a      ; set new position of sprite

    ld   a,OAMF_XFLIP
    ld   [wShadowOAM + 7], a    ; flip the sprite horizontally
    ret                 ; Return from the function

UpdateSprite:

