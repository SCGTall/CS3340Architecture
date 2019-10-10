##############################################################################
# Program : MindReader	Programmer: Chaoran Li, Jiaer JIang, Xue Cheng, Pengfei Tong
# Due Date: 12/05/19	Last Modified:10/04/19
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
# 
#############################################################################
# Register:
# global
# $v0	for I/O
# $a0	for I/O
# $s0	'y'
# $s1	'n'
# $s2	max digit
# $33	line feed every x numbers
# $t0	digit, 1~$s2
# $t1	result
# $t2	input, 1 for y and 0 for n
# $t3	pointer for card
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
card:		# set at the end of .data to make sure no overflow
#############################################################################
		.text
		.globl main
main:	# init
		li	$s0, 0x79				# save character 'y'
		li	$s1, 0x6e				# save character 'n'
		li	$s2, 6				# 6 digits binary for 0 ~ 63
		li	$s3, 8				# feed back every 8 numbers when print card
		li	$t1, 0				# set result to 0
		addi	$t0, $s2, 0			# start from highest digit
		# get start
		li	$v0, 4				# print message start
		la	$a0, start				# load address
		syscall
		li	$v0, 4				# print message hint
		la	$a0, hint
		syscall
		
		jal	input					# get an input
		beq	$t2, $zero, exit
		# print card and ask question
loop:		beq	$t0, $zero, show		# if digit == 0, show reslut. Get highter digit first for similicity
		jal	print					# print card
		li	$v0, 4				# print question
		la	$a0, question
		syscall
		li	$v0, 4				# print hint
		la	$a0, hint
		syscall
		jal	input					# get an input
		sll	$t1, $t1, 1			# result << 1
		add	$t1, $t1, $t2			# result += input
		addi	$t0, $t0, -1			# digit--
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
input:	li	$v0, 12				# load a character
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
print:		addi	$sp, $sp, -28			# save $t1-$t7, $t0 is digit
		sw	$t1, 0($sp)
		sw	$t2, 4($sp)
		sw	$t3, 8($sp)
		sw	$t4, 12($sp)
		sw	$t5, 16($sp)
		sw	$t6, 20($sp)
		sw	$t7, 24($sp)
		# init for print
		# $t0	digit
		# $t1	print index
		# $t2	upper count
		# $t3	lower count
		# $t4	upper end
		# $t5	lower end
		# $t6	shamt
		# $t7	number
		li	$t1, 0				# print index, feed back according to $s3
		li	$t2, 0				# upper count
		li	$t3, 0				# lower count
		li	$t4, 1				# set upper end
		sub	$t6, $s2, $t0			# << max digit - current digit 
		sllv	$t4, $t4, $t6
		li	$t5, 1				# set lower end
		addi	$t6, $t0, -1
		sllv	$t5, $t5, $t6
		addi	$t6, $t0, -1			# set shamt for splice number
		# traverse
upperL:	beq	$t2, $t4, upperE		# if equal end upper loop
lowerL:	beq	$t3, $t5, lowerE			# if equal end lower loop and start a upper loop
		# print number
		addi	$t7, $t2, 0			# number == upper * upper unit + 1 + lower
		sll	$t7, $t7, 1
		addi	$t7, $t7, 1
		sllv	$t7, $t7, $t6
		add	$t7, $t7, $t3
		beq	$t7, $zero, notPrint0		# do not print 0
		bne	$t1, $zero, tab			# feed back according to print index
		li	$v0, 11				# print \t
		li	$a0, 0x0a
		j	printN
tab:		li	$v0, 11				# print \n
		li	$a0, 0x09
printN:	syscall					# syscall for print '\r' or '\n'
		addi	$t1, $t1, 1			# print index++
		bne	$t1, $s3, resetE			# reset print index if necessary
		li	$t1, 0
resetE:	li	$v0, 1				# print number
		addi	$a0, $t7, 0
		syscall
notPrint0:	addi	$t3, $t3, 1			# lower count++
		j	lowerL
lowerE:	addi	$t2, $t2, 1			# upper count++
		li	$t3, 0				# set lower count to 0
		j	upperL
upperE:	# restore
		lw	$t1, 0($sp)
		lw	$t2, 4($sp)
		lw	$t3, 8($sp)
		lw	$t4, 12($sp)
		lw	$t5, 16($sp)
		lw	$t6, 20($sp)
		lw	$t7, 24($sp)
		addi	$sp, $sp, 28			#restore $t1~$t7
		jr	$ra
exit:		li	$v0, 4				# print end
		la	$a0, end
		syscall
