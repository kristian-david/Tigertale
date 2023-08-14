SECTION "Clear OAM Routine", ROMX

ClearOAM:
    ld hl, wShadowOAM   ; Point HL to the start of shadow OAM
    ld b, wShadowOAM.end - wShadowOAM ; Load the size of shadow OAM into B (it's less than 256 so we can use a single byte)
.clearOAMLoop
    ld [hli], a         ; Zero this OAM byte
    dec b               ; Decrement the loop counter in B (bytes of OAM)
    jr nz, .clearOAMLoop ; If B isn't zero, continue zeroing bytes

    ; Perform OAM DMA once to ensure OAM doesn't contain garbage
    ld a, HIGH(wShadowOAM) ; Load the high byte of our Shadow OAM buffer into A
    call hOAMDMA         ; Call our OAM DMA routine (in HRAM), quickly copying from wShadowOAM to OAMRAM

    ret