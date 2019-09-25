rv Version 3.2                        Wed Sep 25 22:52:13 2019
Scot W. Stevenson

Header
R
T 00000000
S 00000000
A 00000130
A 00000138
A 00000140
A 00000148
A 00000150
D 000002f8
C

Loc         Instruction in Binary                   Source Code
                                              # Command loop / jump table experiment 
                                              # Scot W. Stevenson <scot.stevenson@gmail.com>
                                              # First version: 25. Sep 2019
                                              # This version: 25. Sep 2019

                                              # Command loop that accepts a character and uses 
                                              # jump table for a subrountine. This is an experi
                                              # possible ed clone.

                                              .text
                                              _start:
                                              main_loop:
                                              		# Print welcome string
0000  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_welcome
0004  0000 1111 1100 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0008  0000 1100 0000 0010 1000 0000 0000 0000 		sout t0
000c  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, buffer
0010  0001 0100 1100 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0014  0001 0100 0000 0010 1000 0000 0000 0000 		sin t0

                                              		# We just examine the first character at this p
                                              		# we figure out how to parse the whole string. 
                                              		# use a0 because parts of this later will be
                                              		# handled by subroutine
0018  1110 0110 0000 0001 1100 0101 0000 0011 		lbu a0, buffer		# get char from input
001c  0000 0000 0000 0000 0000 0011 0001 0111 		la t1, cmd_tbl		# initalize pointer to the jump
0020  0001 0001 0000 0011 0000 0011 0001 0011 		# addi (2nd inst in la seq)

                                              inner_loop:
0024  0000 0000 0000 0011 0100 0010 1000 0011 		lbu t0, 0(t1)		# Get command character from tab
0028  0000 0110 0000 0010 1000 0010 0110 0011 		beqz t0, error  	# End of the list of known com
002c  0000 0000 1010 0010 1000 0110 0110 0011 		beq t0, a0, found	# No. Found a match?
0030  0000 0000 1000 0011 0000 0011 0001 0011 		addi t1, t1, 8		# No. Next entry in command tab
0034  1111 1111 0001 1111 1111 0000 0110 1111 		j inner_loop

                                              found:
0038  0000 0000 0100 0011 0010 0011 1000 0011 		lw t2, 4(t1)		# jump address comes after char
003c  0000 0000 0000 0011 1000 0000 0110 0111 		jr t2			# Execute the command routine
0040  1111 1100 0001 1111 1111 0000 0110 1111 		j main_loop

                                              # --- Command routines ---

                                              i_add:
0044  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_add
0048  0000 0101 1000 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
004c  0000 0011 1000 0000 0000 0000 0110 1111 		j common_out
                                              i_delete:
0050  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_delete
0054  0000 0110 0100 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0058  0000 0010 1100 0000 0000 0000 0110 1111 		j common_out
                                              i_insert:
005c  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_insert
0060  0000 0111 1000 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0064  0000 0010 0000 0000 0000 0000 0110 1111 		j common_out
                                              i_write:
0068  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_write
006c  0000 1010 1000 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0070  0000 0001 0100 0000 0000 0000 0110 1111 		j common_out 

                                              i_quit:		
0074  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_quit
0078  0000 0111 1100 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
007c  0000 1100 0000 0010 1000 0000 0000 0000 		sout t0
0080  0000 0000 0000 0000 0000 0000 0000 0000 		halt

                                              common_out:
0084  0000 1100 0000 0010 1000 0000 0000 0000 		sout t0
0088  0000 0000 0000 0000 1000 0000 0110 0111 		ret

                                              # --- Error handling ---

                                              error:
                                              		# We follow the ed convention of only having a 
008c  0000 0000 0000 0000 0000 0010 1001 0111 		la t0, s_error
0090  0000 0100 0100 0010 1000 0010 1001 0011 		# addi (2nd inst in la seq)
0094  0000 1100 0000 0010 1000 0000 0000 0000 		sout t0
0098  1111 0110 1001 1111 1111 0000 0110 1111 		j main_loop

                                              .data
                                              # --- Data ---

