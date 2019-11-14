		.data
msg:		.asciiz "12 31 42 73 65 89 23 47 49 27 49 81 63 98 17 39"
msg2:	.asciiz "hello"
msg3:	.asciiz "\n["
msg4:	.asciiz  "]\t("
msgY:	.asciiz  "Y"
msgN:	.asciiz "N"
#############################################################################
		.text
		.globl main
main:	li	$t0, 1
		li	$s0, 121
		li	$s1, 110
loop:		li	$v0, 4
		la	$a0, msg3
		syscall
		li	$v0, 1
		move $a0, $t0
		syscall
		li	$v0, 4
		la	$a0, msg4
		syscall
		li	$v0, 12				# input a character
		syscall
		beq	$v0, $s0, branchY		# input is y
		beq	$v0, $s1, branchN		# input is n
		move	$a0, $v0
		li	$v0, 1				# print
		syscall
		addi	$t0, $t0, 1
		j	loop
branchY:	li	$v0, 4
		la	$a0, msgY
		syscall
		j	loop
branchN:	li	$v0, 4
		la	$a0, msgN
		syscall
		j	loop
		
