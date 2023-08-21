;============================================================================================================================
; Print Name
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

;============================================================================================================================
; Set up variables for printing
;============================================================================================================================
PrintText:
    ld de, _WarayaIntro

    ld a, 0
    ld [printProgress+0], a
    ld [printProgress+1], a

    ld [currentChar+0], a
    ld [currentChar+1], a

    ld [lineIndex], a


    ld a, PRINT_PRINTING
    ld [printStatus], a

    ld a, FALSE
    ld [isArrowWaitVisible], a

.skip
    ret

;============================================================================================================================
; Process the actual printing of text with Typrewriter style animation
;============================================================================================================================
ProcessPrint:
    ld de, _WarayaIntro

    ; Use appropriate _SCRN1+i where i is an offset to place the line of string in its position in the dialogue box
    call SelectLine

    ; Place print progress into BC to be added to screen adress
    ld a, [printProgress]
    ld c, a
    ld a, 0
    ld b, a

    ; Add print progress to window tile address
    add hl, bc

    ; Load print progress to be so it can be added directly to e which contains the address of the text to be printed
    ld a, [currentChar]
    ld b, a

    ld a, e
    add a, b
    ld e, a
    
    ; Print text
    ld a, [de]
    ld [hl], a
    inc de

    ; Load the current char in the string
    ld a, [de]

    ; Break new line if BR is found, else check for 1 to end the dialogue
    cp BR
    jr nz, .checkCNT

    ; Break new line
    ld a, [lineIndex]
    inc a
    ld [lineIndex], a

    jr .skip

.checkCNT
    ; Check for END
    cp CNT
    jr nz, .checkEND

    ld a, PRINT_WAITING
    ld [printStatus], a

    call WaitForPlayer

    jr .end

.checkEND
    ; Check for END
    cp END
    jr nz, .skip

    ; Finished
    ld a, PRINT_IDLE
    ld [printStatus], a

.skip
    call NextChar

.end
    ret

;============================================================================================================================
; This is to progress through printing
;============================================================================================================================

NextChar:
    ld a, [printProgress]
    inc a
    ld [printProgress], a

    ld a, [currentChar]
    inc a
    ld [currentChar], a
ret

;============================================================================================================================
; Select which line in the dialogue box
;============================================================================================================================

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

;============================================================================================================================
; Show an arrow to suggest to the player that there are more texts.
;============================================================================================================================

WaitForPlayer:
    push de
    push hl

    ld hl, _SCRN1+146

    ld a, [isArrowWaitVisible]
    cp TRUE
    jr nz, .showArrowWait

; Hide the arrow wait indicator
    ld a, BOT
    ld [hl], a

    ld a, FALSE
    ld [isArrowWaitVisible], a

    jr .end

.showArrowWait   

    ld a, ARROW_WAIT
    ld [hl], a

    ld a, TRUE
    ld [isArrowWaitVisible], a

.end
    pop hl
    pop de
ret