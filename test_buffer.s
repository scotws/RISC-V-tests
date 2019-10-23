# Buffer Test in RISC-V assembler GNU/Spike
# Scot W. Stevenson <scot.stevenson@gmail.com>  
# First version: 03. Oct 2019
# This version: 23. Oct 2019

# Using only Linux system calls, prompt user for string and place it in
# a buffer. Print string from buffer. Requires RV64I arch

# Spike emulator: 
# - Assemble with riscv64-unknown-elf-gcc test_buffer.s \
#       -o test_buffer \
#       -nostartfiles -nostdlib \
# - Execute with spike pk test_stringmatrix02

# Fedora RISC-V in QEMU: 
# - Assemble with gcc test_buffer.s -o test_buffer \
#       -nostartfiles -nostdlib \
# - Execute resulting binary file normally

        .option nopic

        .equ SYS_READ, 63
        .equ SYS_WRITE, 64
        .equ SYS_EXIT, 94

        .equ MAX_STRING, 256    # max string size

        .equ STDIN, 0
        .equ STDOUT, 1


# ==== READ-ONLY DATA ====

        .section .rodata
        .align 2

prompt:         .ascii  "Please enter a string: "
l_prompt:       .byte   .-prompt  

msg:            .ascii  "You entered: "
l_msg:          .byte   .-msg 


# ==== VARIABLES AND BUFFERS ====

        .section .bss
        .align 2

buffer:         .space  256


# ==== PROGRAMM CODE ====

        .section .text
        .align 2
        .global _start

_start:
        # Print prompt
        li a0, STDOUT           # String goes to stdout (screen)
        la a1, prompt           # String address
        lbu a2, l_prompt        # Length of string
        li a7, SYS_WRITE
        ecall 

        # Get string from user
        li a0, STDIN            # Get input from stdin (keyboard)
        la a1, buffer           # Put in buffer
        li a2, MAX_STRING       # maximal string size
        li a7, SYS_READ
        ecall

        mv s0, a0               # Save length of input string
        
        # Print result
        li a0, STDOUT           # String goes to stdout (screen)
        la a1, msg              # String address
        lbu a2, l_msg           # Length of string
        li a7, SYS_WRITE
        ecall 

        li a0, STDOUT
        la a1, buffer
        mv a2, s0               # length of input string
        li a7, SYS_WRITE
        ecall

        # All done, exit signalling all okay
        li a0, 0
        li a7, SYS_EXIT
        ecall

        .end


