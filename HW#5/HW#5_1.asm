##############################################################################
# Program : HW#5_1	Programmer: Chaoran Li
# Due Date: 11/04/19	Last Modified:11/06/19
# Course: CS3340	Section:501
#############################################################################
# Description:
#  Write a MIPS assembly language program that
#
# Joe is running a take-out pizza shop Pizza-R-US that sells 8" round (circle)  and 10" square pizzas.
# Write a MIPS assembly language program to help him to calculate the total square foot of pizzas he has
# sold during a day.
#
# The program:
#
# 1.  a) prompts Joe for the number of round and square pizzas sold in a day. Obviously, the program
# must ask Joe to input two integer numbers: the number of circle piazza and the number of square pizza
# sold.
#
#      b) prompts Joe for his estimate of total pizzas sold in that day in square feet (a floating point number).
#
# 2. calculates the total pizza sold in square feet for each type (circle and square) and for both types.
#
# 3.  a) prints out the calculation results such that Joe would know a) the total number of square feet of
# pizza sold, b) the total number of square feet of round pizzas, and c) the total number of square feet
# of square piazzas. 
#
#     b) prints the message "Yeah!" if the total pizzas sold is greater than Joe's estimate (from 1.b),
# otherwise prints "Bummer!". 
#
# Note: single precision floating point arithmetic must be used for round piazzas but integer arithmetic
# should be used for square piazzas (except the last step when converting the total square inches to
# square feet), and floating point comparison must be used for 3.b).
#
# Details: 
# 1. According to my survey about the size of pizza on the Internet, for 8" circle pizza, 8" is its
# diameter. For 10" square pizza, 10" is its edge length.
# 2. For this case, if the integer for the total square feet for square pizzas is larger than 32-bit, I will use
# the formula : total square feet = number * 100 to calculate and print.
#############################################################################
# Register:
#	$s0	area of one square pizza (integer) diagonal length = 10
#	$t0	input circle pizza number
#	$t1	input squre pizza number
#	$t2	total number of square feet of all square pizzas
#	$t3	tmp number
# Co-processor1:
#	$f16	Joe's estimate of total area
#	$f18	area of one circle pizza (single) diameter = 8
#	$f20	pi = 3.14159
#	$f22	4.0
#	$f24	total number of square feet of all circle pizzas
#	$f26	total number of square feet of all square pizzas
#	$f28	total number of square feet of all pizzas
#	$f30	tmp FP
#
#############################################################################
		.data
msgIn1:	.asciiz "\nHello Joe, how is your day? Tell me how many circle pizzas have you sold today?"
msgIn2:	.asciiz "\n(Input an integer): "
msgIn3:	.asciiz "\nHow about square pizzas?"
msgIn4:	.asciiz "\nOK. Then how many square inches of pizza do you thing you sold today?"
msgIn5:	.asciiz "\n(Input a single floating point): "
msgOut1:	.asciiz "\nTotal number of square feet of all circle pizzas:\n"
msgOut2:	.asciiz "\nTotal number of square feet of all square pizzas:\n"
msgOut3:	.asciiz "\nTotal number of square feet of all pizzas:\n"
msgOut4:	.asciiz "\nYeah!"
msgOut5:	.asciiz "\nBummer!"
suffix00:	.asciiz "00"
pi:		.float 3.14159
#############################################################################
		.text
		.globl main
main:	# init saved register
		li	$s0, 10			# diagonal length = 10
		mul	$s0, $s0, $s0		# 10 * 10
		li	$t3,	8
		mtc1	$t3, $f18	 		
		cvt.s.w	$f18, $f18	# diameter = 8
		mul.s	$f18, $f18, $f18
		li	$t3, 4
		mtc1	$t3, $f22
		cvt.s.w	$f22, $f22	# 4.0
		div.s	$f18, $f18, $f22
		lwc1	$f20, pi			# pi
		mul.s	$f18, $f18, $f20	# 8 * 8 / 4 * pi
		# prompt for input
		li	$v0, 4
		la	$a0, msgIn1
		syscall
		li	$v0, 4
		la	$a0, msgIn2
		syscall
		li	$v0, 5			# get number of circle pizzas
		syscall
		move	$t0, $v0
		li	$v0, 4
		la	$a0, msgIn3
		syscall
		li	$v0, 4
		la	$a0, msgIn2
		syscall
		li	$v0, 5			# get number of square pizzas
		syscall
		move	$t1, $v0
		li	$v0, 4
		la	$a0, msgIn4
		syscall
		li	$v0, 4
		la	$a0, msgIn5
		syscall
		li	$v0, 6			# get estimate of total square feet
		syscall
		mov.s	$f16, $f0
		# calculate total square feet of circle pizza and print
		mtc1	$t0, $f30
		cvt.s.w	$f30, $f30	# get circle pizza number
		mul.s	$f24, $f18, $f30	# total square feet of circle pizzas
		li	$v0, 4
		la	$a0, msgOut1
		syscall
		li	$v0, 2			# print
		mov.s	$f12, $f24
		syscall
		# calculate total square feet of square pizza and print
		mult	$t1, $s0			# total square feet of square pizzas
		mfhi	$t3
		bne	$t3, $zero, bigInt	# if integer is too big
		li	$v0, 4
		la	$a0, msgOut2
		syscall
		mflo	$a0				# print LO
		li	$v0, 1
		syscall
		# calculate total square feet of all pizza and print
		mtc1	$a0, $f26
		cvt.s.w	$f26, $f26	# total square feet of square pizzas (single)
		j	total
bigInt:	# if integer larger than 32-bit (number * 100)
		li	$v0, 4
		la	$a0, msgOut2
		syscall
		move	$a0, $t1
		li	$v0, 1			# print number
		syscall
		mtc1	$a0, $f26
		cvt.s.w	$f26, $f26	# total square feet of square pizzas (single)
		li	$v0, 4
		la	$a0, suffix00		# print 00
		syscall
		li	$t3, 100
		mtc1	$t3, $f30
		cvt.s.w	$f30, $f30	# 100
		mul.s	$f26, $f26, $f30
total:		add.s	$f28, $f24, $f26	# total square feet of all pizzas
		li	$v0, 4
		la	$a0, msgOut3
		syscall
		li	$v0, 2			# print
		mov.s	$f12, $f28
		syscall
compare:	# compare and print yeah or bummer
		c.le.s	$f16, $f28		# compare with Joe;s estimate
		bc1t	yeah
		li	$v0, 4			# print bummer
		la	$a0, msgOut5
		syscall
		j	exit
yeah:		li	$v0, 4			# print yeah
		la	$a0, msgOut4
		syscall
exit:		# exit	
		
		
		
		
