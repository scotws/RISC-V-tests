# Hex to ASCII conversion Test in RISC-V assembler 
# Scot W. Stevenson <scot.stevenson@gmail.com>  
# First version: 03. Oct 2019
# This version: 23. Oct 2019

# Given a byte, create and print the corresponding two hex number's characters
# using Linux system calls. For example, $1E would be printed as "1E". We
# assume that the number we have been given has been checked for the correct
# range and that the hex numerals A-F are uppercase (0x14 to 0x46 ASCII)
# Requires RV64I arch.

# Fedora RISC-V in QEMU:
# - Assemble with gcc test_hex2ascii.s -o test_hex2ascii \
#       -nostartfiles -nostdlib \
# - Execute resulting binary file normally

# This does NOT currently work with the Spike emulator. Commands should be:
# - Assemble with riscv64-unknown-elf-gcc test_hex2ascii.s \
#       -o test_hex2ascii \
#       -nostartfiles -nostdlib \
# - Execute with spike pk test_hex2ascii

        .option nopic

        .equ SYS_WRITE, 64
        .equ SYS_EXIT, 94

        .equ STDIN, 0
        .equ STDOUT, 1

        .equ TESTNUMBER, 0x1E


# ==== VARIABLES AND BUFFERS ====

        .section .bss
        .align 2

buffer:         .space  3


# ==== MAIN PROGRAMM ====

        .section .text
        .align 2
        .global _start

_start:

        li s0, TESTNUMBER
        la s1, buffer

        # Start with LSB by masking everything else. We keep a copy of the 
        # original number in s0
        mv a0, s0

        jal ra, convert_lsn     # Returns ASCII value in a0
        sb a0, 1(s1)            # Save LSN to buffer

        # Now the MSB
        mv a0, s0
        srai a0, a0, 4
        jal ra, convert_lsn     # Returns ASCII value in a0
        sb a0, 0(s1)            # Save LSN to buffer

        # Add a line feed (0x0A) to the string to make it look better
        li a0, 0x0A
        sb a0, 2(s1)

        # Print result
        li a0, STDOUT           # String goes to stdout (screen)
        la a1, buffer           # String address
        li a2, 3                # Length of string
        li a7, SYS_WRITE
        ecall 

        # All done, exit signalling all okay
        li a0, 0
        li a7, SYS_EXIT
        ecall

## ---- SUBROUTINES ----

# convert_lsn takes a byte in a0 and converts the least significant nibble 
# (LSN) to the equivalent ASCII character, returning it in a0.
convert_lsn:
        # We need to see if we have a numeral or a 0xA to 0xF
        li t0, 0x9 
        
        # Mask everything except the LSN
        andi a0, a0, 0x0F

        # See if we need to add 0x7 for 0xA to 0xF
        ble a0, t0, numeral

        # Add 7 for 0xA to 0xF
        addi a0, a0, 0x7

numeral:
        # We always add 0x30 for the conversion
        addi a0, a0, 0x30

        ret

        .end


