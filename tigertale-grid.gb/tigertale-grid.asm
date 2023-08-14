; Grid Collision Example for the Nintendo Game Boy
; by Dave VanEe 2022
; Tested with RGBDS 0.6.0
; License: CC0 (https://creativecommons.org/publicdomain/zero/1.0/)

; This example builds on the following examples:
;  - background-tilemap (except using a manually constructed tilemap)
;  - vblank/oamdma/sprite
;  - joypad

; The main additions in this example are moving a player in response to input (ProcessInput), and checking the tilemap
;  entries to determine if attempted moves are into valid spaces based on tile ID (GetTileID). Note that instead of using an
;  automatically generated tilemap as in the background-filemap example, the tilemap is pre-constructed with tiles organized
;  such that walkable tiles start at 0 and are sequential to simplify the collision check.

include "hardware.inc"  ; Include hardware definitions so we can use nice names for things
include "engine/constants.inc"  
include "engine/variables.asm" 
include "engine/movement.asm"
include "engine/player_oam.asm" 
include "engine/sprite_oam.asm"
include "engine/background_tilemap.asm"
include "engine/timer.asm"
include "utilities/clear_oam.asm"  
INCLUDE "math.asm"

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

    ; Copy our sprite and background tiles to VRAM
    ld hl, PlayerTileData ; Load the source address of our tiles into HL
    ld de, _VRAM        ; Load the destination address in VRAM into DE
    ld bc, PlayerTileData.end - PlayerTileData ; Load the number of bytes to copy into BC
    call MemCopy        ; Call our general-purpose memory copy routine

    ; Copy our sprite and background tiles to VRAM
    ld hl, NpcTileData ; Load the source address of our tiles into HL
    ld de, _VRAM        ; Load the destination address in VRAM into DE
    ld bc, NpcTileData.end - NpcTileData ; Load the number of bytes to copy into BC
    call MemCopy        ; Call our general-purpose memory copy routine

    ld hl, BackgroundTileData ; Load the source address of our tiles into HL
    ld de, _VRAM+$1000  ; Load the destination address in VRAM into DE
    ld bc, BackgroundTileData.end - BackgroundTileData ; Load the number of bytes to copy into BC
    call MemCopy        ; Call our general-purpose memory copy routine

    call SetTileMap

    ; Setup palettes and scrolling
    ld a, %11100100     ; Define a 4-shade palette from darkest (11) to lightest (00)
    ldh [rBGP], a       ; Set the background palette
    ld a, %11010000     ; Define a 4-shade palette which omits the 10 value to increase player contrast
    ldh [rOBP0], a      ; Set an object palette

    ; Set the scroll position of the camera
    ld a, -56             ; Load the desired X coordinate into A
    ldh [rSCX], a       ; Set the horizontal camera position (SCX) to the desired X coordinate
    ld a, -40             ; Load the desired Y coordinate into A
    ldh [rSCY], a       ; Set the vertical camera position (SCY) to the desired Y coordinate

    ldh [hCurrentKeys], a ; Zero our current keys just to be safe (A is already zero from earlier)

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

    ; Setup the direction and supposed positions of the player
    ld hl, wNPC      ; Point HL to the start of the player's state in WRAM
    ld a, 9             ; Load the starting Y coordinate into A
    ld [hli], a         ; Set the starting wNPC.y value in WRAM
    ld a, 3             ; Load the starting X coordinate into A
    ld [hli], a         ; Set the starting wNPC.x value in WRAM
    ld a, FACE_DOWN     ; Load the starting facing direction into A
    ld [hli], a         ; Set the starting wNPC.facing value in WRAM


    ; Setup the VBlank interrupt
    ld a, IEF_VBLANK    ; Load the flag to enable the VBlank interrupt into A
    ldh [rIE], a        ; Load the prepared flag into the interrupt enable register
    xor a               ; Set A to zero
    ldh [rIF], a        ; Clear any lingering flags from the interrupt flag register to avoid false interrupts
    ei                  ; enable interrupts!

    ; Combine flag constants defined in hardware.inc into a single value with logical ORs and load it into A
    ld a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_WINOFF
    ldh [rLCDC], a      ; Enable and configure the LCD to show the background and objects

;============================================================================================================================
; Initialize
;============================================================================================================================

    call PopulateShadowOAM          ; Initialize Sprite
    call RenderNpcSprite

;============================================================================================================================
; Main Loop
;============================================================================================================================

LoopForever:
    HALT                ; Halt the CPU, waiting until an interrupt fires (this will sync our loop with VBlank)

    CALL UpdateJoypad   ; Poll the joypad and store the state in HRAM
    CALL ProcessInput   ; Update the game state in response to user input
    ; call MoveCamera

    CALL LoopTimer

    JR LoopForever      ; Loop forever


;============================================================================================================================
; Main Routines (Functions)
;============================================================================================================================

SECTION "Main Routines", ROMX


; Return the tile ID in TilemapData at provided coordinates
; @param B: Y coordinate in tilemap
; @param C: X coordinate in tilemap
; @return A: Tile ID at coordinates given
GetTileID:
    push bc             ; Store the input coordinates on the stack
    ld hl, TilemapData  ; Load the start address of the TilemapData into HL
    ld a, 3             ; Load the Y coordinate into A
    or a                ; Check if the Y coordinate is zero
    jr z, .yZero        ; If zero, skip the Y seeking code
    ld de, SCRN_X_B     ; Load the number of tiles per row of TilemapData into DE
.yLoop
    add hl, de          ; Add the number of tiles per row to the pointer in HL
    dec b               ; Decrease the loop counter in B
    jr nz, .yLoop       ; Loop until we've offset to the correct row
.yZero

    ld a, c             ; Load the X coordinate into A

    ; Add the X coordinate offset to HL (this is a common way to add A to a 16-bit register)
    add l               ; Add the X coordinate to the low byte of the pointer in HL
    ld l, a             ; Store the new low byte of the pointer in L
    adc h               ; Add H plus the carry flag to the contents of A
    sub l               ; Subtract the contents of L from A
    ld h, a             ; Store the new high byte of the pointer in H

    ld a, [hl]          ; Read the value of TilemapData at the coordinates of interest into A
    pop bc              ; Recover the original input coordinates from the stack
    ret


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
; Joypad Handling
;============================================================================================================================

SECTION "Joypad Variables", HRAM
; Reserve space in HRAM to track the joypad state
hCurrentKeys:   ds 1    ; Current keys
hNewKeys:       ds 1    ; Newly pressed keys

SECTION "Joypad Routine", ROM0

; Update the newly pressed keys (hNewKeys) and the held keys (hCurrentKeys) in memory
; Note: This routine is written to be easier to understand, not to be optimized for speed or size
UpdateJoypad:
    ; Poll half the controller
    ld a, P1F_GET_BTN   ; Load a flag into A to select reading the buttons
    ldh [rP1], a        ; Write the flag to P1 to select which buttons to read
    ldh a, [rP1]        ; Perform a few dummy reads to allow the inputs to stabilize
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ; The final read of the register contains the key state we'll use
    or $f0              ; Set the upper 4 bits, and leave the action button states in the lower 4 bits
    ld b, a             ; Store the state of the action buttons in B

    ld a, P1F_GET_DPAD  ; Load a flag into A to select reading the dpad
    ldh [rP1], a        ; Write the flag to P1 to select which buttons to read
    call .knownRet      ; Call a known `ret` instruction to give the inputs to stabilize
    ldh a, [rP1]        ; Perform a few dummy reads to allow the inputs to stabilize
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ;  ...
    ldh a, [rP1]        ; The final read of the register contains the key state we'll use
    or $f0              ; Set the upper 4 bits, and leave the dpad state in the lower 4 bits

    swap a              ; Swap the high/low nibbles, putting the dpad state in the high nibble
    xor b               ; A now contains the pressed action buttons and dpad directions
    ld b, a             ; Move the key states to B

    ld a, P1F_GET_NONE  ; Load a flag into A to read nothing
    ldh [rP1], a        ; Write the flag to P1 to disable button reading

    ldh a, [hCurrentKeys] ; Load the previous button+dpad state from HRAM
    xor b               ; A now contains the keys that changed state
    and b               ; A now contains keys that were just pressed
    ldh [hNewKeys], a   ; Store the newly pressed keys in HRAM
    ld a, b             ; Move the current key state back to A
    ldh [hCurrentKeys], a ; Store the current key state in HRAM
.knownRet
    ret

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

;============================================================================================================================
; Tile/Tilemap Data
;============================================================================================================================

SECTION "Tile/Tilemap Data", ROMX

; Obj tiles based on "Micro Character Bases" by Kacper Woźniak (https://thkaspar.itch.io/micro-character-bases)
; Licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)
; Skeleton tiles adjusted to 3-shade, and additional facing directions created based on the original art
PlayerTileData:
    incbin "gfx/player.2bpp"
.end

; Define the NPC's sprite data
NpcTileData:
    incbin "gfx/player.2bpp"  ; Replace with the actual NPC sprite data
.end

; BG tiles based on "Dungeon Package" tileset by nyk-nck (https://nyknck.itch.io/dungeonpack)
; License for original assets not clearly specified, but not CC0. Attribution/link included here for completness.
BackgroundTileData:
    incbin "gfx/grid-collision-bg-tiles.2bpp"  ; Include binary tile data inline using incbin
.end                                    ; The .end label is used to let the assembler calculate the length of the data

TilemapData:
    incbin "gfx/grid-collision.tilemap"     ; Include tilemap built using Tilemap Studio and the grid-collision-bg-tiles tileset