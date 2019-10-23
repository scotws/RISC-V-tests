# Linux System Calls for RISC-V with GNU GCC/Spike/pk
Scot W. Stevenson <scot.stevenson@gmail.com>   
First version: 03. October 2019   
This version: 21. October 2019   

There is an [easy procedure](./riscv_howto_syscalls.md) for accesing Linux
system calls from RISC-V as defined by `man 2 <CALL>`. To make things even
easier, this is a running list of useful calls I have used defined directly for
RISC-V with examples. Assumes the GNU GCC assembler is used for the Spike
simulator with pk and RV64I. 

Use these at your own risk, I take no resposibility. I am grateful for
corrections, additions, and comments. This document is copyright Creative
Commons by Attribution (CC BY). 

// -------------------------------------------------------------------
## EXIT

Terminate the process (`man 2 exit`). Use this to end the program.

### Registers

- a0: Return value: 0 for all okay, other for error
- a7: System Call code for `exit`: 94

### Return value

_none_ 

### Example code

```
        .equ SYS_EXIT, 94

        .section .text
        .align 2

        li a0, 0                # Return code, no error
        li a7, SYS_EXIT         # System call code for write
        ecall
```


### Notes

_none_


// -------------------------------------------------------------------
## MMAP

Map files or directories into memory (`man 2 mmap`). Used here for anonymous
memory. Note that each call reserves at least one page of memory. 

### Registers

- a0: Page address, `NULL` (0) for anonymous
- a1: Page size, usually 4096 bytes for Linux
- a2: Memory protection, see below
- a3: Flags: Shared, private or anonymous
- a4: File descriptor, -1 for anonymous on Linux
- a5: Offset, 0 for anonymous
- a7: System Call code for `mmap`: 222

### Return value

- a0: 0 on success, -1 on failure

### Example code

```
        .equ SYS_MMAP, 222
        .equ SYS_WRITE, 64

        .equ PAGESIZE, 4096

        .equ PROT_READ, 0x1
        .equ PROT_WRITE, 0x2
        .equ MAP_ANONYMOUS, 0x20
        .equ MAP_PRIVATE, 0x02

        .equ STDOUT, 1

        .section .rodata
        .align 2

success:        .ascii  "Mapping successful\n"
l_success:      .byte   .-success

failure:        .ascii  "Could not map\n"
l_failure:      .byte   .-success

        .section .text
        .align 2
        .global _start

_start:
        # Print prompt
        li a0, 0                        # NULL, because we want anonymous mapping
        li a1, PAGESIZE                 # Linux standard page is 4096
        li a2, PROT_READ|PROT_WRITE     # Read and write to page
        li a3, MAP_ANONYMOUS|MAP_PRIVATE  
        li a4, -1                       # File descriptor for anonymous
        li a5, 0                        # Offset
        li a7, SYS_MMAP
        ecall 

        # Print success or failure
        beqz a0, itworked

        # Failure
        la a1, failure
        la a2, l_failure
        j print

itworked:
        # Success
        la a1, success
        lbu a2, l_success

print:
        li a0, STDOUT           # String goes to stdout (screen)
        li a7, SYS_WRITE
        ecall 
```

### Notes

- Use `munmap` to free memory again, see below
- `mmap` is the recommended way to reserve memory in modern systems instead of
  `brk` and `sbrk`. 
- To get the values for parameters such as `MAP_ANONYMOUS`, run
  `echo '#include <sys/mman.h>' | gcc -E - -dM | less` which accesses the
  preprocessor (see
  https://stackoverflow.com/questions/38602525/looking-for-mmap-flag-values for
  a discussion). Also, see https://github.com/riscv/riscv-pk/blob/master/pk/mmap.h


// -------------------------------------------------------------------
## READ

Read characters into a buffer (`man 2 read`). Use this to get a string from the
user.

### Registers

- a0: File descriptor, usually STDIN (keyboard), which is 0
- a1: Address of buffer to store string
- a2: Maximal string length to receive
- a7: System Call code for `read`: 63

### Return value

- a0: Number of bytes read if all went well, otherwise -1

### Example code

```
        .equ STDIN, 0
        .equ SYS_READ, 63
        .equ MAX_CHARS, 255

        .section .bss
        .align 2

buffer:         .space  256

        .section .text
        .align 2

        li a0, STDIN            # File descriptor, 0 for STDIN
        la a1, buffer           # Address of buffer to store string
        li a2, MAX_CHARS        # Maximum number of chars to store
        li a7, SYS_READ         # System call code for read
        ecall

        # TODO: ERROR HANDLING if a0 = -1
```


### Notes

_none_


// -------------------------------------------------------------------
## WRITE

Write bytes from a buffer to a file descriptor (`man 2 write`). Use this to
print a string. 

### Registers

- a0: File to write to, usually STDOUT (screen), which is 1.
- a1: Address of the character buffer
- a2: Length of the string
- a7: System Call code for `write`: 64

### Return value

- a0: Number of bytes written if all is well, or -1 for error

### Example code

```
        .equ STDOUT, 1
        .equ SYS_WRITE, 64

        .section .rodata
        .align 2

msg:    .ascii  "We miss Deanna Troi"
l_msg:  .byte   .-msg


        .section .text
        .align 2

        li a0, STDOUT           # File descriptor, 1
        la a1, msg              # Address of the message
        lbu a2, l_msg           # Length of string
        li a7, SYS_WRITE        # System call code for write
        ecall

        # TODO: ERROR HANDLING: See if a0 == a2
```

### Notes

- Strings defined this way are not zero terminated; use `.ascii` instead of
  `.asciz` or `.string`.

// -------------------------------------------------------------------
