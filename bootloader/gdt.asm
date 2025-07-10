[BITS 16]

; --------------------------------------
; GDT - Global Descriptor Table
; --------------------------------------

gdt_start:
    dq 0x0000000000000000     ; Null descriptor

    ; Code Segment: base=0x00000000, limit=0xFFFFFFFF, type=0x9A
    dq 0x00CF9A000000FFFF

    ; Data Segment: base=0x00000000, limit=0xFFFFFFFF, type=0x92
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; Size of GDT
    dd gdt_start                  ; Linear address of GDT