009c  0110 0011 0110 0001 0110 0101 0101 0010 s_add:		.asciz "Reached add subroutine\n"
00a0  0010 0000 0110 0100 0110 0101 0110 1000 
00a4  0010 0000 0110 0100 0110 0100 0110 0001 
00a8  0111 0010 0110 0010 0111 0101 0111 0011 
00ac  0110 1001 0111 0100 0111 0101 0110 1111 
00b0  0000 0000 0000 1010 0110 0101 0110 1110 
00b4  0110 0011 0110 0001 0110 0101 0101 0010 s_delete:	.asciz "Reached delete subroutine\n"
00b8  0010 0000 0110 0100 0110 0101 0110 1000 
00bc  0110 0101 0110 1100 0110 0101 0110 0100 
00c0  0111 0011 0010 0000 0110 0101 0111 0100 
00c4  0110 1111 0111 0010 0110 0010 0111 0101 
00c8  0110 1110 0110 1001 0111 0100 0111 0101 
00cc  0000 0000 0000 0000 0000 1010 0110 0101 
00d0  0000 0000 0000 0000 0000 1010 0011 1111 s_error:	.asciz "?\n"
00d4  0110 0011 0110 0001 0110 0101 0101 0010 s_insert:	.asciz "Reached insert subroutine\n"
00d8  0010 0000 0110 0100 0110 0101 0110 1000 
00dc  0110 0101 0111 0011 0110 1110 0110 1001 
00e0  0111 0011 0010 0000 0111 0100 0111 0010 
00e4  0110 1111 0111 0010 0110 0010 0111 0101 
00e8  0110 1110 0110 1001 0111 0100 0111 0101 
00ec  0000 0000 0000 0000 0000 1010 0110 0101 
00f0  0110 0100 0110 1111 0110 1111 0100 0111 s_quit:		.asciz "Goodbye\n"
00f4  0000 1010 0110 0101 0111 1001 0110 0010 
00f8  0000 0000 0000 0000 0000 0000 0000 0000 
00fc  0110 0101 0111 0100 0110 1110 0100 0101 s_welcome:	.asciz "Enter a character: "
0100  0010 0000 0110 0001 0010 0000 0111 0010 
0104  0111 0010 0110 0001 0110 1000 0110 0011 
0108  0110 0101 0111 0100 0110 0011 0110 0001 
010c  0000 0000 0010 0000 0011 1010 0111 0010 
0110  0110 0011 0110 0001 0110 0101 0101 0010 s_write:	.asciz "Reached write subroutine\n"
0114  0010 0000 0110 0100 0110 0101 0110 1000 
0118  0111 0100 0110 1001 0111 0010 0111 0111 
011c  0111 0101 0111 0011 0010 0000 0110 0101 
0120  0111 0101 0110 1111 0111 0010 0110 0010 
0124  0110 0101 0110 1110 0110 1001 0111 0100 
0128  0000 0000 0000 0000 0000 0000 0000 1010 

012c  0000 0000 0000 0000 0000 0000 0110 0001 cmd_tbl:	.word 'a', i_add
0130  0000 0000 0000 0000 0000 0000 0100 0100 
0134  0000 0000 0000 0000 0000 0000 0110 0100 		.word 'd', i_delete
0138  0000 0000 0000 0000 0000 0000 0101 0000 
013c  0000 0000 0000 0000 0000 0000 0110 1001 		.word 'i', i_insert
0140  0000 0000 0000 0000 0000 0000 0101 1100 
0144  0000 0000 0000 0000 0000 0000 0111 0111 		.word 'w', i_write
0148  0000 0000 0000 0000 0000 0000 0110 1000 
014c  0000 0000 0000 0000 0000 0000 0111 0001 		.word 'q', i_quit
0150  0000 0000 0000 0000 0000 0000 0111 0100 
0154  0000 0000 0000 0000 0000 0000 0000 0000 		.word 0

0158  0000 0000 0000 0000 0000 0000 0000 0000 buffer:		.zero 1024
0554  0000 0000 0000 0000 0000 0000 0000 0000 
======================================================= Output
Enter a character: u
?
Enter a character: a
Reached add subroutine
Enter a character: q
Goodbye

=========================================== Program statistics
Input file name       = jumptable01.a
Instructions executed = 97 (decimal)
Program size          = 558 (hex) 1368 (decimal)
Load point            = 0 (hex) 0 (decimal)
Programmer            = Scot W. Stevenson
