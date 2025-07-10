; =============================================================================
; FILE: stage2.asm - Extended Bootloader
; =============================================================================
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

; =============================================================================
; 32-bit Protected Mode Entry Point
; =============================================================================
[BITS 32]
protected_mode_entry:
    ; Set up segment registers
    mov ax, 0x10            ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000        ; Stack for protected mode

    ; Call paging setup (builds PML4, PDP, PD)
    call setup_paging

    ; Load GDT for 64-bit long mode
    lgdt [gdt64_descriptor]

    ; Enable PAE (bit 5 of CR4)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Set CR3 to point to PML4 table
    mov eax, pml4_table
    mov cr3, eax

    ; Enable Long Mode (LME bit in EFER MSR)
    mov ecx, 0xC0000080     ; IA32_EFER MSR
    rdmsr
    or eax, 1 << 8          ; Set LME (Long Mode Enable)
    wrmsr

    ; Enable paging and long mode
    mov eax, cr0
    or eax, 0x80000001      ; PG + PE
    mov cr0, eax

    ; Far jump to 64-bit long mode
    jmp 0x08:long_mode_start
