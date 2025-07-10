[BITS 16]
[ORG 0x7C00]

%include "animation.asm"
%include "print.asm"
%include "kernel_loader.asm"

boot_start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, 0x0003
    int 0x10

    call shark_animation

    mov si, boot_msg
    call print_string

    call load_stage2

    jmp 0x1000:0x0000

boot_msg: db 13,10, 'Booting SharkOS...', 13,10, 0
times 510-($-$$) db 0
dw 0xAA55
