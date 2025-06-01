; bootloader.asm - Simple two-sector bootloader
; This code runs first when the computer boots from the disk.
; It prints "hello" on the screen, then loads the second sector and jumps there.

org 0x7C00                ; BIOS loads bootloader here (0x7C00)

start:
    mov [BOOT_DRIVE], dl  ; Save the drive number BIOS gives us in DL, we will need it later

    ; Print "hello" message on screen
    mov si, hello_msg
.print_char:
    lodsb                 ; Load next byte from string (AL = *SI, SI++)
    cmp al, 0             ; Check for string end (0 = end)
    je load_second_sector ; If zero, jump to loading second sector
    mov ah, 0x0E          ; BIOS teletype function - print char in AL
    mov bh, 0x00          ; Display page number (usually 0)
    mov bl, 0x07          ; Text color attribute (gray)
    int 0x10              ; Call BIOS video interrupt to print character
    jmp .print_char       ; Repeat for next character

load_second_sector:
    ; Now load second sector from disk into memory at 0x8000
    mov ah, 0x02          ; BIOS function: read sectors
    mov al, 1             ; Number of sectors to read = 1
    mov ch, 0             ; Cylinder = 0 (start of disk)
    mov cl, 2             ; Sector = 2 (we want second sector)
    mov dh, 0             ; Head = 0
    mov dl, [BOOT_DRIVE]  ; Drive number from BIOS
    mov bx, 0x8000        ; Memory address to load second sector into
    int 0x13              ; Call BIOS disk interrupt
    jc disk_error         ; If carry flag set, error happened

    ; Jump to code we just loaded (second sector)
    jmp 0x0000:0x8000     

disk_error:
    ; If disk read failed, print error message
    mov si, err_msg
.print_err:
    lodsb
    cmp al, 0
    je hang               ; End of string - hang
    mov ah, 0x0E
    int 0x10
    jmp .print_err

hang:
    jmp $                 ; Infinite loop to stop execution

hello_msg db 'hello', 0x0D, 0x0A, 0  ; 'hello' followed by CR LF and string terminator
err_msg db 'Disk read error!', 0

BOOT_DRIVE db 0           ; Will store BIOS boot drive number here

times 510-($-$$) db 0     ; Fill the rest of the sector with zeros
dw 0xAA55                 ; Boot sector signature (required)
