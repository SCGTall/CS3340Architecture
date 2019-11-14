##############################################################################
# Program : MindReader	Programmer: Chaoran Li, Jiaer JIang, Xue Cheng, Pengfei Tong
# Due Date: 12/05/19	Last Modified:11/08/19
# Course: CS3340	Section:501
#############################################################################
# Description:
# 
# Topic:
# The topic for the team project this semester is the Mind Reader game. 
# For a feel of the game visit   
# https://www.mathsisfun.com/games/mind-reader.html
# 
# Minimum requirements for the program:
# The game is for a human player and your program is the 'mind reader'. Your program must display the
# cards, get input from the player then correctly display the number that the player has in mind.
# At the end of a game, the program will ask the player if he/she wants to play another game and then
# repeat or end the program. 
# The 'cards' MUST be generated and displayed once at a time during a game, i.e. NOT pre-calculated
# and stored in memory. The order of displayed cards MUST be random. 
# The player input (keystrokes) should be minimum
# The ASCII based display is the minimum requirement. Creative ways to display the game (e.g. colors)
#  will earn the team extra credits.
# If the player gives an invalid input, an error message is displayed to explain why the input was not valid. 
# 
# Extra credits will be given for:
# Graphic/color display
# Extra features of the programs (e.g. background music, sounds or music to indicate invalid input,
# pleasant display etc...) implemented and documented.
# Any other notable creativity that the team has shown.
# You must document these extra credit features in your report and explain well to unlock these extra
# credits.
# 
# Design:
# Print: Two loop to traverse to print
# Calculate: Get higher unit first. Return 0 if out of range.
# 
# Log:
# version 1.0	10/04/19		Design the interaction flow
# version 1.1	10/05/19		Print card and calculate result
# version 1.2	10/09/19		If think about number out of 1~63, return 0
# version 1.3	11/08/19		Imply shuffle function
# 
#############################################################################
# Register:
# global
# $v0	for I/O
# $a0	for I/O
# $a1	for I/O
# $s0	'y'
# $s1	'n'
# $s2	max digit
# $s3	line feed every x numbers
# $s4	random factor: a random number to decide current digit for card is 0 or 1
# #s5	card length
# $t0	digit left, show result when $t0 is 0
# $t1	result
# $t2	input, 1 for y and 0 for n
# $t3	current digit
# $t4	valid random sequence (last digit)
# $t8	tmp1
# $t9	tmp2
#
# Truth table:		current digit(card)	answer value	result of xor	final binary expansion		add to result
#						0			0(n)			0				1				1
#						0			1(y)			1				0				0
#						1			0(n)			1				0				0
#						1			1(y)			0				1				1
# if (xor = 0) add to result
#
#############################################################################
		.data
		# messages
start:		.asciiz "\nThink of a number between 1 and 63. Six cards will be displayed and you would tell\nme whether your number is in the card. Once you finish all six cards, I can read your\nmind. Start now?"
hint:		.asciiz "\n(input 'y' or 'n'):\n"
question:	.asciiz "\nDo you find your number here?"
unvalid:	.asciiz "\nThe only valid answer is 'y' or 'n' (lower case). So input correctly.\n"
answer:	.asciiz "\nYour number is "
again:	.asciiz ". Awesome right?\nDo you wanna another try?"
overflow:	.asciiz "\nAll your answer is 'n', which means that your number is not in 1 and 63"
end:		.asciiz "\nGLHF!"
sequence:	.space 24			# digit sequence
card:		.space 128		# at most 
#############################################################################
		.text
		.globl main
		# init
main:	li	$s0, 0x79				# save character 'y'
		li	$s1, 0x6e				# save character 'n'
		li	$s2, 6				# 6 digits binary for 0 ~ 63
		li	$s3, 8				# feed back every 8 numbers when print card
		li	$a1, 64				# random range [0, 64)
		li	$v0, 42
		syscall
		move	$s4, $a0				# random factor: a random 6-bit 0/1 sequence
		li	$s5, 1				# set card length
		sllv	$s5, $s5, $s2			# << 6
		srl	$s5, $s5, 1			# half of 2^6
		# init sequence ( a shuffled sequence to ask question)
		li	$t8, 1				# start with 000001
		move	$t9, $s2				# index = max digit
		sll	$t9, $t9, 2			# index -> address
initSeqL:	beq	$t9, $zero, initSeqE		# break
		addi	$t9, $t9, -4			# address -= 4
		sw	$t8, sequence($t9)		# save to sequence[index]
		sll	$t8, $t8, 1			# <<1
		j	initSeqL
