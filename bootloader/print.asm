[BITS 16]

print_string:
    pusha
.loop:
    lodsb                   ; Load byte from SI
    test al, al             ; Check for null terminator
    jz .done
    mov ah, 0x0E            ; BIOS teletype
    mov bh, 0x00            ; Page number
    mov bl, 0x07            ; Color (light gray)
    int 0x10
    jmp .loop
.done:
    popa
    ret

print_string_16:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x0F            ; Bright white
    int 0x10
    jmp .loop
.done:
    popa
    ret
