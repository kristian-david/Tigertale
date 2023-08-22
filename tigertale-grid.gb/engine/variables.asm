;============================================================================================================================
; Game State Variables
;============================================================================================================================

SECTION "Game State Variables", WRAM0

; we use 0 as the 'end of string' character
TextString::
    ds 32
.end::
    
canMove:    ds 1

movementState:   ds 1    ; Define a 1-byte variable to store the movement state
windowMoveDir:   ds 1    ; -1(Down) 0(Idle) 1(Up)

dialogueTilePointer:    ds 1    ; Use to point the tile in dialogueFrame for printing text


; Might not be used if napagana ko without this
; movementStartCount: ds 1

playerSpriteTile: ds 1

camMoveProgress: ds 1        ; from 0-7
animProgress: ds 1 ; 

moveDir: ds 2               ; Vector containing the possible direction of player

; This would hold the position and orientation values of the player
wPlayer:                ; To directly reference Y just use [wPlayer] since y is the starting byte itself
.y              ds 1    ; Player's Y coordinate (in grid space)
.x              ds 1    ; Player's X coordinate (in grid space)
.facing         ds 1    ; Player's facing direction (0=left, 1=right, 2=up, 3=down)

SECTION "Frame Counters", HRAM
hFrameCounter:
	db

gameTick:           ds 1  ; Define a variable to store the timer counter
dialogueAnimTick:   ds 1    ; Timer for printing text
printTextTick:      ds 1
moveCooldownTick:   ds 1
camMovementTick:    ds 1
animTick:           ds 1



SECTION "Initialize", ROM0

InitializeVariables:
    ; Initialize Movement Timer (initialized with 0)
    ld a, 0
    ld [camMovementTick], a
    ld [animTick], a
    ld [moveCooldownTick], a
    ld [dialogueAnimTick], a
    ld [printTextTick], a
    ; Initialize Sprite Tile (initialized with 0)
    ld a, 0
    ld [playerSpriteTile], a
    ; Initialize Camera Movement Progress
    xor a
    ld [camMoveProgress], a
 
    ; Initialize Movement State
    ld a, MOVEMENT_IDLE
    ld [movementState], a

    ld a, 0
    ld [windowMoveDir], a

    ld a, TRUE
    ld [canMove], a
    
    ld a, 1
    ld [wNPC.defaultFacing],a

    ret