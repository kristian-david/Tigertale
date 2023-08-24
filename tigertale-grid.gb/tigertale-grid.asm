; Tigertale, a homebrewed game for the Nintendo Game Boy
; by Kristian Paolo P. David 2023
; Tested with RGBDS 0.6.0
; License: CC0 (https://creativecommons.org/publicdomain/zero/1.0/)

; The main additions in this example are moving a player in response to input (ProcessInput), and checking the tilemap
;  entries to determine if attempted moves are into valid spaces based on tile ID (GetTileID). Note that instead of using an
;  automatically generated tilemap as in the background-filemap example, the tilemap is pre-constructed with tiles organized
;  such that walkable tiles start at 0 and are sequential to simplify the collision check.

include "hardware.inc"  ; Include hardware definitions so we can use nice names for things
include "characters/waraya.asm"
include "dialogue/charmap.asm"
include "dialogue/clear_text.asm"
include "dialogue/dialogue_system.asm"  
include "dialogue/initiate_npc_dialogue.asm"
include "dialogue/npc_dialogue_picker.asm"
include "dialogue/print_text.asm"
include "dialogue/string_functions.asm"
include "engine/constants.inc"  
include "engine/variables.asm" 
include "engine/movement.asm"
include "engine/movement_check.asm"
include "engine/player_oam.asm" 
include "engine/sprite_oam.asm"
include "engine/background_set.asm"
include "engine/tiles.asm"
include "engine/process_input.asm"
include "utilities/clear_oam.asm"  
include "utilities/initialize_values.asm"
include "utilities/joypad.asm"
include "utilities/load_assets.asm"  
include "timer/vblank_timer.asm"
include "math.asm"

; Declare Constants
; Declare Variables


;============================================================================================================================
; Interrupts
;============================================================================================================================

; The VBlank vector is where execution is passed when the VBlank interrupt fires
SECTION "VBlank Vector", ROM0[$40]
; We only have 8 bytes here, so push all the registers to the stack and jump to the rest of the handler
; Note: Since the VBlank handler used here only affects A and F, we don't have to push/pop BC, DE, and HL,
;  but it's done here for demonstration purposes.
VBlank:
    push af             ; Push AF to the stack
    ld a, HIGH(wShadowOAM) ; Load the high byte of our Shadow OAM buffer into A
    jp VBlankHandler    ; Jump to the rest of the handler

; The rest of the handler is contained in ROM0 to ensure it's always accessible without banking
SECTION "VBlank Handler", ROM0
VBlankHandler:
    call hOAMDMA        ; Call our OAM DMA routine (in HRAM), quickly copying from wShadowOAM to OAMRAM
    pop af              ; Pop AF off the stack
    reti                ; Return and enable interrupts (ret + ei)

;============================================================================================================================
; Initialization
;============================================================================================================================

; Define a section that starts at the point the bootrom execution ends
SECTION "Start", ROM0[$0100]
    jp EntryPoint       ; Jump past the header space to our actual code

    ds $150-@, 0        ; Allocate space for RGBFIX to insert our ROM header by allocating
                        ;  the number of bytes from our current location (@) to the end of the
                        ;  header ($150)

EntryPoint:
    di                  ; Disable interrupts as we won't be using them
    ld sp, $e000        ; Set the stack pointer to the end of WRAM

    ; Turn off the LCD when it's safe to do so (during VBlank)
.waitVBlank
    ldh a, [rLY]        ; Read the LY register to check the current scanline
    cp SCRN_Y           ; Compare the current scanline to the first scanline of VBlank
    jr c, .waitVBlank   ; Loop as long as the carry flag is set
    xor a               ; Once we exit the loop we're safely in VBlank
    ldh [rLCDC], a      ; Disable the LCD (must be done during VBlank to protect the LCD)

    ; Copy the OAMDMA routine to HRAM, since during DMA we're limited on which
    ;  memory the CPU can access (but HRAM is safe)
    ld hl, OAMDMA       ; Load the source address of our routine into HL
    ld b, OAMDMA.end - OAMDMA ; Load the length of the OAMDMA routine into B
    ld c, LOW(hOAMDMA)  ; Load the low byte of the destination into C
.oamdmaCopyLoop
    ld a, [hli]         ; Load a byte from the address HL points to into the register A, increment HL
    ldh [c], a          ; Load the byte in the A register to the address in HRAM with the low byte stored in C
    inc c               ; Increment the low byte of the HRAM pointer in C
    dec b               ; Decrement the loop counter in B
    jr nz, .oamdmaCopyLoop ; If B isn't zero, continue looping

    call LoadSpriteTiles
    call LoadFontTiles
    call LoadDialogueFrameTile
    call LoadBackgroundTiles
    
    ; Set background and window
    call SetTileMap
    call SetDialogueFrame

    call InitializeValues

    call InitializeVariables


    ;When the GAMEBOY™ is powered on, OAM is filled with semi-random values so remove that
    call ClearOAM

    ; Setup the direction and supposed positions of the player
    ld hl, wPlayer      ; Point HL to the start of the player's state in WRAM
    ld a, 3             ; Load the starting Y coordinate into A
    ld [hli], a         ; Set the starting wPlayer.y value in WRAM
    ld a, 2             ; Load the starting X coordinate into A
    ld [hli], a         ; Set the starting wPlayer.x value in WRAM
    ld a, FACE_DOWN     ; Load the starting facing direction into A
    ld [hli], a         ; Set the starting wPlayer.facing value in WRAM

    ; Setup the direction and supposed positions of the npc
    ld hl, wNPC      ; Point HL to the start of the player's state in WRAM
    ld a, 5             ; 9 Load the starting Y coordinate into A
    ld [hli], a         ; Set the starting wNPC.y value in WRAM
    ld a, 2             ; 3 Load the starting X coordinate into A
    ld [hli], a         ; Set the starting wNPC.x value in WRAM
    ld a, FACE_DOWN     ; Load the starting facing direction into A
    ld [hli], a         ; Set the starting wNPC.facing value in WRAM
    ;OFFSET
    ld a, 5             ; 9 Load the starting Y coordinate into A
    ld [hli], a         ; Set the starting wNPC.y value in WRAM
    ld a, 2             ; 3 Load the starting X coordinate into A
    ld [hli], a         ; Set the starting wNPC.x value in WRAM


    ; Setup the VBlank interrupt
    ld a, IEF_VBLANK    ; Load the flag to enable the VBlank interrupt into A
    ldh [rIE], a        ; Load the prepared flag into the interrupt enable register
    xor a               ; Set A to zero
    ldh [rIF], a        ; Clear any lingering flags from the interrupt flag register to avoid false interrupts
    ei                  ; enable interrupts!

    ; Combine flag constants defined in hardware.inc into a single value with logical ORs and load it into A
    ld a, LCDCF_ON | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a      ; Enable and configure the LCD to show the background and objects

;============================================================================================================================
; Initialize
;============================================================================================================================

    call PopulateShadowOAM          ; Initialize Sprite
    call RenderNpcSprite

    call InitializeDialogueSystem

    

;============================================================================================================================
; Main Loop
;============================================================================================================================

LoopForever:
    HALT                ; Halt the CPU, waiting until an interrupt fires (this will sync our loop with VBlank)

    CALL UpdateJoypad   ; Poll the joypad and store the state in HRAM
    CALL ProcessInput   ; Update the game state in response to user input
    CALL DialogueSystem

    CALL GameTickTimer

    call ChangeText

    ; Make sure to use `ldh` for HRAM and registers, and not a regular `ld`
	ldh a, [hFrameCounter]
	inc a
	ldh [hFrameCounter], a

    ; cp a, 15 ; Every 15 frames (a quarter of a second), run the following code
    ; jp nz, Main
    


    JR LoopForever      ; Loop forever


;============================================================================================================================
; Main Routines (Functions)
;============================================================================================================================

SECTION "Main Routines", ROMX


;============================================================================================================================
; Utility Routines
;============================================================================================================================

SECTION "MemCopy Routine", ROM0
; Since we're copying data few times, we'll define a reusable memory copy routine
; Copy BC bytes of data from HL to DE
; @param HL: Source address to copy from
; @param DE: Destination address to copy to
; @param BC: Number of bytes to copy
MemCopy:
    ld a, [hli]         ; Load a byte from the address HL points to into the register A, increment HL
    ld [de], a          ; Load the byte in the A register to the address DE points to
    inc de              ; Increment the destination pointer in DE
    dec bc              ; Decrement the loop counter in BC
    ld a, b             ; Load the value in B into A
    or c                ; Logical OR the value in A (from B) with C
    jr nz, MemCopy      ; If B and C are both zero, OR B will be zero, otherwise keep looping
    ret                 ; Return back to where the routine was called from



;============================================================================================================================
; OAM Handling
;============================================================================================================================

SECTION "Shadow OAM", WRAM0, ALIGN[8]
; Reserve page-aligned space for a Shadow OAM buffer, to which we can safely write OAM data at any time, 
;  and then use our OAM DMA routine to copy it quickly to OAMRAM when desired. OAM DMA can only operate
;  on a block of data that starts at a page boundary, which is why we use ALIGN[8].
wShadowOAM:
    ds OAM_COUNT * 4
.end

SECTION "OAM DMA Routine", ROMX
; Initiate OAM DMA and then wait until the operation is complete, then return
; @param A High byte of the source data to DMA to OAM
OAMDMA:
    ldh [rDMA], a
    ld a, OAM_COUNT
.waitLoop
    dec a
    jr nz, .waitLoop
    ret
.end

SECTION "OAM DMA", HRAM
; Reserve space in HRAM for the OAMDMA routine, equal in length to the routine
hOAMDMA:
    ds OAMDMA.end - OAMDMA


