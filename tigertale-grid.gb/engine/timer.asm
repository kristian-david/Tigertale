SECTION "Timer", ROM0

; This subroutine increments the timer counter and checks if a certain time has passed
LoopTimer:
    ; Check if Timer has if movementState is Moving to enable timer
    ld a, [movementState]
    cp MOVEMENT_MOVING
    jr nz, .skip

    ; Actual Timer
    ld a, [timerCounter]
    inc a
    ld [timerCounter], a

    ; call UpdateWalkCounter

.skip
    ret

CheckTimer:
    ; Check for animating sprites
    ld hl, animationFrameCounter
    ld a, [timerCounter]
    cp [hl]
    jr c, .notYetAnimating

    ; Update walk counter - increment then return to 0 after
    call UpdateStepCounter
    
    ;Add the Frame Counter so we can check the next frame where we will animate the sprite
    ld a, [animationFrameCounter]
    add ANIMATION_SPEED
    ld [animationFrameCounter], a
    

.notYetAnimating
    ; Check for resetting movement cooldown
    
    ld a, [timerCounter]
    cp MOVE_SPEED
    jr c, .notYetReached

    call ResetAnimationCount

.notYetReached
    ret

UpdateStepCounter:
    ld a, [stepCounter]     ; Load the current value of stepCounter
    inc a                    ; Increment the value
    cp 4                     ; Compare with 3
    jr nz, .notReached3      ; Jump if not equal to 3
    ld a, 0                  ; Reset to 0 if equal to 3
.notReached3
    ld [stepCounter], a      ; Store the updated value back
    ret

ResetAnimationCount:
    ld a, MOVEMENT_IDLE
    ld [movementState], a

    ld a, 0
    ld [timerCounter], a

    ld a, 0
    ld [stepCounter], a 

    ld a, [ANIMATION_SPEED]
    ld [animationFrameCounter], a

    ret

; ; Call this subroutine every VBlank to update the timer
; UpdateTimer:
;     ; call CheckTimer
;     ret