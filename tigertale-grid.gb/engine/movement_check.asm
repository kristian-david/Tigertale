SECTION "Movement Check Routines", ROMX


; Return a boolean that checks if there is an NPC at coordinates
; @param B: Y coordinate in tilemap
; @param C: X coordinate in tilemap
; @return A: Boolean indicating the occurrence of an NPC at the coordinates
CheckForNPC:
    push bc           ; Store the input coordinates on the stack

    ld a, [wNPC.y]   ; Load the Y coordinate of the NPC into A
    cp b             ; Compare it with the provided Y coordinate
    jr nz, .noCollision  ; If not equal, no collision

    ld a, [wNPC.x]   ; Load the X coordinate of the NPC into A
    cp c             ; Compare it with the provided X coordinate
    jr nz, .noCollision  ; If not equal, no collision

    ld a, TRUE       ; If both Y and X coordinates match, set A to TRUE (collision)
    pop bc            ; Recover the original input coordinates from the stack
    ret

.noCollision:
    ld a, FALSE      ; If coordinates don't match, set A to FALSE (no collision)
    pop bc            ; Recover the original input coordinates from the stack
    ret


; Return the tile ID in TilemapData at provided coordinates
; @param B: Y coordinate in tilemap
; @param C: X coordinate in tilemap
; @return A: Tile ID at coordinates given
GetTileID:
    push bc             ; Store the input coordinates on the stack
    ld hl, TilemapData  ; Load the start address of the TilemapData into HL
    ld a, 3             ; Load the Y coordinate into A
    or a                ; Check if the Y coordinate is zero
    jr z, .yZero        ; If zero, skip the Y seeking code
    ld de, SCRN_X_B     ; Load the number of tiles per row of TilemapData into DE
.yLoop
    add hl, de          ; Add the number of tiles per row to the pointer in HL
    dec b               ; Decrease the loop counter in B
    jr nz, .yLoop       ; Loop until we've offset to the correct row
.yZero

    ld a, c             ; Load the X coordinate into A

    ; Add the X coordinate offset to HL (this is a common way to add A to a 16-bit register)
    add l               ; Add the X coordinate to the low byte of the pointer in HL
    ld l, a             ; Store the new low byte of the pointer in L
    adc h               ; Add H plus the carry flag to the contents of A
    sub l               ; Subtract the contents of L from A
    ld h, a             ; Store the new high byte of the pointer in H

    ld a, [hl]          ; Read the value of TilemapData at the coordinates of interest into A
    pop bc              ; Recover the original input coordinates from the stack
    ret
