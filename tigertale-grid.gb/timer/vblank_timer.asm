SECTION "Timer", ROM0

GameTickTimer:

    CALL DialogueMoveTimer

    ; Call the following functions if the player is moving
    ld a, [movementState]   ; Load movement state
    cp MOVEMENT_MOVING      ; Compare with MOVEMENT_MOVING
    jr nz, .skip            ; Jump if not equal (skip timer update)

    call CamMovementTimer
    call AnimationTimer
    call MoveCooldownTimer

.skip

ret

;============================================================================================================================
; Dialogue Timer for movement
;============================================================================================================================

DialogueMoveTimer:

    ld a, [windowMoveDir]   ; Load movement state
    cp 0      ; Compare with Idle
    jr z, .skip            ; Jump if equal to 0 (Idle)

    ld a, [dialogueAnimTick]    ; Load timer counter
    inc a                   ; Increment timer
    ld [dialogueAnimTick], a    ; Store updated timer counter

    CALL CheckWindowMovTimer

.skip
    ret

;============================================================================================================================
; Movement Timers that rely on Vblank
;============================================================================================================================

CamMovementTimer:
    ld a, [camMovementTick]    ; Load timer counter
    inc a                   ; Increment timer
    ld [camMovementTick], a    ; Store updated timer counter

    cp CAM_SPEED                  ; Compare with MOVE_SPEED
    jr c, .skip           ; Jump if timer < MOVE_SPEED

    ; Reset camMovementTick
    ld a, 0
    ld [camMovementTick], a

    CALL UpdateCamProgress

    call PopulateShadowOAM ; Update the sprite locations for the next frame
    call MoveCamera
    call RenderNpcSprite
.skip
ret

AnimationTimer:
    ld a, [animTick]    ; Load timer counter
    inc a                   ; Increment timer
    ld [animTick], a    ; Store updated timer counter

    cp ANIM_SPEED                  ; Compare with MOVE_SPEED
    jr c, .skip           ; Jump if timer < MOVE_SPEED

    ; Reset camMovementTick
    ld a, 0
    ld [animTick], a

    call UpdateStepCounter         ; Call subroutine to update step counter
.skip
ret


MoveCooldownTimer:
    ld a, [moveCooldownTick]    ; Load timer counter
    inc a                   ; Increment timer
    ld [moveCooldownTick], a    ; Store updated timer counter

    ld a, [moveCooldownTick]           ; Load timer counter
    cp MOVE_SPEED                  ; Compare with MOVE_SPEED
    jr c, .skip           ; Jump if timer < MOVE_SPEED

    ; Reset everything
    ld a, MOVEMENT_IDLE
    ld [movementState], a

    ld a, 0
    ld [moveCooldownTick], a
    ld [camMoveProgress], a
    ld [animProgress], a 
    
.skip
    ret

    
;============================================================================================================================
; Other Functions
;============================================================================================================================

; Updates the step counter
UpdateCamProgress:
    ld a, [camMoveProgress]      ; Load the current value of stepCounter
    inc a                           ; Increment the value
    cp 8                            ; Compare with 8
    jr z, .reached7                 ; Jump if reached 7 since 0 indexing
    ld [camMoveProgress], a      ; Store the updated value back
.reached7
    ret

; Updates the step counter
UpdateStepCounter:
    ld a, [animProgress]     ; Load the current value of animProgress
    inc a                    ; Increment the value
    cp 4                     ; Compare with 4
    jr nz, .notReached4      ; Jump if not equal to 4
    xor a                  ; Reset to 0 if equal to 4
.notReached4
    ld [animProgress], a      ; Store the updated value back

    ret