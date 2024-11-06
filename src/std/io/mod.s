include "hardware.inc"

def IOBUF_SZ EQU $100

section fragment "std", romx
; ------------------------------------------------------------------------------
; Module: io
;
; I/O routines for drawing text to the display and serial communication.
; ------------------------------------------------------------------------------
io::

; ------------------------------------------------------------------------------
; Routine: io.draw
;
; Draws a string to the display. Automatically inserting newlines when
; necessary.
;
; Parameters:
;   HL: string pointer
; ------------------------------------------------------------------------------
.draw::
    ; startup
    push de
    ; get video buffer
    ld de, _SCRN0
:   ; exit condition
    ld a, [hl+]
    cp a, 0
    jp z, :+
    ; ignore unused ascii
    cp a, $7f
    jp nc, :-
    ; handle control chars
    sub a, $20
    jp c, :-
    ; write current character
    ld [de], a
    ; iterator next
    inc de
    jp :-
:   ; cleanup
    pop de
    ret

; ------------------------------------------------------------------------------
; Routine: io.recv
;
; Receives a string from the serial port.
;
; Implementation:
;   Fetch directly from stdin, checking buffer length as data is received from serial port during
;   the interrupt handler.
;
; Parameters:
;   HL: buffer pointer
; ------------------------------------------------------------------------------
.recv::
    ; startup
    push de
    ; check stdin has data
    call stdin.len
    cp a, 0
    jp z, :++
    ; make read pointer
    ld d, high(stdin)
    ld a, [stdin.reader]
    ld e, a
:   ; fetch next character
    ld a, [de]
    inc e
    ; copy character to buffer
    ld [hl+], a
    ; compare with write pointer
    ld a, [stdin.writer]
    sub a, e
    ; check buffer length
    jp nz, :-
    ; copy null-terminator
    ld [hl+], a
    ; update reader
    ld a, e
    ld [stdin.reader], a
:   ; cleanup
    pop de
    ret

; ------------------------------------------------------------------------------
; Routine: io.send
;
; Sends a string over the serial port.
;
; Implementation:
;   In order to begin the transfer as fast as possible, we fetch and send the
;   first character immediately, then copy the remaining bytes to stdout.
;
; Parameters:
;   HL: string pointer
; ------------------------------------------------------------------------------
.send::
    ; startup
    push de
    ; check serial not busy
    ld a, [rSC]
    bit SCB_START, a
    jp nz, :+
    ; fetch first character
    ld a, [hl+]
    cp a, 0
    jp z, :+++
    ; load serial data
    ld [rSB], a
    ; send serial data
    ld a, SCF_START | SCF_SOURCE
    ld [rSC], a
    ; make write pointer
    ld d, high(stdout)
    ld a, [stdout.writer]
    ld e, a
:   ; fetch next character
    ld a, [hl+]
    cp a, 0
    jp z, :+
    ; copy character to stdout
    ld [de], a
    inc e
    jp :-
:   ; update writer
    ld a, e
    ld [stdout.writer], a
:   ; cleanup
    pop de
    ret
