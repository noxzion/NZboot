@echo off
del bootloader.bin 2>nul
del second_sector.bin 2>nul
del floppy.img 2>nul

echo Building boot.asm...
nasm -f bin boot.asm -o bootloader.bin
if errorlevel 1 (
    echo Failed to build boot.asm
    pause
    exit /b 1
)

echo Building sec_s.asm...
nasm -f bin sec_s.asm -o second_sector.bin
if errorlevel 1 (
    echo Failed to build sec_s.asm
    pause
    exit /b 1
)

echo Creating floppy.img...
copy /b bootloader.bin + second_sector.bin floppy.img > nul
if errorlevel 1 (
    echo Failed to create floppy.img
    pause
    exit /b 1
)

echo Running QEMU...
qemu-system-x86_64 -drive file=floppy.img,format=raw

pause
