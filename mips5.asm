        .data
endgamePanda: .asciiz "/Users/scgtall25/Desktop/CS3340Architecture/TeamProject/Resource/P02.png"

        .text
        
main:
	la $a0, endgamePanda
        li $v0, 60
	syscall
	li $a0, 0
	li $a1, 0
	li $v0, 61
	syscall
	li $a0, 0
	li $a1, 256
	li $a2, 0
	jal DrawDot
	j end
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
