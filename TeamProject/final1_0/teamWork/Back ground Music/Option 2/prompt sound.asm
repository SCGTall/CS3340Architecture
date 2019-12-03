
.text 
main:	

jal	Righttone
jal     Righttone


jal     Wrongtone


j exit



Righttone:
li	$a0, 83			#$a0 stores the pitch of the tone
li	$a1, 250		#$a1 stores the length of the tone
li	$a2, 112		#$a2 stores the instrument of the tone
li	$a3, 100		#$a3 stores the volumn of the tone
li	$v0, 33			#system call code for MIDI out synchronous
syscall				#play the first half of the tone
li	$a0, 79			#$a0 stores the pitch of the tone
li	$a1, 250		#$a1 stores the length of the tone
li	$a2, 112		#$a2 stores the insrument of the tone
li	$a3, 100		#$a3 stores the volumn of the tone
li	$v0, 33			#system call code for MIDI out synchronous
syscall				#play the second half of the tone
jr	$ra

Wrongtone:
li	$a0, 50			#$a0 stores the pitch of the tone
li	$a1, 1500		#$a1 stores the length of the tone
li	$a2, 32			#$a2 stores the insrument of the tone
li	$a3, 127		#$a3 stores the volumn of the tone
li	$v0, 31			#system call code for MIDI out
syscall				#play the tone
jr	$ra



exit:
li $v0, 10           #this line is going to signal end
syscall
