
; Page tables (must be 4KB aligned)
align 4096
pml4_table:
    resb 4096

pdp_table:
    resb 4096

pd_table:
    resb 4096
