; =============================================================================
; FILE: a20.asm - A20 Line Enable
; =============================================================================
[BITS 16]

enable_a20:
    pusha
    
    ; Try keyboard controller method
    call wait_8042_command
    mov al, 0xAD
    out 0x64, al            ; Disable keyboard
    
    call wait_8042_command
    mov al, 0xD0
    out 0x64, al            ; Read output port
    
    call wait_8042_data
    in al, 0x60
    push eax
    
    call wait_8042_command
    mov al, 0xD1
    out 0x64, al            ; Write output port
    
    call wait_8042_command
    pop eax
    or al, 2                ; Set A20 bit
    out 0x60, al
    
    call wait_8042_command
    mov al, 0xAE
    out 0x64, al            ; Enable keyboard
    
    popa
    ret

wait_8042_command:
    in al, 0x64
    test al, 2
    jnz wait_8042_command
    ret

wait_8042_data:
    in al, 0x64
    test al, 1
    jz wait_8042_data
    ret
