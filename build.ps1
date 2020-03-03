param(
    [string]$Target = "mkiso"
)

switch ($Target) {
    "deps" {
        wsl sudo apt update
        wsl sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev grub-common xorriso nasm grub-pc-bin libfontconfig1 mesa-common-dev libglu1-mesa-dev -y
    }
    "mkiso" {
        wsl as --32 boot.s -o boot.o
        wsl gcc -m32 -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra
        wsl gcc -m32 -c utils.c -o utils.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra
        wsl gcc -m32 -c char.c -o char.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra
        wsl gcc -m32 -c logo.c -o logo.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra
        wsl ld -m elf_i386 -T linker.ld kernel.o utils.o char.o logo.o boot.o -o charleX.bin -nostdlib
        wsl grub-file --is-x86-multiboot charleX.bin
        wsl mkdir -p iso/boot/grub
        wsl cp charleX.bin iso/boot/charleX.bin
        wsl cp grub.cfg iso/boot/grub/grub.cfg
        wsl grub-mkrescue -o charleX.iso iso
    }
    "clean" {
        Remove-Item -Path "*.bin", "*.o" -Force
    }
    default {
        Write-Host "Invalid target. Use deps, mkiso, or clean."
    }
}
