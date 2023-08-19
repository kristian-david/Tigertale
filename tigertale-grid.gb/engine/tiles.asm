;============================================================================================================================
; Tile/Tilemap Data
;============================================================================================================================

SECTION "Tile/Tilemap Data", ROMX

PlayerTileData:
    incbin "gfx/player.2bpp"
.end

NpcTileData:
    incbin "gfx/player.2bpp"  ; Replace with the actual NPC sprite data
.end

BackgroundTileData:
    incbin "gfx/grid-collision-bg-tiles.2bpp"  ; Include binary tile data inline using incbin
.end

TilemapData:
    incbin "gfx/grid-collision.tilemap"     ; Include tilemap built using Tilemap Studio and the grid-collision-bg-tiles tileset

SECTION "Font", ROM0
FontData:
        INCBIN "fonts/alphanum_gbstudio.2bpp"
.end

FrameData:
        INCBIN "fonts/dialogue_frame.2bpp"
.end