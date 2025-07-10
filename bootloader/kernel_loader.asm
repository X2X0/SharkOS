[BITS 16]

load_stage2:
    pusha
    
    ; Reset disk system
    mov ah, 0x00
    mov dl, 0x80            ; First hard drive
    int 0x13
    
    ; Read sectors containing stage 2
    mov ah, 0x02            ; Read sectors function
    mov al, 4               ; Number of sectors to read
    mov ch, 0               ; Cylinder
    mov cl, 2               ; Starting sector (sector 2)
    mov dh, 0               ; Head
    mov dl, 0x80            ; Drive number
    mov bx, 0x1000          ; Buffer segment
    mov es, bx
    mov bx, 0x0000          ; Buffer offset
    int 0x13
    
    jc disk_error
    popa
    ret

disk_error:
    mov si, disk_err_msg
    call print_string
    hlt

disk_err_msg: db 'Disk read error!', 0
