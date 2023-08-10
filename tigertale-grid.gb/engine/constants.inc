;============================================================================================================================
; Game Constants
;============================================================================================================================

;Boolean
FALSE EQU 0
TRUE EQU 1

def MAX_WALKABLE_TILE_ID equ 8  ; All tiles from 0 to this tile ID will be considered walkable for the purposes of collision

def OBJ_Y_OFFSET equ -9         ; Since we're using two objects to draw the player larger than 8x8, but we're still moving
def OBJ_X_OFFSET equ -4         ;  on an 8x8 grid, we offset things slightly to center the player on the current tile

;Facing Directions
rsreset                         ; Reset the _RS counter to 0 for a new set of defines
def FACE_LEFT   EQU 2            ; Define FACE_LEFT as 2
def FACE_RIGHT  EQU 3            ; Define FACE_RIGHT as 2
def FACE_UP     EQU 1            ; Define FACE_UP as 1
def FACE_DOWN   EQU 0            ; Define FACE_DOWN as 0

;Movement States
MOVEMENT_IDLE EQU 0
MOVEMENT_MOVING EQU 1

MOVE_SPEED EQU 60               ; Either 15 or 30
ANIMATION_SPEED EQU 15          ; MOVE_SPEED /3