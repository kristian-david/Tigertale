SECTION "Clear Dialogue Name", ROM0
; CLEAR THE NAME
ClearDialogueName:
    ld de, DialogueFrameTiles   ; Load the address of the dialogue frame tiles
    ld hl, _SCRN1
    ld b, 20

.setTile
    call SetDialogueFrameTile

    dec b
    ld a, b
    cp 0              ; Copy until find 0
    jr nz, .setTile

ret

SECTION "Clear Dialogue Text", ROM0
; CLEAR THE TEXT
ClearDialogueText:
    push de
    push hl

    ld de, DialogueFrameTiles+20   ; Load the address of the dialogue frame tiles
    ld hl, _SCRN1+31       ; 31 is offset for next line but 20 would be added in the loop so start with 11
    ld b, 20

.setTile
    call SetDialogueFrameTile
    dec b
    ld a, b
    cp 0           ; Copy until find 0
    jr nz, .setTile

; HARDCODED remove line 2
    ld de, DialogueFrameTiles+20   ; Load the address of the dialogue frame tiles
    ld hl, _SCRN1+63       ; 31 is offset for next line but 20 would be added in the loop so start with 11
    ld b, 20

.setTile2
    call SetDialogueFrameTile
    dec b
    ld a, b
    cp 0           ; Copy until find 0
    jr nz, .setTile2

; HARDCODED remove line 3
    ld de, DialogueFrameTiles+20   ; Load the address of the dialogue frame tiles
    ld hl, _SCRN1+95       ; 31 is offset for next line but 20 would be added in the loop so start with 11
    ld b, 21

.setTile3
    call SetDialogueFrameTile
    dec b
    ld a, b
    cp 0           ; Copy until find 0
    jr nz, .setTile3
    
    pop hl
    pop de

    ret