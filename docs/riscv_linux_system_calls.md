# Linux System Calls for RISC-V with GNU GCC/Spike/pk
Scot W. Stevenson <scot.stevenson@gmail.com>   
First version: 03. October 2019   
This version: 03. October 2019   

There is an [easy procedure](./riscv_howto_syscalls.md) for accesing Linux
system calls from RISC-V as defined by `man 2 <CALL>`. To make things easier,
this is a running list of useful calls I have used defined directly for RISC-V
with examples. Assumes the GNU GCC assembler is used for the Spike simulator
with pk and RV64I. 

Use these at your own risk, I take no resposibility. I am grateful for
corrections, additions, and comments.


## WRITE

Write bytes from a buffer to a file descriptor (`man 2 write`).

### Registers

- a0: File to write to, usually STDOUT, which is 1.
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

