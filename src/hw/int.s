section "int.40h", rom0[$40]
    ; handle vblank
    reti

section "int.48h", rom0[$48]
    ; handle stat
    reti

section "int.50h", rom0[$50]
    ; handle timer
    reti

section "int.58h", rom0[$58]
    ; handle serial
    jp int.serial

section "int.60h", rom0[$60]
    ; handle joypad
    reti
