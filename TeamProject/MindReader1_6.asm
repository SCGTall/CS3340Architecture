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
# version 1.4	12/02/19		Add functions about Bitmaps
# version 1.5	12/02/19		Final improvement about music and flow path.
# version 1.6	12/02/19		Disable $s4 for logical confusion in overflow design
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
# $t0		digit left, show result when $t0 is 0
# $t1		result
# $t2		input, 1 for y and 0 for n
# $t3		current digit
# $t4		valid random sequence (last digit)
# $t8		tmp1
# $t9		tmp2
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
sequence:	.space 24			# digit sequence
card:		.space 128		# at most 
		# messages
start:		.asciiz "\nThink of a number between 1 and 63. Six cards will be displayed and you would tell\nme whether your number is in the card. Once you finish all six cards, I can read your\nmind. Start now?"
hint:		.asciiz "\n(input 'y' or 'n'):\n"
question:	.asciiz "\nDo you find your number here?"
unvalid:	.asciiz "\nThe only valid answer is 'y' or 'n' (lower case). So input correctly.\n"
answer:	.asciiz "\nYour number is "
again:	.asciiz ". Awesome right?\nDo you wanna another try?"
overflow:	.asciiz "\nYou are so cute! I think your number is not in 1 and 63"
end:		.asciiz "\nGame over. GLHF!"
pictStart:	.asciiz "Resource/P01.png"
pictStart2:	.asciiz "Resource/P02.png"
pictCard1:	.asciiz "Resource/P03.png"
pictCard2:	.asciiz "Resource/P04.png"
pictCard3:	.asciiz "Resource/P05.png"
pictCard4:	.asciiz "Resource/P06.png"
pictCard5:	.asciiz "Resource/P07.png"
pictCard6:	.asciiz "Resource/P08.png"
pictAnsw:	.asciiz "Resource/P09.png"
pictOverf:	.asciiz "Resource/P10.png"
pictEnd:	.asciiz "Resource/P11.png"
musicStt:	.asciiz "Resource/MusicStart.txt"
musicEnd:	.asciiz "Resource/MusicEnd.txt"
buff: .asciiz " "
numOfNotesBuff: .ascii "  "#right now it has lenght of 3 b/c thats how many characters in the syscall in readNumNotes has.
numOfNotes:.word 0
#############################################################################
		.text
		.globl main
		# init
main:	li	$s0, 0x79				# save character 'y'
		li	$s1, 0x6e				# save character 'n'
		li	$s2, 6				# 6 digits binary for 0 ~ 63
		li	$s3, 8				# feed back every 8 numbers when print card
		li	$s5, 1				# set card length
		sllv	$s5, $s5, $s2			# << 6
		srl	$s5, $s5, 1			# half of 2^6
		# init sequence ( a shuffled sequence to ask question)
		li	$t8, 1				# start with 000001
		move	$t9, $s2			# index = max digit
		sll	$t9, $t9, 2				# index -> address
initSeq:	beq	$t9, $zero, restart		# break
		addi	$t9, $t9, -4				# address -= 4
		sw	$t8, sequence($t9)		# save to sequence[index]
		sll	$t8, $t8, 1				# <<1
		j	initSeq
restart:	li	$a1, 64				# random range [0, 64)
		#li	$v0, 42
		#syscall
		#move	$s4, $a0			# random factor: a random 6-bit 0/1 sequence
		li	$s4, 63
		addi	$sp, $sp, -8			# save $s0-s1
		sw	$s0, 0($sp)
		sw	$s1, 4($sp)
		la	$s0, sequence
		move	$s1, $s2
		jal	shuffle				# shuffle sequence (length = 6 (* 4))
		lw	$s0, 0($sp)
		lw	$s1, 4($sp)
		addi	$sp, $sp, 8			# restore
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	drawStart
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		li	$v0, 4				# print message start
		la	$a0, start				# load address
		syscall
		li	$v0, 4				# print message hint
		la	$a0, hint
		syscall
		jal	input					# get an input
		beq	$t2, $zero, exit			# input, 1 for y and 0 for n
		li	$t1, 0				# set result to 0
		move	$t0, $s2			# digits left
		# main loop: print card and ask question
