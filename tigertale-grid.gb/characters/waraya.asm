SECTION "Waraya NPC", WRAM0

wNPC:
.y              ds 1    ; NPC's Y coordinate (in grid space)
.x              ds 1    ; NPC's X coordinate (in grid space)
.facing         ds 1    ; NPC's facing direction (0=left, 1=right, 2=up, 3=down)
.offsetY        ds 1    ; Offset to when player moves
.offsetX        ds 1    ; Offset to when player moves
.defaultFacing  ds 1    ; Default facing direction
.end

_Waraya:
    .progress   ds 1
    .isHostile  ds 1
    .isAlive    ds 1
.end