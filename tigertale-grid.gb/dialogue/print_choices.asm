;============================================================================================================================
; Print Choices
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