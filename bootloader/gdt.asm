; =============================================================================
; FILE: gdt.asm - Global Descriptor Table
; =============================================================================
[BITS 16]

; 32-bit GDT for protected mode
gdt_start:
    ; Null descriptor
    dq 0x0000000000000000
    
    ; Code Segment: base=0x00000000, limit=0xFFFFFFFF, type=0x9A
    dq 0x00CF9A000000FFFF
    
    ; Data Segment: base=0x00000000, limit=0xFFFFFFFF, type=0x92
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; Size of GDT
    dd gdt_start                  ; Linear address of GDT

; 64-bit GDT for long mode
gdt64_start:
    ; Null descriptor
    dq 0x0000000000000000
    
    ; Code segment (64-bit)
    dq 0x00AF9A000000FFFF
    
    ; Data segment (64-bit)
    dq 0x00AF92000000FFFF

gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dd gdt64_start
