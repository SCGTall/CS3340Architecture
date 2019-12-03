        .data
endgamePanda: .asciiz "/Users/scgtall25/Desktop/CS3340Architecture/TeamProject/Resource/P02.png"

        .text
        
main:


	la $t0, endgamePanda
	li $t1, 0
	li $t2, 0
	jal makeDot
	addi $t2, $t2, 200
	jal makeDot2
	j end
        
makeDot:	addi $sp, $sp, -16	# save variable
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		
		move $a0, $t0		# dir
		li $v0, 60
		syscall
		move $a0, $t1		# x
		move $a1, $t2		# y
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
		
makeDot2:	addi $sp, $sp, -16	# save variable
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		
		move $a0, $t1		# x
		move $a1, $t2		# y
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
################################################################################################
#  Procedure: CalcAddr                                                                         #
#  Converts X, Y coordinate to address                                                         #
#  Input: $a0 x coordinate                                                                     #
#  Input: $a1 y coordinate                                                                     #
#  Returns $v0 = memory address                                                                #
################################################################################################
CalcAddr:
# $v0 = base+$a0*4+$a1*512*4
sll $a0,$a0,2
sll $a1,$a1,11
addi $v0, $a0, 0x10010000
add $v0, $v0, $a1
jr $ra

################################################################################################
#  Procedure: DrawDot                                                                          #
#  Draws a dot of color ($a2) at x ($a0) and y ($a1)                                           #
#  Input: $a0 x coordinate                                                                     #
#  Input: $a1 y coordinate                                                                     #
#  Input: $a2 color number (0-9)                                                               #
################################################################################################
DrawDot:
addi $sp,$sp,-8	# adjust stack ptr, 2 words
sw $ra, 4($sp)		# store $ra

# $v0 = base+$a0*4+$a1*512*4
sll $a0,$a0,2
sll $a1,$a1,11
addi $v0, $a0, 0x10010000
add $v0, $v0, $a1

sw $v1, 0($v0)		# make dot
lw $ra, 4($sp)		# load original $ra
addi $sp, $sp, 8	# adjust $sp
jr $ra


end:
