# Test for String Matrix storage, second version
# Scot W. Stevenson <scot.stevenson@gmail.com>
# First version: 29. Sep 2019
# This version: 23. Oct 2019

# Figure out a way to print strings with a call to a function with a single.
# number, storing the string data somewhere. Requires RV64IC arch 

# Spike emulator: 
# - Assemble with riscv64-unknown-elf-gcc test_buffer.s \
#       -o test_buffer \
#       -nostartfiles -nostdlib \
# - Execute with spike pk test_stringmatrix02

# Fedora RISC-V in QEMU: 
# - Assemble with gcc test_buffer -o test_buffer \
#       -nostartfiles -nostdlib \
# - Execute resulting binary file normally

        .option nopic
        .align 2

        .equ SYS_WRITE, 64      # magic number for write (2) Linux System Call 
        .equ SYS_EXIT, 93       # magic number for exit (2) Linux System Call

        .equ STDOUT, 1          # magic number for Standard Output

	.equ U_BUFFY, 0		# First entry
	.equ U_SPIKE, 6		# Last entry

        .section .text

#  ---- MAIN ----

# Test routine to walk through all entries of the table as an experiment. If this were
# the actual routine, we'd terminate the table with a zero entry and test for that. 

        .global _start
_start:

                # Print from U_BUFFY to U_ANYA
                li a0, U_BUFFY          # Start value
                li s1, U_SPIKE          # Last value
                mv s0, a0               # Save a copy of current user number

loop:
                jal ra, print_string    # Print the string
                jal ra, print_eol       # Print the EOL (testing, should be part of strings)

                addi s0, s0, 1          # Add to counter
                bgt s0, s1, done        # Break loop if we're done 

                mv a0, s0               # Move user number to a0 for subroutine call
                j loop

done:        
                # We're done, we exit
                li a7, SYS_EXIT
                ecall 

        .size _start, .-_start


# ---- SUBROUTINES ----

# print_string takes the number of the user to print in a0 and does the rest
# by itself
print_string:
                # Save the return address 
                addi sp, sp, -8
                sw ra, 0(sp)
                
                mv t0, a0               # temporary store for user number
                li a0, STDOUT           # Para 1: Send output to stdout

                la t1, string_table     # Base address of string table 

                sll t3, t0, 3           # Offset to table is table size * user number.
                                        # Shifting 3 times multiplies by 8 which is the
                                        # number of bytes of a table entry (64 bit)
                add t4, t1, t3          # Address of string's address in table
                ld a1, 0(t4)            # Para 2: Address of string


		la t1, length_table	# Base address of length table
		add t1, t1, t0		# Offset to table is user number in bytes
                lbu a2, 0(t1)           # Para 3: Length of string

                li a7, SYS_WRITE        # Linux System Call to write (2) 
                ecall

                # Restore the return address, restore the stack pointer
                ld ra, 0(sp)
                addi sp, sp, 8

                ret

        .size print_string, .-print_string

# print_eol prints a line feed. This is just for testing only, we actually should be
# including the line feeds in the strings
print_eol:

                # Save the return address
                addi sp, sp, -8
                sw ra, 0(sp)

                li a0, STDOUT           # file where output goes
                la a1, s_eol            # Can't use ASCII code for EOL directly
                li a2, 1                # Length of code
                li a7, SYS_WRITE
                ecall

                # Restore the return address and return
                ld ra, 0(sp)
		addi sp, sp, 8

                ret

        .size print_eol, .-print_eol


        .section .rodata

# ---- STRINGS ----

string_table:
	# The string table contains the addresses of the tables, which for RV64 means
	# 8 byte (64 bit) entries
        .dword s_buffy, s_giles, s_willow, s_xander, s_tara, s_anya, s_spike

length_table:
	# The length table contains the lengths of the strings. We limit strings to
	# 256 chars. This saves space with large tables
	.byte 5, 5, 6, 6, 4, 4, 5

# Raw strings, not zero-terminated, sorted by user number
s_buffy:        .ascii "Buffy"
s_giles:        .ascii "Giles"
s_willow:       .ascii "Willow"
s_xander:       .ascii "Xander"
s_tara:		.ascii "Tara"
s_anya:		.ascii "Anya"
s_spike:	.ascii "Spike"

# System strings
s_eol:          .ascii "\n"

        .end
