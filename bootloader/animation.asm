[BITS 16]

shark_animation:
    pusha
    mov cx, 5               ; 5 letters in SHARK
    mov bx, shark_frames
    
.animate_loop:
    push cx
    push bx
    
    ; Clear screen
    mov ax, 0x0003
    int 0x10
    
    ; Set cursor position (center screen)
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 10              ; Row 10
    mov dl, 35              ; Column 35
    int 0x10
    
    ; Print current frame
    mov si, bx
    call print_string
    
    ; Delay for animation effect
    mov cx, 0x05
    mov dx, 0x0000
.delay:
    mov ah, 0x86
    int 0x15
    loop .delay
    
    pop bx
    pop cx
    add bx, 2               ; Next frame pointer
    loop .animate_loop
    
    popa
    ret

shark_frames:
    dw frame_s, frame_h, frame_a, frame_r, frame_k

frame_s: db 'S', 0
frame_h: db 'SH', 0
frame_a: db 'SHA', 0
frame_r: db 'SHAR', 0
frame_k: db 'SHARK', 0
