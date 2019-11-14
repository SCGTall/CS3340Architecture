		.data
SideLen:	.word 8
Perimeter:	.space 4
#############################################################################
		.text
		.globl main
main:	lw	$t0, SideLen
		sll	$t0, $t0, 2
		sw	$t0, Perimeter
