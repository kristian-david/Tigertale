SECTION "Timer", ROM0

; This subroutine increments the timer counter and checks if a certain time has passed
; You can modify the timing condition here
LoopTimer:
    ; Check if Timer has started
    ld a, [hasStarted]
    cp 1
    jr nz, .skip

    ; Actual Timer
    ld a, [timerCounter]
    inc a
    ld [timerCounter], a
.skip
    ret

CheckTimer:
    ld a, [hasStarted]
    cp 1
    jr nz, .startTimer      ; If not equal to 1 then timer is still off

    ld a, [timerCounter]
    cp 15
    jr c, .notYetReached

    ; Timer is finished
    ld a, MOVEMENT_IDLE
    ld [movementState], a
    ; Reset the hasStarted
    ld a, 0
    ld [hasStarted], a

    ld a, 0
    ld [timerCounter], a

    ret

.startTimer
    xor a
    ld a, 1
    ld [hasStarted], a


.notYetReached
    ret

; ; Call this subroutine every VBlank to update the timer
; UpdateTimer:
;     ; call CheckTimer
;     ret