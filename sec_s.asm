; second_sector.asm - Code loaded by bootloader as second sector
; It prints "second sector" on the screen and then stops

org 0x8000                ; Loaded at memory address 0x8000

start:
    mov si, second_msg     ; Point SI to our message string
.print_char:
    lodsb                  ; Load next char into AL, advance SI
    cmp al, 0              ; If zero, end of string
    je hang                ; Stop execution
    mov ah, 0x0E           ; BIOS print char function
    mov bh, 0              ; Display page number
    mov bl, 0x07           ; Text color (gray)
    int 0x10               ; Print character
    jmp .print_char        ; Next char

hang:
    jmp $                  ; Infinite loop to stop execution

second_msg db 'second sector', 0x0D, 0x0A, 0  ; Message with CR LF and string terminator

times 512-($-$$) db 0     ; Fill rest of sector with zeros
