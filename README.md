# RISC-V Assembler Experiments
Scot W. Stevenson <scot.stevenson@gmail.com>   
First version: 25. September 2019   
This version: 23. October 2019    

Contained here are experiments in RISC-V assembly language as learning
experiences. 

The folder `DosReis` contains programs and solutions based on the book *RISC-V
Assembler Language* by Anthony J. Dos Reis. These end in `.a` and use the `rv`
tool. The programs in the main directory use the full GNU GCC toolset, either
with the Spike emulator, or QEMU with Fedora 31. 

Obviously you'd have to be competely nuts to use any of this for your own stuff,
because this is part of me learning RISC-V and all very, very experimental. If
you do, note these are provided as is, with no guaranty, and I take no
responsibility for anything that happens. 

This code is placed in the public domain unless otherwise noted.

## Included Documentation

Included in the folder `docs` are my notes on setting various things up and
running them. 

- An [introduction](docs/riscv_howto_syscalls.md) to accessing Linux system
  calls via RISC-V assembler.

- A [very incomplete list](docs/riscv_linux_system_calls.md) of Linux system
  calls and how they are accessed in RISC-V assembler, with examples. 

- Setting up [Fedora RISC-V on QEMU emulator](docs/qemu_fedora_riscv_setup.md)
  to access a complete Linux system. I usually use Ubuntu, but in this case,
  Fedora seems to have a definite leg up.

- [Notes](docs/gnu_assembler_tips.md) on using the GNU GCC assembler for
  RISC-V.

## Getting Started

After trying various setups, I have found that the easiest way to get started
with RISC-V assembly programming is currently through Dos Reis' book and
software. Once you would like to have access to the full might and power of the
GNU GCC assembler, I suggest switching to Fedora on QEMU, as Spike/PK gave me
some trouble. 
