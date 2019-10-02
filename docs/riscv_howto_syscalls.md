# How to use Linux System Calls with RISC-V
Scot W. Stevenson <scot.stevenson@gmail.com>   
First version: 29. Sep 2019   
This version: 02. Oct 2019   

This text assumes you have set up a basic RISC-V system with the RISC-V GNU GCC
Toolchain and the Spike simulator (though you can use other emulators as well).

## Background 

System calls are the fundamental interface between a program and the Linux
kernel. You can access them from assembler programs to bypass other libraries.
See `man 2 syscalls' or http://man7.org/linux/man-pages/man2/syscalls.2.html for
more information and a complete list of system calls.

## System calls in C

In C, a list of parameters is passed to the kernel in a certain sequence. For
instance, for `write`, we have (see `man 2 write`):

```
ssize_t write(int fd, const void *buf, size_t count);
```

The three parameters passed are a file descriptor, a pointer to a character
buffer (in other words, a string) and the number of characters in that string to
be printed. The [file descriptor](https://en.wikipedia.org/wiki/File_descriptor)
can be the Standard Output. Note the string is not zero-terminated. In other
words, this is very much like the `(addr n)` structure of Forth strings. 

## RISC-V calling conventions

The RISC-V convention as defined by
https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf is to map these
parameters one by one to the registers starting at `a0`, put the number for the
system call in `a7`, and execute the `ecall` instruction. In our case: 

- The file descriptor number goes in `a0`.

- The pointer to the string -- its address -- goes in `a1`. 

- The number of characters to print goes in `a2`. 

To find the magic number for the system call for `write` and the Spike simulator
with pk, we take a look at
https://github.com/riscv/riscv-pk/blob/master/pk/syscall.h . It turns out to be
64. This goes into `a7`. 

After a successful write, we should receive the number of characters written in
`a0`. If there was an error, the return value should be -1. 

## Example

To print the string "RISC-V" and then quit with the `exit` system call with the
GNU GCC compiler suite and the Spike simulator, this is one possible solution:

```        
        .equ STDOUT, 1
        .equ WRITE, 64
        .equ EXIT, 93

        .globl  _start
_start:
        
        li a0, STDOUT  # file descriptor
        la a1, msg     # address of string
        li a2, 7       # length of string
        li a7, WRITE   # syscall number for write
        ecall

        # MISSING: Check for error condition

        li a0, 0       # 0 signals success
        li a7, EXIT
        ecall

msg:
        .ascii "RISC-V\n"
```        

We assemble, link and run this program with 

```        
riscv64-unknown-elf-gcc riscv_out.s -o riscv_out -nostartfiles -nostdlib
spike pk riscv_out
```        

> This example assumes RV64 - if you want to run the 32-bit version, you'll
> have to have a 32-bit version of pk, even if you pass the `--isa=RV32I`
> argument to Spike. See https://github.com/riscv/riscv-gnu-toolchain/issues/162
> for a discussion of this problem.

## Sources 

This text is based on a [Reddit
discussion](https://www.reddit.com/r/RISCV/comments/dagvzr/where_do_i_find_the_list_of_stdio_system_etc/).
Thanks to everybody there for the help, especially Bruce Hoult.
