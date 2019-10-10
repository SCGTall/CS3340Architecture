##############################################################################
# Program : HW#3_2	Programmer: Chaoran Li
# Due Date: 09/24/19	Last Modified:09/19/19
# Course: CS3340	Section:501
#############################################################################
# Description:
# Write a MIPS assembly language program that does the followings:
# a) Prompt the user for an integer in the range of 0 to 100. If the user inputs 0 the program stops.
# b) Otherwise, the program stores the numbers from 0 up to the input value into an array of words
# in memory, i.e. initializes the array with values from 0 up to N where N is the value that user has given.
# c) The program then adds the value of all even numbers of the array together (up to N) by loading them
# from the main memory then add them up, then prints out the sum with the message "The sum of even
# integers from 0 to N is:". For example, if the user gave 6 as the input the program prints out "The sum
# of even integers from 0 to 6 is 12".
#############################################################################
# Register:
#	$a0	I/O
#	$t0	store input
#	$t1	number
#	$t2	compare index < input ? 1 : 0
#	$t3	memory address iterator
#	$t4	sum
#	$t5	compare number < 0 ? 1 : 0
#############################################################################
		.data
array	:	.space 404				#  array (101 * 4)
msgIn:	.asciiz "input a 0 - 100 integer : "
msgSum1:	.asciiz "The sum of even integers from 0 to "
msgSum2: .asciiz " is "
#############################################################################
		.text
		.globl main
main:	# input 0 - 100
		li	$v0, 4			# system call to print msgIn
		la	$a0 msgIn			# load address of msgIn
		syscall
		
		li	$v0, 5			# system call code for read input
		syscall
		# ? == 0
		beq	$v0, $zero, exit		# if equals to 0, then exit
		slt	$t5, $v0, $zero		# input < 0 ? 1 : 0 
		bne	$t5, $zero, exit		# if number < 0, exit (these two lines deal with input < 0, maybe unnecessary)
		add	$t0, $zero, $v0		# store input
		
		# init register for store number
		addi	$t1, $zero, 0		# init $t1 number
		la	$t3, array			# init $t3 iterator
		# save 0 up to X into Array
loop1:	sw	$t1, 0($t3)		# save number to iterator
		addi	$t1, $t1, 1		# number++
		addi	$t3, $t3, 4		# get next address
		slt	$t2, $t1, $t0		# number < input  ? 1 : 0
		beq	$t1, 100, finally1	# prevent overflow
		bne	$t2, $zero, loop1	# if not 0, goto loop1
		# add last
finally1:	sw	$t1, 0($t3)		# save last number
		
		# init register for calculate sum
		la	$t3, array			# init $t3 iterator
		addi	$t4, $zero, 0		# init $t4 sum
		# get sum
loop2:	lb	$t1, 0($t3)		# load even number from iterator
		add	$t4, $t4, $t1		# add even interger to sum
		addi	$t3, $t3, 8		# interval is 8
		addi	$t1, $t1, 2		# number + 1 for odd input
		slt	$t2, $t1, $t0		# number + 1 < input ? 1 : 0
		beq	$t1, 100, finally2	# prevent overflow
		bne	$t2, $zero, loop2	# if not 0, goto loop2
		# add last
finally2:	lb	$t1, 0($t3)		# load last even number
		add	$t4, $t4, $t1		# add last even number
		
		# print sum
		li	$v0, 4			# system call to print msgSum1
		la	$a0, msgSum1		# load address of msgSum1
		syscall
		
		li	$v0, 1			# system call to print input between two messages
		move	$a0, $t1			# set input to print
		syscall
		
		li	$v0, 4			# system call to print msgSum2
		la	$a0, 	msgSum2		# load address of msgSum2
		syscall
		
		li	$v0, 1			# system call to print sum
		move	$a0, $t4			# set sum to print
		syscall
exit:		# end if input is 0
