##############################################################################
# Program : HW#4_2_6_2	Programmer: Chaoran Li
# Due Date: 10/15/19	Last Modified:10/15/19
# Course: CS3340	Section:501
#############################################################################
# Description:
# Textbook 2.6.2
# Sort Array {2, 4, 3, 6, 1} in $t6
#############################################################################
		.data
Array:	.word 2, 4, 6, 3, 1
#############################################################################
		.text
		.globl main
main:	la	$s6, Array				# set $s6 to Array
		li	$s1, 5				# len = 5
		li	$t0, 0				# $t0: offset of i
		sll	$t2, $s1, 2			# $t2: max offset of i
		add	$t3, $zero, $t2			# $t3: max offset of j
loopI:	beq	$t0, $t2, exitI			# break loopI
		li	$t1, 0				# $t1: offset of j
		addi	$t3, $t3, -4			# $t3 -= 4
loopJ:	beq	$t1, $t3, exitJ
		add	$t4, $s6, $t1			# &= Array[j]
		lw	$t5, 0($t4)
		lw	$t6, 4($t4)
		slt	$t7, $t6, $t5			# Array[j + 1] < Array[j] ? 1 : 0
		beq	$t7, $zero, skip
		sw	$t5, 4($t4)			# swap
		sw	$t6, 0($t4)	
skip:		addi	$t1, $t1, 4
		j 	loopJ
exitJ:		addi	$t0, $t0, 4
		j 	loopI
exitI:
