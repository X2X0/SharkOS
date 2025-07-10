[BITS 16]
[ORG 0x7C00]

; Include all necessary components
%include "animation.asm"
%include "print.asm"
%include "kernel_loader.asm"

boot_start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen
    mov ax, 0x0003
    int 0x10

    ; Show SHARK animation
    call shark_animation

    ; Display boot message
    mov si, boot_msg
    call print_string

    ; Load stage 2 from disk
    call load_stage2

    ; Jump to stage 2
    jmp 0x1000:0x0000

boot_msg: db 13,10, 'Booting SharkOS...', 13,10, 0

; Fill to 512 bytes with boot signature
times 510-($-$$) db 0
dw 0xAA55
