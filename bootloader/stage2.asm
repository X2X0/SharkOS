[BITS 16]
[ORG 0x10000]    ; Stage 2 is loaded here by stage1

%include "gdt.asm"
%include "a20.asm"
%include "paging.asm"
%include "longmode.asm"

stage2_start:
    ; Print Stage 2 message
    mov si, stage2_msg
    call print_string_16

    ; Enable A20 line to access memory beyond 1MB
    call enable_a20

    ; Load GDT for 32-bit mode
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to 32-bit protected mode
    jmp 0x08:protected_mode_entry

stage2_msg: db 'Stage 2 loaded. Switching to protected mode...', 13, 10, 0
