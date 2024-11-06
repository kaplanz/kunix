include "hardware.inc"

section fragment "int", rom0
; ------------------------------------------------------------------------------
; Module: int
;
; Interrupt service routines (handlers).
; ------------------------------------------------------------------------------
int::

; ------------------------------------------------------------------------------
; Routine: int.serial
;
; Send bytes over the serial port until stdout is drained.
; ------------------------------------------------------------------------------
.serial::
    ; startup
    push af
    push bc
    push de
    push hl
    ; check if host or peer
    ld a, [rSC]
    bit SCB_SOURCE, a
    ; check stdout has data
    call stdout.len
    cp a, 0
    jp z, .done
    ; get char
    call stdout.get
    ; load serial data
    ld [rSB], a
    ; send serial data
    ld a, SCF_START | SCF_SOURCE
    ld [rSC], a
.done
    ; cleanup
    pop hl
    pop de
    pop bc
    pop af
    reti

.host
.peer
