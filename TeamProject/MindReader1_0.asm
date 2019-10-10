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
# Log:
# version 1.0	10/04/19		Design the interaction flow
# 
#############################################################################
# Register:
# $v0	for I/O
# $a0	for I/O
# $s0	'y'
# $s1	'n'
# $s2	6 (6 digits)
# $t0	result
# $t1	digit
# $t2	1 for y and 0 for n
# $t3	digit < 6 ? 1 : 0
#############################################################################
		.data
		# messages
start:		.asciiz "Think of a number between 0 and 63. Six cards will be displayed and you would tell\n"
start2:	.asciiz "me whether your number is in the card. Once you finish all six cards, I can read your\n"
start3:	.asciiz "mind. Start now?\n"
hint:		.asciiz "input 'y' or 'n':\n"
question:	.asciiz "Do you find your number here?"
unvalid:	.asciiz "\nThe only valid answer is 'y' or 'n' (lower case). So input correctly.\n"
answer:	.asciiz "\nYour number is "
again:	.asciiz ". Awesome right?\nDo you wanna another try?\n"
end:		.asciiz "\nGLHF!"
test:		.asciiz "\n########"
#############################################################################
		.text
		.globl main
main:	# init
		li	$s0, 0x79				# save character 'y'
		li	$s1, 0x6e				# save character 'n'
		li	$s2, 6				# max digit
		li	$t0, 0				# set result to 0
		li	$t1, 0				# start from last digit
		# get start
		li	$v0, 4				# print message start
		la	$a0, start				# load address
		syscall
		li	$v0, 4				# print message start2
		la	$a0, start2
		syscall
		li	$v0, 4				# print message start3
		la	$a0, start3
		syscall
		li	$v0, 4				# print message hint
		la	$a0, hint
		syscall
		
		jal	input					# get an input
		beq	$t2, $zero, exit
		# print card and ask question
loop:		slt	$t3, $t1, $s2			# digit < 6 ? 1 : 0
		beq	$t3, $zero, show		# if digit >= 6, show reslut
		jal	print					# print card
		li	$v0, 4				# print question
		la	$a0, answer
		syscall
		li	$v0, 4				# print hint
		la	$a0, hint
		syscall
		jal	input					# get an input
		addi	$t1, $t1, 1			# digit++
		j	loop
show:	li	$v0, 4				# print answer
		la	$a0, answer
		syscall
		li	$v0, 1				# print result
		move	$a0, $t0				# set $a0 to result
		syscall
		li	$v0, 4				# print again
		la	$a0, again
		syscall
		li	$v0, 4				# print hint
		la	$a0, hint
		syscall
		
		jal	input
		beq	$t2, $zero, exit
		j	main
input:	li	$v0, 12				# load a character
		syscall
		# check input validity
		beq	$v0, $s0, branchY		# input is y
		beq	$v0, $s1, branchN		# input is n
		li	$v0, 4				# print unvalid
		la	$a0, unvalid
		syscall
		
		j	input
branchY:	li	$t2, 1				# set $s2 to 1 if input is y
		jr	$ra
branchN:	li	$t2, 0				# set $s2 to 0 if input is n
		jr	$ra
print:		li	$v0, 4				# print card
		la	$a0, test
		syscall
		
		jr	$ra
exit:		li	$v0, 4				# print end
		la	$a0, end
		syscall
