		addi	$s0, $zero, 77
		addi $s1, $zero, 31234
		lw $t0, 12($s1)
domore:	addi $t0, $t0, 100
		sw $t0, 8($s1)
		addi $s0, $s0, 1
		slti $t7, $s0, 150
		addi $s1, $s1, 1
		bne $t7, $zero, domore
		sub $s0, $s0, 100
