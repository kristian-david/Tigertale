;============================================================================================================================
; Check the player tries and can initiate a dialogue
;
; TryDialogueA and TryDialogueB are called from the ProcessInput function respectively
;============================================================================================================================

SECTION "Initiate NPC Dialogue", ROM0

TryDialogueA:
    push bc
    push hl

    ld hl, moveDir        ; Load the address of the variable moveDirection into HL
    ld c, [hl]            ; Store the lower byte of BC (register C) into moveDirection
    inc hl                ; Increment HL to point to the next memory location
    ld b, [hl]            ; Store the upper byte of BC (register B) into the next memory location


    ; Calculate the destination coordinates by applying the deltas
    ld a, [wPlayer.y]   ; Load the current player Y coordinate into A
    add b               ; Add the dY value from B to get the new Y coordinate
    ld b, a             ; Store the new Y coordinate back in B
    ld a, [wPlayer.x]   ; Load the current player X coordinate into A
    add c               ; Add the dX value from C to get the new X coordinate
    ld c, a             ; Store the new Y coordinate back in C

    ; Check if facing any NPC
    call CheckForNPC      ; Call a routine to get the tile ID at the B=y, C=x coordinates
    cp TRUE ; Compare the tile ID from TilemapData to the maximum walkable tile ID
    jr nz, .skip               ; If the tile ID is greater than the maximum walkable tile ID, return

    Call PickNpcDialogue

    ;Change facing direction of NPC
    ld a, [wPlayer.facing]
    Call MakeNpcFacePlayer

.skip
    pop hl
    pop bc
    ret


TryDialogueB:
    call CancelDialogue

    ; Reset facing direction of NPC
    ld a, [wNPC.defaultFacing]
    call MakeNpcFacePlayer
ret

; Update facing direction of NPC
; @param A: Player facing direction
MakeNpcFacePlayer:
    cp FACE_UP
    jr z, .down

    cp FACE_DOWN
    jr z, .up

    cp FACE_LEFT
    jr z, .right

    ; Player is facing right so make NPC face left to player
    ld a, FACE_RIGHT
    ld [wNPC.facing], a

    jr .updateNpcDir

.right
    ld a, FACE_LEFT
    ld [wNPC.facing], a
    jr .updateNpcDir

.up
    ld a, FACE_UP
    ld [wNPC.facing], a
    jr .updateNpcDir

.down
    ld a, FACE_DOWN
    ld [wNPC.facing], a

.updateNpcDir
    Call UpdateNpcDirection
ret

ResetNpcFacingDirection:
ret