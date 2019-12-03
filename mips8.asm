#x from 10 - 370, y from 100 - 200, cube 45 x 25, word 8 x 16
.text
li $a2, 0xFFFFFFFF
 		li $s0, 190
		li $s1, 150
		li $s2, 78
		li $s7, 10
		move $s3, $s0
 		move $s4, $s1
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
		j exit

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
	lw $ra, ($sp)
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
	jr $ra
draw1:  addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $s0, $s0, 8
	addi $t6, $s1, 8
	jal col
	addi $t6, $s1, 8
	jal col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
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
	jr $ra
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
	jr $ra
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
	jr $ra
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
	jr $ra
draw6: 	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal draw5
	addi $s0, $s0, -8
	addi $s1, $s1, 8
	addi $t6, $s1, 8
	jal col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
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
	jr $ra
draw8:	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal draw0
	addi $t6, $s0, 0
	addi $s0, $s0, -8
	addi $s1, $s1, -8
	jal row
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
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
	jr $ra

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
exit:
li $v0, 10
syscall
