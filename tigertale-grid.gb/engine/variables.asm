;============================================================================================================================
; Game State Variables
;============================================================================================================================

SECTION "Game State Variables", WRAM0

movementState:   ds 1    ; Define a 1-byte variable to store the movement state
timerCounter:   ds 1  ; Define a variable to store the timer counter

; Might not be used if napagana ko without this
; movementStartCount: ds 1

playerSpriteTile: ds 1

movementFrameCounter: ds 1      ; used for keeping track of the time to allow movement again
animationFrameCounter: ds 1     ; used for keeping track of the time to update the walk counter
stepCounter: ds 1 ; 

previousDir: ds 1

; This would hold the position and orientation values of the player
wPlayer:
.y              ds 1    ; Player's Y coordinate (in grid space)
.x              ds 1    ; Player's X coordinate (in grid space)
.facing         ds 1    ; Player's facing direction (0=left, 1=right, 2=up, 3=down)

SECTION "Counter", WRAM0
wFrameCounter: db