include "hardware.inc"

section "head", rom0[$100]
    nop
    jp main
    ; reserve space for header
    ds $150 - @, 0

section "main", romx
main::
    ; stack init
    ld sp, stack.top
    ; enable interrupts
    ld a, IEF_SERIAL
    ld [rIE], a
    ; disable audio
    ld a, 0
    ld [rNR52], a
    ; load font
    ld de, font.len
    ld hl, font.ptr
    call gfx.load
    ; draw to display
    ld hl, str
    call io.draw
    ; display init
    ld a, LCDCF_ON | LCDCF_BLK01 | LCDCF_BGON
    ld [rLCDC], a
    ; palette init
    ld a, %11100100
    ld [rBGP], a
    ; send to serial
    ld hl, str
    call io.send
    ; recv from serial
    ld hl, out
    call io.recv
    ; spin forever
:   jp :-

section "data", romx
str:
    db "Hello, world!", 0

section "vars", wramx[$d000]
out:
    ds $100
