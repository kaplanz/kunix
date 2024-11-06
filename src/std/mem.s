def ALLOC_SZ equ $0800
def STACK_SZ equ $0800

section fragment "std", romx

; ------------------------------------------------------------------------------
; Module: mem
;
; Routines and structures for managing the stack and heap. This includes memory
; (de)allocation.
; ------------------------------------------------------------------------------
mem::

; ------------------------------------------------------------------------------
; Routine: mem.new
;
; Allocates the requested memory on the heap.
;
; Parameters:
;   HL: requested amount of memory
;
; Return:
;   HL: pointer to allocated memory
; ------------------------------------------------------------------------------
.new::
    ; startup
    push bc
    push de
    ; copy allocation length
    ld b, h
    ld c, l
    ; make alloc pointer
    ld hl, alloc
    ld a, [alloc.ptr]
    add a, l
    ld l, a
    ; allocate memory
    ld l, a
    ld h, a
    adc a, 0
    ; cleanup
    pop de
    pop bc
    ret

; ------------------------------------------------------------------------------
; Routine: mem.free
;
; Returns the provided memory allocation to the heap.
;
; Parameters:
;   HL: pointer to allocated memory
; ------------------------------------------------------------------------------
.free::
    ret


section "bss.mem", wramx, bank[1], align[8]

; ------------------------------------------------------------------------------
; Variable: alloc
;
; Buffer for dynamically allocated memory.
; ------------------------------------------------------------------------------
assert @ % $100 == 0
alloc::
    ds {ALLOC_SZ} - 1
.ptr
    ds 1

; ------------------------------------------------------------------------------
; Variable: stack
;
; Buffer for stack allocated memory.
; ------------------------------------------------------------------------------
assert @ % $100 == 0
stack::
.end::
    ds {STACK_SZ} - 1
.top::
    ds 1
