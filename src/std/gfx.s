include "hardware.inc"

section fragment "std", romx
; ------------------------------------------------------------------------------
; Module: gfx
;
; Routines for loading graphics for the display.
; ------------------------------------------------------------------------------
gfx::

; ------------------------------------------------------------------------------
; Routine: gfx.load
;
; Loads a tile data into VRAM, overwriting existing data (if any).
;
; Parameters:
;   DE: tile data length
;   HL: tile data pointer
; ------------------------------------------------------------------------------
.load::
    ; startup
    push bc
    ; get tile buffer
    ld bc, _VRAM
    ; copy each tile
:   ld a, [hl+]
    ld [bc], a
    ; move to next tile
    inc bc
    dec de
    ; exit condition
    ld a, d
    or a, e
    jr nz, :-
    ; cleanup
    pop bc
    ret
