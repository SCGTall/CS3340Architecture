

.data
ChannelCount:	.space 2
NoteCount:	.space 2
FileName:        .asciiz  "Pokemon.karn"


.text
Main:


jal AllocateMemory
jal LoadChannelData
jal LoadNoteData
jal SetupChannels
jal PlaySong
j Main



AllocateMemory:

# Try to open file
	li $v0, 13		# Syscall 13 (Open file)
	la $a0, FileName	# Address of null-terminated filename
	li $a1, 0		# Read-only flag
	li $a2, 0		# Mode (unused)
	syscall			

# Get new file name if necessary
	bltz $v0, Main		# Ask for a new filename if needed
	move $s0, $v0		# Save file descriptor

# Read number of channels
	li $v0, 14		# Syscall 14 (Read from file)
	la $a0, ($s0)		# File descriptor
	la $a1, ChannelCount	# Input buffer for channel count
	li $a2, 1		# Read one byte
	syscall			

# Allocate memory for channels/instruments
	li $v0, 9		# Syscall 9 (allocate heap memory)
	lb $t1, ChannelCount	# Number of channels used
	li $t2, 2		# Bytes per channel/instrument
	mul $t1, $t1, $t2	# Bytes needed to store all channel data
	add $a0, $0, $t1	# Reserve bytes
	syscall			#

	move $s1, $v0		# Store pointer to channel data start

# Read number of notes
	li $v0, 14		# Syscall 14 (Read from file)
	la $a0, ($s0)		# File descriptor
	la $a1, NoteCount	# Input buffer for note count
	li $a2, 2		# Read two bytes (halfword)
	syscall			

# Allocate memory for notes
	li $v0, 9		# Syscall 9 (allocate heap memory)
	lh $t1, NoteCount	# Load number of notes
	li $t2, 7		# Note size in bytes
	mul $a0, $t1, $t2	# Reserve bytes for notes * Note Size 
	syscall			

	move $s2, $v0		# Store pointer to note data start
jr $ra

# Subroutine: LoadChannelData
#	Load note data (start, pitch, duration, channel, velocity)
#	Stores in memory starting at $s2

LoadChannelData:

	li $v0, 14		# Syscall 14 (Read from file)
	la $a0, ($s0)		# File descriptor
	la $a1, ($s1)		# Input buffer for channel data

# Calculate bytes to load
	lb $t1, ChannelCount	# Number of channels
	li $t2, 2		# Channel  byte + Instrument byte
	mul $a2, $t1, $t2	# Read bytes for channel data
	syscall			#
jr $ra

# Subroutine: LoadNoteData
#	Load note data (start, pitch, duration, channel, velocity)
#	Stores in memory starting at $s2

LoadNoteData:   # Subroutine:  Load note data (start, pitch, duration, channel, velocity)

# Read note data
	li $v0, 14		# Syscall 14 (Read from file)
	la $a0, ($s0)		# File descriptor
	la $a1, ($s2)		# Input buffer for channel count

# Calculate bytes to load
	lh  $t1, NoteCount	# Load number of notes
	li  $t2, 7		# Note size
	mul $a2, $t1, $t2	# Read bytes for notes * Note Size 
	syscall			#
jr $ra

# Subroutine: SetupChannels
#	Load required channels with instruments
#
#	$s1	=	Channel Data Pointer

SetupChannels:
	li $t1, 1		# Channel counter
	lb $t2, ChannelCount	# Number of channels

	LoadChannel:
	addiu $v0, $0, 38	# Syscall 38 (program change)
	lb    $a0, 0($s1)	# Load channel number
	lb    $a1, 1($s1)	# Load instrument
	syscall			#

	addiu $s1, $s1, 2	# Move to next channel/instrument pair

	addiu $t1, $t1, 1		# Increment channel counter
	ble   $t1, $t2, LoadChannel	# Loop through all channels
jr $ra

# Subroutine: PlaySong
#	Plays the song
#
#	$s1	=	Channel Data Pointer
#	$s2	=	Note Data Pointer
#	
#	$t1	=	Note counter
#	$t2	=	Total number of notes
#
PlaySong:
	sub     $sp,$sp,4	# Push $ra onto stack
	sw      $ra,($sp)	#

	li	$t1, 0		# Note counter
	lh 	$t2, NoteCount	# Load number of notes

	PlayNote:
	addiu 	$v0, $0, 37	# Syscall 37 (MIDI++)
	lb	$a0, 0($s2)	# Load pitch from memory (byte)

# Load duration (unaligned halfword)
	sub     $sp,$sp,4	# Push $a0 onto stack
        sw      $a0,($sp)	#
	sub     $sp,$sp,4	# Push $v0 onto stack
        sw      $v0,($sp)	#

	la 	$a0, 1($s2)		# Duration's memory address
	jal	LoadUnalignedHalfWord	# Load the unaliged duration
	add 	$a1, $t0, $v0		# Load duration (halfword)

	lw      $v0,($sp)	# Pop $v0 off stack
	add     $sp,$sp,4	#          
	lw      $a0,($sp)	# Pop $a0 off stack
	add     $sp,$sp,4	#          

	lb 	$a2, 3($s2)	# Load channel (byte)
	lb 	$a3, 4($s2)	# Load velocity/volume (byte)
	syscall

# Sleep until the next note, if any
	NoteDelay:
	addiu 	$v0, $0, 32	# Syscall 32 (sleep)

# Load pause time (unaligned halfword)
	sub     $sp,$sp,4	# Push $v0 onto stack
        sw      $v0,($sp)	#

	la 	$a0, 5($s2)		# Pause time's memory address
	jal	LoadUnalignedHalfWord	# Load the unaliged pause time
	add 	$a0, $t0, $v0		# Load duration (halfword)

	lw      $v0,($sp)	# Pop $v0 off stack
	add     $sp,$sp,4	#          
	syscall			#

# Sleep or finish the song
	addiu	$t1, $t1, 1		# Increment note counter
	bge	$t1, $t2, FinishSong	# End song after all notes played
	addiu 	$s2, $s2, 7		# Move to next note struct
	j 	PlayNote		# Play the next note
	
	FinishSong:
	lw      $ra,($sp)        # Pop $ra off stack
	add     $sp,$sp,4        #            	
jr $ra

# Subroutine: Load an unaligned halfword from memory
#
#	$a0 - Halfword memory address
#	$v0 - The resulting halfword
#
LoadUnalignedHalfWord:

# Push $t1 and $t2 onto the stack
	sub     $sp,$sp,4	# Push $t1 onto stack
        sw      $t1,($sp)	#
	sub     $sp,$sp,4	# Push $t2 onto stack
        sw      $t2,($sp)	#

# Combine two bytes into one new halfword
	lbu 	$t1, 0($a0)	# Load the first byte
	lbu	$t2, 1($a0)	# Load second byte

	sll	$v0, $t2, 8	# Shift second byte left by 8-bits
	or	$v0, $v0, $t1	# OR the two bytes (combine them)

# Pop $t1 and $t2 off stack
	lw      $t2,($sp)	# Pop $t2 off stack
	add     $sp,$sp,4	#          
	lw      $t1,($sp)	# Pop $t1 off stack
	add     $sp,$sp,4	#          
jr $ra

# Subroutine: Exit the program immediately
#
ExitProgram:

# Close the file
	li $v0, 16		# Syscall 13 (Close file)
	add $a0, $0, $s0	# File descriptor
	syscall			#

	li $v0, 10	# Syscall 10 (Exit program)
	syscall		# Exit
