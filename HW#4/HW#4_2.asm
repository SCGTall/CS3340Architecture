##############################################################################
# Program : HW#4_2	Programmer: Chaoran Li
# Due Date: 10/15/19	Last Modified:10/15/19
# Course: CS3340	Section:501
#############################################################################
# Description:
#  Write a MIPS assembly language program that
#
# a. prompts the user for a zip code (as a 5-digits unsigned integer, or 0) with the string "Give me your
# zip code (0 to stop): ". No error checking is necessary, assuming that the user will give correct numbers.
#
# b. if the input is 0 stops
# 
# c. otherwise, display the leading string  "The sum of all digits in your zip code is", calculate the sum of
# all digits by calling two functions (see below) one at a time and then display the result with the leading
# string "ITERATIVE:"  for the iterative version, and "RECURSIVE:"  for the recursive version of the function.
#
# d. repeats from a.
# 
# For example, if the user gave the input 75081 the program will print out 
# 
# The sum of all digits in your zip code is
# ITERATIVE: 21
# RECURSIVE: 21
# 
# This program should make use of a function that calculates and returns the sum of digits in the input
# argument zip. Implement two versions of this function, one is iterative (named int_digits_sum)  and the
# other is recursive (named rec_digits_sum). The main program should call each of these two functions to
# calculate and then display the sum after the user has input a ZIP code. 
#############################################################################
# Register:
#	$a0		I/O
#	#s0		store input
#	$s1		store iterative result
#	$s2		store recursive result
#	$t8		reserve argument for recursive
#	iterative
#	$t0		5 digit in zip code
#	$t1		index
#	$t2		dividend
#	$t3		10 (divisor)
#	$t4		remainder
#	recursive
#	$t0		dividend
#	$t1		sum
#	$t2		10 (divisor)
#	$t3		remainder
#
#############################################################################
		.data
array	:	.space 404				#  array (101 * 4)
msgIn:	.asciiz "Give me your zip code (0 to stop): "
msgOut1:	.asciiz "\nThe sum of all digits in your zip code is\nITERATIVE: "
msgOut2:	.asciiz "\nRECURSIVE: "
#############################################################################
		.text
		.globl main
main:	# input zip code
		li	$v0, 4			# print msgIn
		la	$a0 msgIn
		syscall
		
		li	$v0, 5			# system call code for read input
		syscall
		# exit if input is 0
		beq	$v0, $zero, exit		# if equals to 0, then exit
		add	$s0, $zero, $v0		# save input
		# iterative
		li	$s1, 0
		jal	iter
		
		# recusive
		addi	$sp, $sp, -16
		sw 	$t0, 0($sp)		# save former $t0-t3
		sw	$t1, 4($sp)
		sw	$t2, 8($sp)
		sw	$t3, 12($sp)
		add	$t0, $zero, $s0		# set dividend
		li	$t1, 0			# set sum to 0
		li	$t2, 10			# decimal
		addi	$sp, $sp, -16
		sw 	$t0, 0($sp)		# save $t0-t3
		sw	$t1, 4($sp)
		sw	$t3, 8($sp)		# $t2 do not change
		sw	$ra, 12($sp)
		jal	recu
		lw 	$s2, 4($sp)		# save sum to $t2
		addi	$sp, $sp, 16
		lw	$t0, 0($sp)		# restore
		lw	$t1, 4($sp)
		lw	$t2, 8($sp)
		lw	$t3, 12($sp)
		addi	$sp, $sp, 16
		# print
		j	print
iter:		# iterative
		addi	$sp, $sp, -24		# save $t0-$t5
		sw	$t0, 0($sp)
		sw	$t1, 4($sp)
		sw	$t2, 8($sp)
		sw	$t3, 12($sp)
		sw	$t4, 16($sp)
		sw	$t5,	20($sp)
		
		li	$t0, 5			# 5 digits in zip code
		li	$t1, 0			# index
		add	$t2, $zero, $s0		# dividend
		li	$t3, 10			# divisor
loopIter:	beq	$t1, $t0, endLI
		div	$t2, $t3			# $t2 / $t3 = LO * $t3 + HI
		mfhi	$t4
		add	$t5, $t5, $t4		# $s1 += remainder
		mflo	$t2				# $t2 = quotient
		addi	$t1, $t1, 1		# index++
		j	loopIter
endLI	:	add	$s1, $zero, $t5		# save sum to $s1
		lw	$t0, 0($sp)		# restore
		lw	$t1, 4($sp)
		lw	$t2, 8($sp)
		lw	$t3, 12($sp)
		lw	$t4, 16($sp)
		lw	$t5, 20($sp)
		addi	$sp, $sp, 24
		jr	$ra
recu:		# recursive
		div	$t0, $t2			# $t0 / $t2 = LO * $t2 + HI
		mfhi	$t3
		mflo	$t0				# dividend = quotient
		sw	$t0, 0($sp)
		
		addi	$sp, $sp, -16		# save $t0, t1, t3
		sw	$t0, 0($sp)
		sw	$t1, 4($sp)
		sw	$t3, 8($sp)		# $t2 do not change
		sw	$ra, 12($sp)
		beq	$t0, $zero, nagt
		jal	recu
nagt:		lw	$t1, 4($sp)		# reload
		lw	$t3, 8($sp)
		lw	$ra, 12($sp)
		addi	$sp, $sp, 16
		add	$t1, $t1, $t3		# $t1 += remainder
		sw	$t1, 4($sp)
		jr	$ra
print:		# print result
		li	$v0, 4			# print msgOut1
		la	$a0, msgOut1
		syscall
		
		li	$v0, 1			# print itertive result
		move	$a0, $s1
		syscall
		
		li	$v0, 4			# print msgOut2
		la	$a0, 	msgOut2
		syscall
		
		li	$v0, 1			# print recursive result
		move	$a0, $s2
		syscall
exit:		# end if input is 0
