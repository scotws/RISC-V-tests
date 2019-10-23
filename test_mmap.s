# mmap system call test in RISC-V assembler GNU/Spike
# Scot W. Stevenson <scot.stevenson@gmail.com>  
# First version: 20. Oct 2019
# This version: 23. Oct 2019

# Using only Linux system calls, reserve on page of memory and then free it 
# again. Requires RV64I arch.

# Fedora RISC-V in QEMU: 
# - Assemble with gcc test_mmap.s -o test_mmap \
#       -nostartfiles -nostdlib \
# - Execute resulting binary file normally

# This does NOT currently work with the Spike emulator. Commands should be: 
# - Assemble with riscv64-unknown-elf-gcc test_mmap.s \
#       -o test_mmap \
#       -nostartfiles -nostdlib \
# - Execute with spike pk test_mmap

# To get the values for PROT_READ etc, follow the instructions at 
# https://stackoverflow.com/questions/38602525/looking-for-mmap-flag-values,
# especially echo '#include <sys/mman.h>' | gcc -E - -dM | less

        .option nopic

        .equ SYS_MMAP, 222 
        .equ SYS_MUNMAP, 215
        .equ SYS_WRITE, 64
        .equ SYS_EXIT, 94

        .equ PAGESIZE, 4096

        .equ PROT_READ, 0x1 
        .equ PROT_WRITE, 0x2 
        .equ MAP_ANONYMOUS, 0x20
        .equ MAP_PRIVATE, 0x02

        .equ STDOUT, 1


# ==== READ-ONLY DATA ====

        .section .rodata
        .align 2

success:        .ascii  "Mapping successful\n"
l_success:      .byte   .-success

failure:        .ascii  "Could not map\n"
l_failure:      .byte   .-failure

unmap_ok:       .ascii  "Unmapping successful\n"
l_unmap_ok:     .byte   .-unmap_ok

unmap_fail:     .ascii  "Unmapping failed\n"
l_unmap_fail:   .byte   .-unmap_fail

# ==== PROGRAMM CODE ====

        .section .text
        .align 2
        .global _start

_start:
        # Setup mmap call
        li a0, 0                        # NULL, because we want anonymous mapping
        li a1, PAGESIZE                 # Linux standard page is 4096
        li a2, PROT_READ|PROT_WRITE     # Read and write to page
        li a3, MAP_ANONYMOUS|MAP_PRIVATE  
        li a4, -1                       # File descriptor for anonymous
        li a5, 0                        # Offset
        li a7, SYS_MMAP
        ecall

        # Save address we were returned for unmapping
        mv s0, a0

        # Print success or failure. Note that mmap returns the the 
        # address of the memory we reserved or -1 for a failure.
        li t0, -1
        bne a0, t0, itworked

        # Failure
        la a1, failure
        la a2, l_failure
        j print

itworked:
        # Success
        la a1, success
        lbu a2, l_success       # fall through to print

print:
        li a0, STDOUT           # String goes to stdout (screen)
        li a7, SYS_WRITE
        ecall

        # Now we need to free the memory again with munmap. We saved 
        # the address in s0
        mv a0, s0               # Address we were given
        li a1, PAGESIZE
        li a7, SYS_MUNMAP
        ecall

        # If all was well, we get a 0 in a0
        beqz a0, unmap_worked

        # Unmap failure
        la a1, unmap_fail
        lbu a2, l_unmap_fail
        j print_end

unmap_worked:
        la a1, unmap_ok
        lbu a2, l_unmap_ok       # fall through to print_end

print_end:
        li a0, STDOUT           # String goes to stdout (screen)
        li a7, SYS_WRITE
        ecall

all_done:
        # All done, exit signalling all okay
        li a0, 0
        li a7, SYS_EXIT
        ecall

        .end

