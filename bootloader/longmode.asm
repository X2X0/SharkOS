; Page tables (must be 4KB aligned)
align 4096
pml4_table:
    resb 4096

pdp_table:
    resb 4096

pd_table:
    resb 4096

; =============================================================================
; 64-bit Long Mode Entry Point
; =============================================================================
[BITS 64]
long_mode_start:
    ; Set up 64-bit segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x200000       ; 64-bit stack

    ; Load kernel from disk
    call load_kernel_64

    ; Jump to kernel entry point
    mov rax, 0x100000       ; Kernel entry point
    jmp rax
