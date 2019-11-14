.text
li		$t0, 0x7FFFFFFF
addi		$t0, $t0, 2
mfc0		$a0, $13
srl  		$a0, $a0, 2
andi		$a0, $a0, 31