loop:		beq	$t0, $zero, show		# if 0 digit left, show reslut. Get highter digit first for similicity
		sll	$t8, $t0, 2
		addi	$t8, $t8, -4				# index -> address
		lw	$t3, sequence($t8)		# current digit = sequence[index]
		move	$t4, $s4
		srl	$s4, $s4, 1			# random sequence >>
		andi	$t4, $t4, 1				# get valid random sequence (lasr digit)
		# card background
		addi $sp, $sp, -12	# save variable
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		beq $t0, 1, card6
		beq $t0, 2, card5
		beq $t0, 3, card4
		beq $t0, 4, card3
		beq $t0, 5, card2
card1:	la $t0, pictCard1
		j cardEntr
card2:	la $t0, pictCard2
		j cardEntr
card3:	la $t0, pictCard3
		j cardEntr
card4:	la $t0, pictCard4
		j cardEntr
card5:	la $t0, pictCard5
		j cardEntr
card6:	la $t0, pictCard6
cardEntr:	li $t1, 0
		li $t2, 0
		jal makeDot
		lw $t0, 0($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		addi $sp, $sp, 12	# restore variable
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
		move	$s1, $s5			# length -> address
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
		move	$s1, $s5			# length
		move	$s2, $s3			# feed back value
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
skipAdd:	addi	$t0, $t0, -1				# digit left--
		j	loop
show:	beq	$t1, $zero, overF		# if answer is 0, overflow
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	drawAnsw
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		li	$v0, 4				# print answer
		la	$a0, answer
		syscall
		li	$v0, 1				# print result
		addi	$a0, $t1, 0				# set $a0 to result
		syscall
		addi	$sp, $sp, -8
		sw	$ra, 0($sp)
		sw	$t5, 4($sp)
		move	$t5, $t1
		jal	bitMNum2
		lw	$ra, 0($sp)
		lw	$t5, 4($sp)
		addi	$sp, $sp, 8
doAgain:	li	$v0, 4				# print again
		la	$a0, again
		syscall
		li	$v0, 4				# print hint
		la	$a0, hint
		syscall
		
		jal	input
		beq	$t2, $zero, exit
		j	restart
overF:	li	$v0, 4				# print overflow
		la	$a0, overflow
		syscall
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	drawOverf
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		j	doAgain
input:	li	$v0, 12				# input a character
		syscall
		# check input validity
		beq	$v0, $s0, branchY		# input is y
		beq	$v0, $s1, branchN		# input is n
		li	$v0, 4				# print unvalid
		la	$a0, unvalid
		syscall
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	wrongTone
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		j	input
branchY:	li	$t2, 1				# set $t2 to 1 if input is y
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	yesTone
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		jr	$ra
branchN:	li	$t2, 0				# set $t2 to 0 if input is n
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	noTone
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
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
		addi	$t0, $t0, 1				# digit++
		srl	$t9, $t9, 1				# $t8 >> 1
		j	digitL
digitE:	li	$t1, 0				# upper count
		li	$t2, 0				# lower count
		li	$t3, 1				# set upper end
		sub	$t5, $s2, $t0			# << max digit - current digit 
		sllv	$t3, $t3, $t5
		li	$t4, 1				# set lower end
		addi	$t5, $t0, -1				# set shamt for splice number
		sllv	$t4, $t4, $t5			# set upper end
		la	$t7, card				# get memory address
		li	$t8, 1				# set card length
		sllv	$t8, $t8, $s2			# << 6
		srl	$t8, $t8, 1				# half of 2^6
		# traverse
upperL:	beq	$t1, $t3, upperE			# if equal end upper loop
lowerL:	beq	$t2, $t4, lowerE			# if equal end lower loop and start a upper loop
		# print number
		move	$t6, $t1			# number == upper * upper unit + 1 + lower
		sll	$t6, $t6, 1				# << 1
		add	$t6, $t6, $s1			# + valid binary expansion
		sllv	$t6, $t6, $t5			# << until 6 digit
		add	$t6, $t6, $t2
		sw	$t6, 0($t7)				# save in card
		addi	$t7, $t7, 4				# addr += 4
		addi	$t2, $t2, 1				# lower count++
		j	lowerL
lowerE:	addi	$t1, $t1, 1				# upper count++
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
		lw	$t8, 0($s0)				# swap
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
		lw	$t3, 0($t1)				# get number from card
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
		addi	$t2, $t2, 1				# feed back index++
		bne	$t2, $s2, afterPrint
		li	$t2, 0				# reset feed back index
afterPrint:	addi	$t0, $t0, 1				# index++
		addi	$t1, $t1, 4				# address+=4
		j	printL
printE:	lw	$t0, 0($sp)
		lw	$t1, 4($sp)
		lw	$t2, 8($sp)
		lw	$t3, 12($sp)
		addi	$sp, $sp, 16			# restore
		# bitmap functions
		addi	$sp, $sp, -4			# save for bitmap print number
		sw	$ra, 0($sp)
		jal	bitMNum				# print num in bitmap
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4			# restore
		jr	$ra
###############################################################################
		# Bitmap functions
		# Bitmap print number		by yuer
		# Bitmap print picuture		by pengfei
###############################################################################
		# Bitmap print number (yuer)
bitMNum:	addi	$sp, $sp, -92			# save variables
		sw 	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		sw	$a2, 12($sp)
		sw	$a3, 16($sp)
		sw	$s0, 20($sp)
		sw	$s1, 24($sp)
		sw	$s2, 28($sp)
		sw	$s3, 32($sp)
		sw	$s4, 36($sp)
		sw	$s5, 40($sp)
		sw	$s6, 44($sp)
		sw	$s7, 48($sp)
		sw	$t0, 52($sp)
		sw	$t1, 56($sp)
		sw	$t2, 60($sp)
		sw	$t3, 64($sp)
		sw	$t4, 68($sp)
		sw	$t5, 72($sp)
		sw	$t6, 76($sp)
		sw	$t7, 80($sp)
		sw	$t8, 84($sp)
		sw	$t9, 88($sp)
		#x from 10 - 370, y from 100 - 200, cube 45 x 25, word 8 x 16
		li $s0, 10        #x position of the head
		li $s1, 100         #y position of the head
		li $t7, 200
		li $t8, 370
		li $s7, 10
		la	$t5, card			# point to card
		li	$t4, 32			# count: print at most 32 numbers
outer: 	li $a2, 0xFFFFFFFF	#loads the color white into the register $a2
		li $s0, 10
inner:	move $s3, $s0
		move $s4, $s1
zeroJp:	lw	$s2, 0($t5)			# load print number
		addi	$t5, $t5, 4			# address ++4
		addi	$t4, $t4, -1			# count--
		beq	$s2, $zero, zeroJp	# read again if zero
		#li $s2, 88 # where you will need to load print number into $s2
		div $s2, $s7
		mfhi $s6
		mflo $s5
		add $a0, $s5, $zero
		jal read
		addi $s0, $s3, 12
		move $s1, $s4
		add $a0, $s6, $zero
		jal read
		move $s0, $s3
   		move $s1, $s4
   		# exit condition for not print zero
   		beq	$t4, $zero, exitBPN
   	
		addi $s0, $s0, 45
		blt $s0, $t8, inner
		addi $s1, $s1, 25
		blt $s1, $t7, outer
		# exit for bitmapPN
exitBPN:	lw 	$ra, 0($sp)
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		lw	$a2, 12($sp)
		lw	$a3, 16($sp)
		lw	$s0, 20($sp)
		lw	$s1, 24($sp)
		lw	$s2, 28($sp)
		lw	$s3, 32($sp)
		lw	$s4, 36($sp)
		lw	$s5, 40($sp)
		lw	$s6, 44($sp)
		lw	$s7, 48($sp)
		lw	$t0, 52($sp)
		lw	$t1, 56($sp)
		lw	$t2, 60($sp)
		lw	$t3, 64($sp)
		lw	$t4, 68($sp)
		lw	$t5, 72($sp)
		lw	$t6, 76($sp)
		lw	$t7, 80($sp)
		lw	$t8, 84($sp)
		lw	$t9, 88($sp)
		addi	$sp, $sp, 92			# restore variables
		jr	$ra
		
		# $t5	 answer
		# Bitmap print number for answer(yuer)
bitMNum2:	addi	$sp, $sp, -92			# save variables
		sw 	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		sw	$a2, 12($sp)
		sw	$a3, 16($sp)
		sw	$s0, 20($sp)
		sw	$s1, 24($sp)
		sw	$s2, 28($sp)
		sw	$s3, 32($sp)
		sw	$s4, 36($sp)
		sw	$s5, 40($sp)
		sw	$s6, 44($sp)
		sw	$s7, 48($sp)
		sw	$t0, 52($sp)
		sw	$t1, 56($sp)
		sw	$t2, 60($sp)
		sw	$t3, 64($sp)
		sw	$t4, 68($sp)
		sw	$t5, 72($sp)
		sw	$t6, 76($sp)
		sw	$t7, 80($sp)
		sw	$t8, 84($sp)
		sw	$t9, 88($sp)
		#x from 10 - 370, y from 100 - 200, cube 45 x 25, word 8 x 16
		li $a2, 0xFFFFFFFF
 		li $s0, 190
		li $s1, 150
		li $s2, 10
		move $s3, $s0
 		move $s4, $s1
 		div $t5, $s2
 		mfhi $s6
 		mflo $s5
 		add $a0, $s5, $zero
 		jal read
		addi $s0, $s3, 12
 		move $s1, $s4
 		add $a0, $s6, $zero
		jal read
		move $s0, $s3
		move $s1, $s4
		# exit for bitmapPN
exitBPN2:	lw 	$ra, 0($sp)
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		lw	$a2, 12($sp)
		lw	$a3, 16($sp)
		lw	$s0, 20($sp)
		lw	$s1, 24($sp)
		lw	$s2, 28($sp)
		lw	$s3, 32($sp)
		lw	$s4, 36($sp)
		lw	$s5, 40($sp)
		lw	$s6, 44($sp)
		lw	$s7, 48($sp)
		lw	$t0, 52($sp)
		lw	$t1, 56($sp)
		lw	$t2, 60($sp)
		lw	$t3, 64($sp)
		lw	$t4, 68($sp)
		lw	$t5, 72($sp)
		lw	$t6, 76($sp)
		lw	$t7, 80($sp)
		lw	$t8, 84($sp)
		lw	$t9, 88($sp)
		addi	$sp, $sp, 92			# restore variables
		jr	$ra

read:   addi $sp, $sp, -4
	sw $ra, ($sp)
	move $s2, $a0
	beq $s2, 0, draw0
	beq $s2, 1, draw1
	beq $s2, 2, draw2
	beq $s2, 3, draw3
	beq $s2, 4, draw4
	beq $s2, 5, draw5
	beq $s2, 6, draw6
	beq $s2, 7, draw7
	beq $s2, 8, draw8
	beq $s2, 9, draw9
readE:	lw $ra, ($sp)		# beq is not jal
	addi $sp, $sp, 4
	jr $ra

draw0:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	addi $s0, $s0, -8
	addi $s1, $s1, -16
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw1:  addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $s0, $s0, 8
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw2:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	jal row
	addi $s0, $s0, -8
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw3:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	jal row
	addi $s0, $s0, -8
	addi $s1, $s1, -8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw4:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $s1, $s1, -16
	addi $t6, $s1, 8
	jal col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw5:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	jal row
	addi $s0, $s0, -8
	addi $s1, $s1, -16
	addi $t6, $s0, 8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw6: 	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	jal row
	addi $s0, $s0, -8
	addi $s1, $s1, -16
	addi $t6, $s0, 8
	jal row
	addi $s0, $s0, -8
	addi $s1, $s1, 8
	addi $t6, $s1, 8
	jal col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw7:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
draw8:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	addi $s0, $s0, -8
	addi $s1, $s1, -16
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	addi $s1, $s1, -8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE
	
draw9:	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $t6, $s0, 8
	jal row
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	addi $s0, $s0, -8
	addi $s1, $s1, -16
	addi $t6, $s1, 8
	jal col
	addi $t6, $s0, 8
	jal row
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	addi $s1, $s1, 8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j readE

row:
   	ble $s0, $t6, DrawRow
   	addi $s0, $s0, -1
   	jr $ra
   	
col:
   	ble $s1, $t6, DrawCol
   	addi $s1, $s1, -1
   	jr $ra
   	

DrawRow:
li $t3, 0x10000100       #t3 = first Pixel of the screen

sll   $t0, $s1, 9        #y = y * 512
addu  $t0, $t0, $s0      # (xy) t0 = x + y
sll   $t0, $t0, 2        # (xy) t0 = xy * 4
addu  $t0, $t3, $t0      # adds xy to the first pixel ( t3 )
sw    $a2, ($t0)         # put the color ($a2) in $t0
addi $s0, $s0, 1 	#adds 1 to the X of the head
j row

DrawCol:
li $t3, 0x10000100       #t3 = first Pixel of the screen

sll   $t0, $s1, 9        #y = y * 512
addu  $t0, $t0, $s0      # (xy) t0 = x + y
sll   $t0, $t0, 2        # (xy) t0 = xy * 4
addu  $t0, $t3, $t0      # adds xy to the first pixel ( t3 )
sw    $a2, ($t0)         # put the color ($a2) in $t0
addi $s1, $s1, 1         #adds 1 to the X of the head
j col

		# Bitmap print pircture (pengfei)
drawStart:	addi $sp, $sp, -8	# save variable
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		la $t0, pictStart
		jal makeDot
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		la $s0, musicStt		# mucic
		jal musicTime
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		addi $sp, $sp, 8
		la $t0, pictStart2
		jal makeDot
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		addi $sp, $sp, 8	# restore variable
		jr $ra
drawAnsw: addi $sp, $sp, -8	# save variable
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		jal yesTone
		jal noTone
		la $t0, pictAnsw
		jal makeDot
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		addi $sp, $sp, 8	# restore variable
		jr $ra
drawOverf: addi $sp, $sp, -8	# save variable
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		jal yesTone
		jal noTone
		la $t0, pictOverf
		jal makeDot
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		addi $sp, $sp, 8	# restore variable
		jr $ra
drawEnd:	addi $sp, $sp, -8	# save variable
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		la $t0, pictEnd
		jal makeDot
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		la $s0, musicEnd		# mucic
		jal musicTime
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		addi $sp, $sp, 8
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		addi $sp, $sp, 8	# restore variable
		jr $ra
		# $t0	dir
		# $t1	x-offset
		# $t2	y-offset
		# make dot?
makeDot:	addi $sp, $sp, -16	# save variable
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		
		move $a0, $t0		# dir
		li $v0, 60
		syscall
		li $a0, 0			# x
		li $a1, 0			# y
		li $v0, 61
		syscall
		li $a0, 0
		li $a1, 256
		li $a2, 0
		# $v0 = base+$a0*4+$a1*512*4
		sll $a0,$a0,2
		sll $a1,$a1,11
		addi $v0, $a0, 0x10010000
		add $v0, $v0, $a1

		sw $v1, 0($v0)		# make dot
		
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a2, 12($sp)
		addi $sp, $sp, 16	# restore variable
		jr $ra
###############################################################################
		# Music function
		# Sound effect				by pengfei
###############################################################################
yesTone:
li	$a0, 83			#$a0 stores the pitch of the tone
li	$a1, 250		#$a1 stores the length of the tone
li	$a2, 112		#$a2 stores the instrument of the tone
li	$a3, 100		#$a3 stores the volumn of the tone
li	$v0, 33			#system call code for MIDI out synchronous
syscall				#play the first half of the tone
jr	$ra
noTone:
li	$a0, 79			#$a0 stores the pitch of the tone
li	$a1, 250		#$a1 stores the length of the tone
li	$a2, 112		#$a2 stores the insrument of the tone
li	$a3, 100		#$a3 stores the volumn of the tone
li	$v0, 33			#system call code for MIDI out synchronous
syscall				#play the second half of the tone
jr	$ra
wrongTone:
li	$a0, 50			#$a0 stores the pitch of the tone
li	$a1, 1500		#$a1 stores the length of the tone
li	$a2, 32			#$a2 stores the insrument of the tone
li	$a3, 127		#$a3 stores the volumn of the tone
li	$v0, 31			#system call code for MIDI out
syscall				#play the tone
jr	$ra
# $s0  save the music file dir
musicTime:
	addi 	$sp, $sp, -52	#save
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$a2, 12($sp)
	sw	$a3, 16($sp)
	sw	$t0, 20($sp)
	sw	$t1, 24($sp)
	sw	$t2, 28($sp)
	sw	$t3, 32($sp)
	sw	$t4, 36($sp)
	sw	$t5, 40($sp)
	sw	$t6, 44($sp)
	sw	$t7, 48($sp)
openFile:
	li $v0, 13          
	move $a0, $s0                  #file name
	li $a1, 0                   		#0 for read
	li $a2,0
	syscall
	move $t7,$v0    
readNumNotes:
	#gets number of notes
	li $v0, 14                   #syscall 14 read from file
	move $a0,$t7                 #the file description
	la $a1, numOfNotesBuff       #the buffer
	li $a2,3                     #number of chars to read
	syscall
	move $t7,$a0             

	la $t4,numOfNotesBuff
		
	#convert the buffer's chars to int
	li $t0, 0
	la $t1,numOfNotes
	#get the ascii value x()
	lb $t2,0($t4)
	li $t3,10
	sub $t2,$t2,48
	mult $t2,$t3
	mflo $t2
	add $t0,$t0,$t2
	#get the ascii value ()x
	lb $t2,1($t4)
	li $t3,1
	sub $t2,$t2,48
	mult $t2,$t3
	mflo $t2
	add $t0,$t0,$t2
	sw $t0,($t1)
	
playNotes:
	li $t5,0
	la $t2, numOfNotes
	lw $t4,($t2)

	playContinue:
	#get the note
	li $v0, 14                         #syscall 14 read from file
	move $a0,$t7                       #the file description
	la $a1, buff                       #the buffer
	li $a2,1                           #number of chars to read
	syscall
	move $t7,$a0                 
	
	#figures out which note is going to be played
	la $t2,buff
	lb $t0,($t2)
	li $t1,61
	beq $t0,68,noteD
	beq $t0,69,noteE
	beq $t0,70,noteF
	beq $t0,71,noteG
	beq $t0,65,noteA
	beq $t0,66,noteB
	beq $t0,67,noteC
	#else play C#
	b noteSetUpDone
	
	noteD:
		add $t1,$t1,1
		b noteSetUpDone
	noteE:
		add $t1,$t1,3
		b noteSetUpDone	
	noteF:
		add $t1,$t1,4
		b noteSetUpDone
	noteG:
		add $t1,$t1,6
		b noteSetUpDone	
	noteA:
		add $t1,$t1,8
		b noteSetUpDone
	noteB:
		add $t1,$t1,10
		b noteSetUpDone	
	noteC:
		add $t1,$t1,11
		b noteSetUpDone
	noteSetUpDone:
	
	#play the sound
	move $a0,$t1                            #pitch
	li $a1,100                            #time
	li $a2,37                               #32#31#29#instumanets
	li $a3,1000                              #volume
	li $v0,33                               #syscall to beep with pause
	syscall
	
	#increment counter
	add $t5,$t5,1
	
	#checks that the counter is less than the number of notes
	bne $t5,$t4, notDone
	j closeFile
	notDone:
	b playContinue
		
closeFile:
	li $v0, 16
	move $a0,$t7
	syscall
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$a2, 12($sp)
	lw	$a3, 16($sp)
	lw	$t0, 20($sp)
	lw	$t1, 24($sp)
	lw	$t2, 28($sp)
	lw	$t3, 32($sp)
	lw	$t4, 36($sp)
	lw	$t5, 40($sp)
	lw	$t6, 44($sp)
	lw	$t7, 48($sp)
	addi 	$sp, $sp, 52	# restore
	jr	$ra
###############################################################################
		# exit
exit:		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	drawEnd
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		li	$v0, 4				# print end
		la	$a0, end
		syscall
		li $v0, 10
		syscall
