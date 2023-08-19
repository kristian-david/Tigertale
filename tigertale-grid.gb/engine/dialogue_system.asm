SECTION "Dialogue", ROM0

; Entry point for the dialogue system
DialogueSystem:

    ; Check if window layer is already moving
    ld a, [windowMoveDir]
    cp 0
    jr nz, .skip

    ldh a, [hCurrentKeys]  ; Load newly pressed keys byte into A

    ; Check if A button is pressed (bit 0)
    bit PADB_A, a
    jr nz, .aButtonPressed ; Jump to aButtonPressed if A button is pressed

    ; Check if B button is pressed (bit 4)
    bit PADB_B, a
    jr nz, .bButtonPressed ; Jump to bButtonPressed if B button is pressed

    ; Continue with other logic if no button is pressed
.skip
    ret

.aButtonPressed:
    ld a, 1
    ld [windowMoveDir], a

    call EnableDialogue

    ret

.bButtonPressed:
    ld a, -1
    ld [windowMoveDir], a

    call DisableDialogue

    ret


CheckWindowMovTimer:
    ld a, [windowMoveDir]   ; Load movement state
    cp 1      ; Compare with Idle
    jr z, .moveDown  

;moveUp
    ld a, [rWY]
    cp 137
    jr z, .setFinished

    inc a
    ld [rWY], a
    jr .skip

.moveDown
    ld a, [rWY]
    cp 104
    jr z, .setFinished

    dec a
    ld [rWY], a
    jr .skip

.setFinished
    ld a, 0
    ld [windowMoveDir], a


    call PrintText
    

.skip
    ret


EnableDialogue:
    ld a, FALSE
    ld [canMove], a

    call PrintName

    ret

DisableDialogue:
    ld a, TRUE
    ld [canMove], a

    ret

;============================================================================================================================
; Enable/Disable Dialogue Frame
;============================================================================================================================

SetDialogueFrame:

    ld de, DialogueFrameTiles   ; Load the address of the dialogue frame tiles

    ; Load the address of the window tile map into HL
    ld hl, _SCRN1       ; Window layer

.setTile
    ld a, [de]
    ld [hli], a
    inc de

    cp 1              ; Copy until find 0
    jr nz, .skip

    ld bc, 11         ; Load the value 32 into BC
    add hl, bc        ; Add 32 to the value in HL

.skip


    cp 0
    jr nz, .setTile

    ret

DialogueFrameTiles:
    db TOP_LEFT, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP, TOP_RIGHT, 1
    db LEFT, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, RIGHT, 1
    db LEFT, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, RIGHT, 1
    db LEFT, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, CNTR, RIGHT, 1
    db BOT_LEFT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT, BOT_RIGHT, 0

;============================================================================================================================
; Print Text
;============================================================================================================================

PrintName:

    ; Load the address of the converted string into DE
    ld de, _WarayaName

    ; Load the address of the window tile map into HL
    ld hl, _SCRN1       ; This is correct

    ; Set position of name in dialogue, add 32 for lower Y pos
    ld bc, 1
    add hl, bc

.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a               ; Copy until find 0
    jr nz, .copyString

    ret

;Called once when starting to print a text
PrintText:
    ; Check if already printing [SUBJECT FOR REMOVAL SINCE TESTING LANG TO]
    ld a, [isPrinting]   ; Load movement state=
    cp TRUE      ; Compare with Idle
    jr z, .skip            ; Jump if equal to 0 (Idle)

    ; Load the address of the converted string into DE
    ld de, _WarayaIntro

    ; Load the address of the window tile map into HL
    ld hl, _SCRN1       ; This is correct

    ; Set position of name in dialogue, add 32 for lower Y pos
    ld bc, 33
    add hl, bc

    ld a, TRUE
    ld [isPrinting], a

.skip
    ret

; Always called on game loop
PrintTimer:
    ld a, [isPrinting]   ; Load movement state=
    cp FALSE      ; Compare with Idle
    jr z, .skip            ; Jump if equal to 0 (Idle)

    ld a, [de]
    ld [hl], a
    inc hl
    inc de
    
    cp 1              ; Copy until find 0
    jr nz, .skip

    

    ;Finished
    ld a, FALSE
    ld [isPrinting], a

.skip
    ret
