;============================================================================================================================
; Game State Variables
;============================================================================================================================

SECTION "Game State Variables", WRAM0

; we use 0 as the 'end of string' character
TextString::
    ds 16
.end::
    


movementState:   ds 1    ; Define a 1-byte variable to store the movement state
gameTick:   ds 1  ; Define a variable to store the timer counter

; Might not be used if napagana ko without this
; movementStartCount: ds 1

playerSpriteTile: ds 1
npcSpriteTile: ds 1

camMoveProgress: ds 1        ; from 0-7
animProgress: ds 1 ; 

animFrameCounter: ds 1     ; used for keeping track of the time to update the walk counter
camFrameCounter: ds 1      ; used for keeping track of the time to allow movement again

moveDir: ds 2               ; Vector containing the possible direction of player

; This would hold the position and orientation values of the player
wPlayer:                ; To directly reference Y just use [wPlayer] since y is the starting byte itself
.y              ds 1    ; Player's Y coordinate (in grid space)
.x              ds 1    ; Player's X coordinate (in grid space)
.facing         ds 1    ; Player's facing direction (0=left, 1=right, 2=up, 3=down)

; This would hold the position and orientation values of the player
wNPC:
.y              ds 1    ; Player's Y coordinate (in grid space)
.x              ds 1    ; Player's X coordinate (in grid space)
.facing         ds 1    ; Player's facing direction (0=left, 1=right, 2=up, 3=down)
.offsetY        ds 1    ; Offset to when player moves
.offsetX        ds 1    ; Offset to when player moves

SECTION "Counter", WRAM0
wFrameCounter: db


SECTION "Initialize", ROM0

InitializeVariables:
    ; Initialize Movement Timer (initialized with 0)
    ld a, 0
    ld [movementTimer], a
    ; Initialize Sprite Tile (initialized with 0)
    ld a, 0
    ld [playerSpriteTile], a
    ; Initialize Sprite Tile (initialized with 0)
    ld a, 0
    ld [npcSpriteTile], a
    ; Initialize Camera Movement Progress
    xor a
    ld [camMoveProgress], a
    ; Initialize Camera Frame Counter Timer (initialized with CAMERA_SPEED)
    ld a, [CAM_SPEED]
    ld [camFrameCounter], a
    ; Initialize Animation Frame Counter Timer (initialized with ANIMATION_SPEED)
    ld a, [ANIM_SPEED]
    ld [animFrameCounter], a
    ; Initialize Movement State
    ld a, MOVEMENT_IDLE
    ld [movementState], a

    ret