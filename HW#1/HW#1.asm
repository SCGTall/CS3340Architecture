##############################################################################
# Program : HW#1	Programmer: Chaoran Li
# Due Date: 09/03/19	Last Modified:09/01/19
# Course: CS3340	Section:501
#############################################################################
# Description:
# Using MARS write a MIPS assembly language program to prompt the user to
# input two 32-bit integers X and Y (X and Y can be prompted separately or
# at the same time), get them from the user then store them in memory
# locations labeled X and Y respectively. The program then loads X and Y
# from the main memory to registers, calculates the sum of them (i.e. X + Y)
# and store the sum into a memory location labeled S. The program then prints
# out the result (i.e. integer S) after printing the string "The sum of X and
# Y (X + Y) is ".
#############################################################################
# Register:
#	$a0	I/O
#	$t4	sum
#	$t5	X
#	$t6	Y
#############################################################################
	.data
msgX:	.asciiz "input a 32-bit integer X: "
msgY:	.asciiz "input a 32-bit integer Y: "
msgSum:	.asciiz "The sum of X and Y (X + Y) is "
	.align 2
X:	.space 4		# 32-bit Integer
Y:	.space 4
S:	.space 4
#############################################################################
	.text
	.globl main
main:
	######################### input X
	li	$v0, 4		# system call to print msgX
	la	$a0 msgX	# load address of msgX
	syscall
		
	li	$v0, 5		# system call code for Read X
	syscall
	
	la	$t0, X		# load address of X
	sw	$v0, X		# store first Integer in X	
	######################### input Y
	li	$v0, 4		# system call to print msgY
	la	$a0 msgY	# load address of msgY
	syscall
		
	li	$v0, 5		# system call code for Read Y
	syscall
	
	la	$t1, Y		# load address of Y
	sw	$v0, Y		# store second Integer in Y
	######################### do add
	lw	$t5, X		# load X into register $t5
	lw	$t6, Y		# load Y into register $t6	
	add	$t4, $t5, $t6	# add $t5 and $t6 to $t4
	sw	$t4, S		# store sum to S
	######################### print
	li	$v0, 4		# system call to print msgSum
	la	$a0, msgSum	# load address of msgSum
	syscall
	
	li	$v0, 1		# system call to print an Integer
	lw	$a0, S		# load S into register $a0
	syscall