initSeqE:	addi	$sp, $sp, -8			# save $s0-s1
		sw	$s0, 0($sp)
		sw	$s1, 4($sp)
		la	$s0, sequence
		move	$s1, $s2
		jal	shuffle				# shuffle sequence (length = 6 (* 4))
		lw	$s0, 0($sp)
		lw	$s1, 4($sp)
		addi	$sp, $sp, 8			# restore
		# get start
		li	$t1, 0				# set result to 0
		move	$t0, $s2				# digits left
		li	$v0, 4				# print message start
		la	$a0, start				# load address
		syscall
		li	$v0, 4				# print message hint
		la	$a0, hint
		syscall
		jal	input					# get an input
		beq	$t2, $zero, exit			# input, 1 for y and 0 for n
		# main loop: print card and ask question
loop:		beq	$t0, $zero, show		# if 0 digit left, show reslut. Get highter digit first for similicity
		sll	$t8, $t0, 2
		addi	$t8, $t8, -4			# index -> address
		lw	$t3, sequence($t8)		# current digit = sequence[index]
		move	$t4, $s4
		srl	$s4, $s4, 1			# random sequence >>
		andi	$t4, $t4, 1			# get valid random sequence (lasr digit)
		# write card
		addi	$sp, $sp, -8			# save $s0-s1
		sw 	$s0, 0($sp)
		sw	$s1, 4($sp)
		move	$s0, $t3
		move	$s1, $t4
		jal	wCard				# write card
		lw 	$s0, 0($sp)
		lw	$s1, 4($sp)
		addi	$sp, $sp, 8			# restore
		# shuffle card
		addi	$sp, $sp, -8			# save $s0-s1
		sw	$s0, 0($sp)
		sw	$s1, 4($sp)			# $s2 is same and const in Callee
		la	$s0, card
		move	$s1, $s5				# length -> address
		jal	shuffle				# shuffle card (length = 2^6/2 (* 4) = 2^7)
		lw	$s0, 0($sp)
		lw	$s1, 4($sp)
		addi	$sp, $sp, 8			# restore
		# print card
		addi	$sp, $sp, -12			# save $s0-s2
		sw	$s0, 0($sp)
		sw	$s1, 4($sp)
		sw	$s2, 8($sp)
		la	$s0, card
		move	$s1, $s5				# length
		move	$s2, $s3				# feed back value
		jal	pCard				# print card
		lw	$s0, 0($sp)
		lw	$s1, 4($sp)
		lw	$s2, 8($sp)
		addi	$sp, $sp, 12			# restore
		li	$v0, 4				# print question
		la	$a0, question
		syscall
		li	$v0, 4				# print hint
		la	$a0, hint
		syscall
		# get result from input
		jal	input					# get an input
		xor	$t2, $t2, $t4			# xor
		bne	$t2, $zero, skipAdd		# != 0 skip add
		add	$t1, $t1, $t3			# result += input
skipAdd:	addi	$t0, $t0, -1			# digit left--
		j	loop
show:	beq	$t1, $zero, overF		# if answer is 0, overflow
		li	$v0, 4				# print answer
		la	$a0, answer
		syscall
		li	$v0, 1				# print result
		addi	$a0, $t1, 0			# set $a0 to result
		syscall
doAgain:	li	$v0, 4				# print again
		la	$a0, again
		syscall
		li	$v0, 4				# print hint
		la	$a0, hint
		syscall
		
		jal	input
		beq	$t2, $zero, exit
		j	main
overF:	li	$v0, 4				# print overflow
		la	$a0, overflow
		syscall
		j	doAgain
input:	li	$v0, 12				# input a character
		syscall
		# check input validity
		beq	$v0, $s0, branchY		# input is y
		beq	$v0, $s1, branchN		# input is n
		li	$v0, 4				# print unvalid
		la	$a0, unvalid
		syscall
		j	input
branchY:	li	$t2, 1				# set $t2 to 1 if input is y
		jr	$ra
branchN:	li	$t2, 0				# set $t2 to 0 if input is n
		jr	$ra
		# write card
		# $s0	current digit (Caller)
		# $s1	valid random expansion (Caller)
		# $s2	max digit (same as Caller)
		# $t0	digit
		# $t1	upper count
		# $t2	lower count
		# $t3	upper end
		# $t4	lower end
		# $t5	shamt
		# $t6	number
		# $t7	address in card
		# $t8	card length
		# $t9	tmp
wCard:	addi	$sp, $sp, -40			# save $t0-$t9
		sw	$t0, 0($sp)
		sw	$t1, 4($sp)
		sw	$t2, 8($sp)
		sw	$t3, 12($sp)
		sw	$t4, 16($sp)
		sw	$t5, 20($sp)
		sw	$t6, 24($sp)
		sw	$t7, 28($sp)
		sw	$t8, 32($sp)
		sw	$t9, 36($sp)
		li	$t0, 0				# get digit
		move	$t9, $s0		
