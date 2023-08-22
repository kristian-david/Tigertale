SECTION "Dialogue Variables", WRAM0
isDialogueEnabled:  ds 1

currentChar:        ds 2
printProgress:      ds 2
lineIndex:          ds 1

printStatus:        ds 1
isArrowWaitVisible: ds 1

SECTION "Dialogue System", ROM0

_PlayerName::
    db "You", 0
.end

rsreset
def PRINT_IDLE      rb 1            ; Not Printing
def PRINT_PRINTING  rb 1            ; Printing
def PRINT_WAITING   rb 1            ; Wait for player before printing next set of lines

rsreset
def BR          rb 1            ; Break line
def CNT         rb 1            ; Continue
def NXT         rb 1            ; Next character to talk
def CHC         rb 1            ; Choice
def END         rb 1            ; End

rsreset
def CHOICE_YES      rb 1        ; Yes / Agree / Positive
def CHOICE_NO       rb 1        ; No / Disagree / Negative
def CHOICE_RPT      rb 1        ; What? / Clarify / Repeat the dialogue
def CHOICE_MSC      rb 1        ; Miscellaneous / Sarcastic / Joke

def ARROW_WAIT  EQU $ED

; Entry point for the dialogue system

InitializeDialogueSystem:
    ld a, FALSE
    ld [isDialogueEnabled], a
ret

; Always called on game loop
DialogueSystem:

    ; Check if window layer is already moving
    ld a, [windowMoveDir]
    cp 0
    jr nz, .skip

    ; Continue with other logic if no button is pressed
.skip
    ret

EnableOrContinueDialogue:

    ld a, [isDialogueEnabled]
    cp FALSE
    jr nz, .tryContinueDialogue

    ld a, 1
    ld [windowMoveDir], a

    call EnableDialogue

.tryContinueDialogue
    ld a, [printStatus]
    cp PRINT_WAITING
    jr nz, .skip

    call ContinueDialogue

.skip
    ret

CancelDialogue:
    ld a, -1
    ld [windowMoveDir], a

    call DisableDialogue

    ret


;============================================================================================================================
; Handle the opening and closing of the Dialogue Window
;============================================================================================================================

CheckWindowMoveTimer:
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
    ld a, PRINT_IDLE
    ld [printStatus], a

    call SetDialogueFrame

.notOpening
    ld a, 0
    ld [windowMoveDir], a

.skip
    ret


EnableDialogue:
    ld a, FALSE
    ld [canMove], a


    ld a, TRUE
    ld [isDialogueEnabled], a

    ld de, _WarayaName
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

SECTION "Set Dialogue", ROM0

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

SetDialogueFrameTile:

    ld a, [de]
    ld [hli], a
    inc de
ret

;============================================================================================================================
; DialogueControls
;============================================================================================================================

SECTION "Dialogue Controls", ROM0

ContinueDialogue:
    ; Call 3 times since some tiles are not cleared entirely
    call ClearDialogueText
    call ClearDialogueText
    call ClearDialogueText

    call HideArrowWait

    call NextChar
    call NextChar

    ld a, PRINT_PRINTING
    ld [printStatus], a

    ld a, 0
    ld [lineIndex], a

    ; Reset Print Progress
    ld [printProgress+0], a         ; Store high byte in printProgress
    ld [printProgress+1], a         ; Store low byte in printProgress+1

ret

HideArrowWait:
    push de
    push hl
    
    ld hl, _SCRN1+146

    ld a, BOT
    ld [hl], a

    ld a, FALSE
    ld [isArrowWaitVisible], a

    pop hl
    pop de
ret