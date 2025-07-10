[BITS 16]

load_stage2:
    pusha
    
    mov ah, 0x00
    mov dl, 0x80
    int 0x13
    
    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    mov bx, 0x1000
    mov es, bx
    mov bx, 0x0000
    int 0x13
    
    jc disk_error
    popa
    ret

disk_error:
    mov si, disk_err_msg
    call print_string
    hlt

disk_err_msg: db 'Disk read error!', 0