digitL:	beq	$t9, $zero, digitE
		addi	$t0, $t0, 1			# digit++
		srl	$t9, $t9, 1			# $t8 >> 1
		j	digitL
digitE:	li	$t1, 0				# upper count
		li	$t2, 0				# lower count
		li	$t3, 1				# set upper end
		sub	$t5, $s2, $t0			# << max digit - current digit 
		sllv	$t3, $t3, $t5
		li	$t4, 1				# set lower end
		addi	$t5, $t0, -1			# set shamt for splice number
		sllv	$t4, $t4, $t5			# set upper end
		la	$t7, card				# get memory address
		li	$t8, 1				# set card length
		sllv	$t8, $t8, $s2			# << 6
		srl	$t8, $t8, 1			# half of 2^6
		# traverse
upperL:	beq	$t1, $t3, upperE		# if equal end upper loop
lowerL:	beq	$t2, $t4, lowerE			# if equal end lower loop and start a upper loop
		# print number
		move	$t6, $t1				# number == upper * upper unit + 1 + lower
		sll	$t6, $t6, 1			# << 1
		add	$t6, $t6, $s1			# + valid binary expansion
		sllv	$t6, $t6, $t5			# << until 6 digit
		add	$t6, $t6, $t2
		sw	$t6, 0($t7)			# save in card
		addi	$t7, $t7, 4			# addr += 4
		addi	$t2, $t2, 1			# lower count++
		j	lowerL
lowerE:	addi	$t1, $t1, 1			# upper count++
		li	$t2, 0				# set lower count to 0
		j	upperL			
upperE:	lw	$t0, 0($sp)
		lw	$t1, 4($sp)
		lw	$t2, 8($sp)
		lw	$t3, 12($sp)
		lw	$t4, 16($sp)
		lw	$t5, 20($sp)
		lw	$t6, 24($sp)
		lw	$t7, 28($sp)
		lw	$t8, 32($sp)
		lw	$t9, 36($sp)
		addi	$sp, $sp, 40			#restore
		jr	$ra
		# print card
		# $s0	start address (Caller)
		# $s1	length (Caller)
		# $s2	feed back value
		# $t0	index
		# $t1	address
		# $t2	feed back index
		# $t3	number
pCard:	addi	$sp, $sp, -16			# save $t0-t3
		sw	$t0, 0($sp)
		sw	$t1, 4($sp)
		sw	$t2, 8($sp)
		sw	$t3, 12($sp)
		li	$t0, 0
		move	$t1, $s0
		li	$t2, 0
printL:	beq	$t0, $s1, printE
		lw	$t3, 0($t1)			# get number from card
		beq	$t3, $zero, afterPrint		# do not print 0
		beq	$t2, $zero, feedBack
		li	$v0, 11				# print \t
		li	$a0, 0x09
		syscall
		j	printNum
feedBack:	li	$v0, 11				# print \n
		li	$a0, 0x0a
		syscall
printNum:	move	$a0, $t3
		li	$v0, 1				# print number
		syscall
		addi	$t2, $t2, 1			# feed back index++
		bne	$t2, $s2, afterPrint
		li	$t2, 0				# reset feed back index
afterPrint:	addi	$t0, $t0, 1			# index++
		addi	$t1, $t1, 4			# address+=4
		j	printL
printE:	lw	$t0, 0($sp)
		lw	$t1, 4($sp)
		lw	$t2, 8($sp)
		lw	$t3, 12($sp)
		addi	$sp, $sp, 16			# restore
		jr	$ra
		# shuffle
		# $s0	start address (Caller)
		# $s1	length(Caller)
		# $t0	break condition
		# $t1	target address
		# $t8	tmp1
		# $t9	tmp2
shuffle:	addi	$sp, $sp, -16			# save $t0-t3
		sw	$t0, 0($sp)
		sw	$t1, 4($sp)
		sw	$t8, 8($sp)
		sw	$t9, 12($sp)
shuffleL:	slt	$t0, $zero, $s1			# 0 < length? 1: 0
		beq	$t0, $zero, shuffleE		# break condition
		move	$a1, $s1				# [0, length)
		li	$v0, 42
		syscall
		sll	$a0, $a0, 2			# * 4
		add	$t1, $s0, $a0			# target address
		lw	$t8, 0($s0)			# swap
		lw	$t9, 0($t1)
		sw	$t9, 0($s0)
		sw	$t8, 0($t1)
		addi	$s0, $s0, 4			# addr += 4
		addi	$s1, $s1, -1			# length--
		j	shuffleL
shuffleE:	lw	$t0, 0($sp)
		lw	$t1, 4($sp)
		lw	$t8, 8($sp)
		lw	$t9, 12($sp)
		addi	$sp, $sp, 16			# restore
		jr	$ra
		# exit
exit:		li	$v0, 4				# print end
		la	$a0, end
		syscall
