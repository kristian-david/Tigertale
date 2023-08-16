include "text/charmap.asm"

SECTION "String Functions", ROM0

ChangeText:
    ld a, 137
    ld [rWY], a
    ld a, 7
    ld [rWX], a

    ld hl, TextString   ; Load the address of TextString into HL
    ld b, TextString.end - TextString; Calculate the buffer length

    ld de, wPlayer    ; Load the address of NewString into DE

.changeString
    ld a, [de]           ; Load the character from NewString into A
    ld [hli], a           ; Store the character in TextString
    inc de               ; Increment the source address
    dec b                ; Decrement the loop counter
    jr nz, .changeString ; If C isn't zero, continue filling the buffer


    ; Load the address of the converted string into DE
    ld de, TextString

    call PrintText

    ret

PrintText:
    ; Load the address of the window tile map into HL
    ld hl, _SCRN1       ; This is correct

.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a               ; Copy until find 0
    jr nz, .copyString

    ret

SECTION "TextString", ROMX


NewString::
    db "DAISY TEST 152X", 0
.end::
