rv Version 3.2                        Thu Sep 26 21:54:11 2019
Scot W. Stevenson

Header
R
T 00000000
S 00000000
D 00000040
C

Loc         Instruction in Binary                   Source Code

                                              # Stringcount experiment
                                              # Scot W. Stevenson <scot.stevenson@gmail.com>
                                              # First version: 26. Sep 2019
                                              # This version: 26. Sep 2019

                                              # Accept a string and return its length.

                                              .text
                                              _start:
                                              		# print string
0000  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, prompt
0004  0000 0011 1000 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0008  0000 1100 0000 0010 1000 0000 0000 0000 		sout t0

                                              		# We put the string address in a0 because later
                                              		# probably be passed as function. Also, we're n
                                              		# sin stores the string in memory
000c  0001 0100 0000 0101 0000 0000 0000 0000 		sin a0

0010  0000 0000 0000 0101 0000 0010 1001 0011 		mv t0, a0	# Pointer to text
0014  0000 0000 0000 0000 0000 0011 0001 0011 		li t1, 0	# Counter 
                                              loop:
0018  0000 0000 0000 0010 1100 0011 1000 0011 		lbu t2, 0(t0)
001c  0000 0000 0000 0011 1000 1000 0110 0011 		beqz t2, done

0020  0000 0000 0001 0011 0000 0011 0001 0011 		addi t1, t1, 1
0024  0000 0000 0001 0010 1000 0010 1001 0011 		addi t0, t0, 1
0028  1111 1111 0001 1111 1111 0000 0110 1111 		j loop

                                              done:
002c  1111 1111 1111 0011 0000 0011 0001 0011 		addi t1, t1, -1
0030  0000 0100 0000 0011 0000 0000 0000 0000 		dout t1
0034  0000 0000 0000 0000 0000 0000 0000 0000 		halt

                                              .data
0038  0110 1001 0111 0010 0111 0100 0101 0011 prompt:		.asciz "String please: "
003c  0111 0000 0010 0000 0110 0111 0110 1110 
0040  0111 0011 0110 0001 0110 0101 0110 1100 
0044  0000 0000 0010 0000 0011 1010 0110 0101 
======================================================= Output
String please: 
0
=========================================== Program statistics
Input file name       = stringlen.a
Instructions executed = 16 (decimal)
Program size          = 48 (hex) 72 (decimal)
Load point            = 0 (hex) 0 (decimal)
Programmer            = Scot W. Stevenson
