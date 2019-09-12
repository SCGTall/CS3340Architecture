	.data
hello:	.asciiz "hello world!"

	.text
main:	li $v0, 4 # print a string
	la $a0, hello
	syscall
	not $t1, $t2
	move $t1, $t2
	
	li $v0, 5 # load in int
	syscall
