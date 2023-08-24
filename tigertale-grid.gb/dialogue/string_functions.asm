include "dialogue/charmap.asm"
include "text/WarayaIntro.asm"

SECTION "String Functions", ROM0

ChangeText:

    ld hl, TextString   ; Load the address of TextString into HL
    ld b, TextString.end - TextString; Calculate the buffer length

    ld de, _WarayaIntroText    ; Load the address of NewString into DE

.changeString
    ld a, [de]           ; Load the character from NewString into A
    ld [hli], a           ; Store the character in TextString
    inc de               ; Increment the source address
    dec b                ; Decrement the loop counter
    jr nz, .changeString ; If C isn't zero, continue filling the buffer

    ret

; PrintText:

;     ; Load the address of the converted string into DE
;     ld de, TextString

;     ; Load the address of the window tile map into HL
;     ld hl, _SCRN1       ; This is correct

;     ; Set position of name in dialogue, add 32 for lower Y pos
;     ld bc, 1
;     add hl, bc

; .copyString
;     ld a, [de]
;     ld [hli], a
;     inc de
;     and a               ; Copy until find 0
;     jr nz, .copyString

;     ret

SECTION "TextString", ROMX

NewString::
    db "DAISY MAE 129", 0
.end::
