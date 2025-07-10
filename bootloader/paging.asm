[BITS 32]

setup_paging:
    ; Clear all page table entries
    mov edi, pml4_table
    mov ecx, 4096 / 4            ; 4096 bytes / 4 bytes per dword
    xor eax, eax
    rep stosd

    ; Clear PDP table
    mov edi, pdp_table
    mov ecx, 4096 / 4
    xor eax, eax
    rep stosd

    ; Clear PD table
    mov edi, pd_table
    mov ecx, 4096 / 4
    xor eax, eax
    rep stosd

    ; Set PML4[0] to point to PDP table
    mov dword [pml4_table], pdp_table + 0x03   ; Present + Read/Write

    ; Set PDP[0] to point to PD table
    mov dword [pdp_table], pd_table + 0x03     ; Present + Read/Write

    ; Set up Page Directory with 2MB pages
    mov edi, pd_table
    mov eax, 0x83                  ; Present + Read/Write + Page Size (2MB)
    mov ecx, 512

.setup_pd:
    stosd                          ; Write entry
    add edi, 4                     ; Skip high 32 bits
    add eax, 0x200000              ; Next 2MB frame
    loop .setup_pd

    ret
