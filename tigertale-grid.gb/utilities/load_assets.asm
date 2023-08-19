; load_assets.asm

; Load player sprite and background tiles to VRAM
SECTION "Load Player and NPC Tiles", ROM0

LoadSpriteTiles:
    ld hl, PlayerTileData
    ld de, _VRAM
    ld bc, PlayerTileData.end - PlayerTileData
    call MemCopy

    ld hl, NpcTileData
    ld de, _VRAM + $0C00                        ;0800 - ito original value ko
    ld bc, NpcTileData.end - NpcTileData
    call MemCopy

    ret

; Load font data to VRAM
SECTION "Load Font Data", ROM0

LoadFontTiles:
    ld hl, FontData
    ld de, _VRAM + $0800                        ;0C00
    ld bc, FontData.end - FontData
    call MemCopy

    ret

LoadDialogueFrameTile:
    ld hl, FrameData
    ld de, _VRAM + $0DF0                        ;0C00
    ld bc, FrameData.end - FrameData
    call MemCopy

    ret

; Load background tiles to VRAM
SECTION "Load Background Tiles", ROM0

LoadBackgroundTiles:
    ld hl, BackgroundTileData
    ld de, _VRAM + $1000
    ld bc, BackgroundTileData.end - BackgroundTileData
    call MemCopy

    ret