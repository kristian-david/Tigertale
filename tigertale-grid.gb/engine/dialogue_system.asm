SECTION "Dialogue Variables", WRAM0
printProgress:  ds 2
lineIndex:   ds 1

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
    ld a, [windowMoveDir]
    cp 1
    jr nz, .notClosing

    call PrintText
    jr .notOpening

.notClosing
    ld a, FALSE
    ld [isPrinting], a

    call SetDialogueFrame

.notOpening
    ld a, 0
    ld [windowMoveDir], a

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

    call ClearDialogueName

    ret

;============================================================================================================================
; Enable/Disable Dialogue Frame
;============================================================================================================================

SetDialogueFrame:
    push bc
    push de
    push hl

    ld de, DialogueFrameTiles   ; Load the address of the dialogue frame tiles

    ; Load the address of the window tile map into HL
    ld hl, _SCRN1       ; Window layer

.setTile
    call SetDialogueFrameTile

    cp 1              ; Copy until find 0
    jr nz, .skip

    ;Next line
    ld bc, 11         ; Load the value 32 into BC
    add hl, bc        ; Add 32 to the value in HL

.skip
    cp 0
    jr nz, .setTile
    
    pop hl
    pop de
    pop bc
    ret

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

; CLEAR THE TEXT
ClearDialogueText:
    ld de, DialogueFrameTiles+20   ; Load the address of the dialogue frame tiles
    ld hl, _SCRN1+31       ; 31 is offset for next line but 20 would be added in the loop so start with 11
    ld b, 20

.setTile
    call SetDialogueFrameTile

    dec b
    ld a, b
    cp 0           ; Copy until find 0
    jr nz, .setTile
    

    ret

SetDialogueFrameTile:
    ld a, [de]
    ld [hli], a
    inc de
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
    ld a, [de]         ; Load the current character from source
    cp 0               ; Check if it's the end of the string (null terminator)
    jr z, .done        ; If it's the end, exit the loop

    ld [hli], a        ; Copy the character to the destination
    inc de             ; Move to the next character
    jr .copyString     ; Continue the loop

.done
    ret

;Called once when starting to print a text
PrintText:
    ld de, _WarayaIntro

    ld a, 0            ; Load high byte of hl into a
    ld [printProgress+0], a         ; Store high byte in printProgress
    ld [printProgress+1], a         ; Store low byte in printProgress+1

    ld [lineIndex], a


    ld a, TRUE
    ld [isPrinting], a

.skip
    ret

; Always called on game loop
ProcessPrint:
    ld de, _WarayaIntro

    ; Use appropriate _SCRN1+i where i is an offset to place the line of string in its position in the dialogue box
    call SelectLine

    ; Place print progress into BC
    ld a, [printProgress]
    ld c, a
    ld a, 0
    ld b, a

    ; Add print progress to window tile address
    add hl, bc

    ; Load print progress to be so it can be added directly to e which contains the address of the text to be printed
    ld a, [printProgress]
    ld b, a

    ld a, e
    add a, b
    ld e, a
    
    ; Print text
    ld a, [de]
    ld [hl], a
    inc de

    ; This is to progress through printing
    ld a, [printProgress]
    inc a
    ld [printProgress], a



    ; Load the current char in the string
    ld a, [de]

    ; Break new line if 0 is found, else check for 1 to end the dialogue
    cp 0
    jr z, .newLine

    jr .checkEnd

.newLine
    ld a, [lineIndex]
    inc a
    ld [lineIndex], a

    jr .skip

.checkEnd
    ; End if 1 is found
    cp 1
    jr nz, .skip

    ; Finished
    ld a, FALSE
    ld [isPrinting], a

.skip
    ret

SelectLine:
    ; Check if lineIndex is 0
    ld a, [lineIndex]
    cp 0
    jr nz, .notZero ; If not 0, check the next condition
    
    ld hl, _SCRN1+34 ; Set hl to _SCRN1 + 48 if lineIndex is 0
    jr .done

.notZero:
    ; Check if lineIndex is 1
    cp 1
    jr nz, .notOne ; If not 1, continue to the next part
    
    ld hl, _SCRN1+48 ; Set hl to _SCRN1 + 61 if lineIndex is 1

    inc de              ; Increment de to go to correct char at string being printed
    jr .done

.notOne:
    ; Line is Two if not One or Zero
    ld hl, _SCRN1+62 ; Set hl to _SCRN1 + 61 if lineIndex is 1

    inc de              ; Increment de 2x to go to correct char at string being printed
    inc de

.done
    ret
