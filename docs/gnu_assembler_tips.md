# Tips for the GNU GCC Assembler and RISC-V
Scot W. Stevenson <scot.stevenson@gmail.com>   
First version: 03. October 2019  
This version: 03. October 2019  

This is a random list of things I learned using the GNU GCC assembler for RISC-V. 

## Getting the length of a string for a System Call

Linux system calls take the string in the "Forth" format: Address of first
character and length of string. There is no terminating zero. The actual string
is defined in the `.rodata` read-only data section as:

```
msg:    .ascii  "Deanna Troi we miss you"
```

The problem is finding out the length, because counting is error-prone (and
stupid). We can have the assembler calculate the length by adding a line such as
this one right after the string definition: 

```
l_msg:  .byte   .-msg
```

The dot stand for the current address. We can then load the length to a register
with something like

```
        lbu a2, l_msg
```

This way, if we edit the string, we don't have to recalculate everything.

## Best practices as defined by me

... since nobody else seems willing to to it: 

- Use `.global` instead of `.globl`. This is just another weird ancient design
  decision like `umount` instead of `unmount` that needs to die.

## Useful links 

https://community.arm.com/developer/ip-products/processors/b/processors-ip-blog/posts/useful-assembler-directives-and-macros-for-the-gnu-assembler

