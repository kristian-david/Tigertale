
SetTileMap:
; Copy our 20x18 tilemap to VRAM
    ld de, TilemapData  ; Load the source address of our tilemap into DE
    ld hl, _SCRN0       ; Point HL to the first byte of the tilemap ($9800)
    ld b, SCRN_Y_B      ; Load the height of the screen in tiles into B (18 tiles)
.tilemapLoop
    ld c, SCRN_X_B      ; Load the width of the screen in tiles into C (20 tiles)
.rowLoop
    ld a, [de]          ; Load a byte from the address DE points to into the A register
    ld [hli], a         ; Load the byte in the A register to the address HL points to and increment HL
    inc de              ; Increment the source pointer in DE
    dec c               ; Decrement the loop counter in C (tiles per row)
    jr nz, .rowLoop     ; If C isn't zero, continue copying bytes for this row
    push de             ; Push the contents of the register pair DE to the stack
    ld de, SCRN_VX_B - SCRN_X_B ; Load the number of tiles remaining in the row into DE
    add hl, de          ; Add the remaining row length to HL, advancing the destination pointer to the next row
    pop de              ; Recover the former contents of the the register pair DE
    dec b               ; Decrement the loop counter in B (total rows)
    jr nz, .tilemapLoop ; If B isn't zero, continue copying rows
    ret