include "hardware.inc"

def IOBUF_SZ EQU $100

section "bss.io", wram0, align[8]

; ------------------------------------------------------------------------------
; Variable: stdin
;
; Buffer for serial input data.
; ------------------------------------------------------------------------------
stdin::
    ds {IOBUF_SZ}

; ------------------------------------------------------------------------------
; Variable: stdout
;
; Buffer for serial output data.
; ------------------------------------------------------------------------------
stdout::
    ds {IOBUF_SZ}


; ------------------------------------------------------------------------------
; Variable: {stdin,stdout}.{reader,writer}
;
; Offset pointers for reading and writing buffered I/O. Implements a ring
; buffer.
;
; NOTE:
;   These variables have been reordered to conserve space within the section (as
;   I/O buffers must have alignment of 8).
; ------------------------------------------------------------------------------
stdin.reader::
    ds 1
stdin.writer::
    ds 1
stdout.reader::
    ds 1
stdout.writer::
    ds 1


section fragment "std", romx

; ------------------------------------------------------------------------------
; Routine: stdin.get
;
; Gets the next character from stdin.
;
; Returns:
;   A: character byte
; ------------------------------------------------------------------------------
stdin.get::
    ; startup
    push hl
    ; make read pointer
    ld h, high(stdin)
    ld a, [stdin.reader]
    ld l, a
    ; read character
    ld a, [hl]
    ; increment reader
    ld hl, stdin.reader
    inc [hl]
    ; cleanup
    pop hl
    ret

; ------------------------------------------------------------------------------
; Routine: stdin.put
;
; Gets the next character from stdin.
;
; Parameters:
;   A: character byte
; ------------------------------------------------------------------------------
stdin.put::
    ; startup
    push de
    push hl
    ; save character
    ld d, a
    ; make write pointer
    ld h, high(stdin)
    ld a, [stdin.writer]
    ld l, a
    ; write character
    ld [hl], d
    ; update reader
    ld hl, stdin.writer
    inc [hl]
    ; cleanup
    pop hl
    pop de
    ret


; ------------------------------------------------------------------------------
; Routine: stdin.len
;
; Calculates the remaining space in stdin.
;
; Returns:
;   A: buffer length
; ------------------------------------------------------------------------------
stdin.len::
    ; startup
    push bc
    ; calculate length
    ld a, [stdin.reader]
    ld b, a
    ld a, [stdin.writer]
    sub a, b
    ; cleanup
    pop bc
    ret

; ------------------------------------------------------------------------------
; Routine: stdout.get
;
; Gets the next character from stdout.
;
; Returns:
;   A: character byte
; ------------------------------------------------------------------------------
stdout.get::
    ; startup
    push hl
    ; make read pointer
    ld h, high(stdout)
    ld a, [stdout.reader]
    ld l, a
    ; read character
    ld a, [hl]
    ; increment reader
    ld hl, stdout.reader
    inc [hl]
    ; cleanup
    pop hl
    ret

; ------------------------------------------------------------------------------
; Routine: stdout.put
;
; Gets the next character from stdout.
;
; Parameters:
;   A: character byte
; ------------------------------------------------------------------------------
stdout.put::
    ; startup
    push de
    push hl
    ; save character
    ld d, a
    ; make write pointer
    ld h, high(stdout)
    ld a, [stdout.writer]
    ld l, a
    ; write character
    ld [hl], d
    ; update reader
    ld hl, stdout.writer
    inc [hl]
    ; cleanup
    pop hl
    pop de
    ret


; ------------------------------------------------------------------------------
; Routine: stdout.len
;
; Calculates the remaining space in stdout.
;
; Returns:
;   A: buffer length
; ------------------------------------------------------------------------------
stdout.len::
    ; startup
    push bc
    ; calculate length
    ld a, [stdout.reader]
    ld b, a
    ld a, [stdout.writer]
    sub a, b
    ; cleanup
    pop bc
    ret
