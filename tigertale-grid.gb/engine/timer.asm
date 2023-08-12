SECTION "Timer", ROM0

; Increments the timer counter and checks if a certain time has passed
LoopTimer:
    ld a, [movementState]   ; Load movement state
    cp MOVEMENT_MOVING      ; Compare with MOVEMENT_MOVING
    jr nz, .skip            ; Jump if not equal (skip timer update)

    ld a, [timerCounter]    ; Load timer counter
    inc a                   ; Increment timer
    ld [timerCounter], a    ; Store updated timer counter

    CALL CheckTimer

.skip
    ret

; Checks timer to update animation and movement state
CheckTimer:
    ; CHECK FOR CAMERA 
    ld hl, camFrameCounter   ; Load animation frame counter
    ld a, [timerCounter]           ; Load timer counter
    cp [hl]                         ; Compare with animation frame counter
    jr c, .notYetCamera         ; Jump if timer < animation frame counter

    call UpdateCamProgress         ; Call subroutine to update step counter
    ld a, [camFrameCounter]  ; Load animation frame counter
    add CAMERA_SPEED             ; Add animation speed
    ld [camFrameCounter], a  ; Store updated animation frame counter

.notYetCamera

    ; CHECK FOR ANIMATION
    ld hl, animationFrameCounter   ; Load animation frame counter
    ld a, [timerCounter]           ; Load timer counter
    cp [hl]                         ; Compare with animation frame counter
    jr c, .notYetAnimating         ; Jump if timer < animation frame counter

    call UpdateStepCounter         ; Call subroutine to update step counter
    ld a, [animationFrameCounter]  ; Load animation frame counter
    add ANIMATION_SPEED             ; Add animation speed
    ld [animationFrameCounter], a  ; Store updated animation frame counter

    ; ANIMATE
    call PopulateShadowOAM ; Update the sprite locations for the next frame
    call MoveCamera

.notYetAnimating
    ; CHECK FOR MOVE COOLDOWN
    ld a, [timerCounter]           ; Load timer counter
    cp MOVE_SPEED                  ; Compare with MOVE_SPEED
    jr c, .notYetReached           ; Jump if timer < MOVE_SPEED

    call ResetAnimationCount       ; Call subroutine to reset animation count

.notYetReached
    ret

; Updates the step counter
UpdateCamProgress:
    ld a, [camMoveProgress]      ; Load the current value of stepCounter
    inc a                           ; Increment the value
    cp 8                            ; Compare with 8
    jr z, .reached7                 ; Jump if reached 7 since 0 indexing
    ld [camMoveProgress], a      ; Store the updated value back

.reached7:
    ret

; Updates the step counter
UpdateStepCounter:
    ld a, [stepCounter]     ; Load the current value of stepCounter
    inc a                    ; Increment the value
    cp 4                     ; Compare with 4
    jr nz, .notReached4      ; Jump if not equal to 4
    xor a                  ; Reset to 0 if equal to 4
.notReached4:
    ld [stepCounter], a      ; Store the updated value back

    ret

; Resets animation and movement counts
ResetAnimationCount:
    ld a, MOVEMENT_IDLE
    ld [movementState], a

    xor a, a                  ; Clear registers
    ld [timerCounter], a
    ld [stepCounter], a 
    ld [camMoveProgress], a

    ld a, [ANIMATION_SPEED]
    ld [animationFrameCounter], a

    ld a, [CAMERA_SPEED]
    ld [camFrameCounter], a

    ret

