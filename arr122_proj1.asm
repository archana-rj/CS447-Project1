# ARCHANA RAJASEHARAN
# ARR122
# 02/08/2020

.include "macros.asm"
.eqv INPUT_SIZE 3
.data

# maps from ASCII to MIDI note numbers, or -1 if invalid.
input: .space INPUT_SIZE

instrumentnum: .byte 0
	
recorded_notes: .byte  -1:1024

recorded_times: .word 250:1024
 
key_to_note_table: .byte
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 60 -1 -1 -1
	75 -1 61 63 -1 66 68 70 -1 73 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 55 52 51 64 -1 54 56 72 58 -1 -1 59 57 74
	76 60 65 49 67 71 53 62 50 69 48 -1 -1 -1 -1 -1

demo_notes: .byte
	67 67 64 67 69 67 64 64 62 64 62
	67 67 64 67 69 67 64 62 62 64 62 60
	60 60 64 67 72 69 69 72 69 67
	67 67 64 67 69 67 64 62 64 65 64 62 60
	-1

demo_times: .word
	250 250 250 250 250 250 500 250 750 250 750
	250 250 250 250 250 250 500 375 125 250 250 1000
	375 125 250 250 1000 375 125 250 250 1000
	250 250 250 250 250 250 500 250 125 125 250 250 1000
	0
.text

# -----------------------------------------------

.globl main
main:

   	println_str "Hi! Enter a command to begin the toy keyboard"
	println_str "play notes with letters & punctuation."
	println_str "change instrument with ` and then type the number."
	println_str "exit with enter."
	println_str "current instrument: 1"

_main_loop:

    print_str "command? [k]eyboard, [d]emo, [r]ecord, [p]lay, [q]uit: "
    la a0, input
    li a1, INPUT_SIZE
    li v0, 8
    syscall


	lb t0, input

	beq t0, 'k', case_keyboard
	beq t0, 'd', case_demo
	beq t0, 'r', case_record
	beq t0, 'p', case_play
	beq t0, 'q', quit

	println_str "Not a valid command!"
	j _main_loop
# -----------------------------------------------

case_keyboard:
	jal keyboard # calls keyboard function
	j _main_loop

keyboard:
	push ra

#	println_str "play notes with letters & punctuation."
#	println_str "change instrument with ` and then type the number."
#	println_str "exit with enter."
#	println_str "current instrument: 1"

	_keyb_loop:

	la a0, input
    li a1, INPUT_SIZE
    li v0, 12
    syscall

    beq v0, '\n', _keyboard_break # user hits 'enter' to exit
    beq v0, '`', _change_instrument # user hits '`' to change instrument

    move a0, v0
    move s0, v0
    jal translate_note

    j _keyb_loop

	_keyboard_break: # exit to main loop	
	pop ra
	jr ra

	_change_instrument: # change instrument
	println_str ""
	print_str "Enter instrument number (1...128): "
	
    li v0, 5
    syscall

	blt v0, 1, _change_instrument
	bgt v0, 128, _change_instrument
	
	move t3, a1
	la a1, instrumentnum # a1 hold adress of instrumentnum
	
	sub v0, v0, 1 # subtract 1 from instrument number
	move t5, v0	# save correct instrument number in t5
	
	sb t5, (a1) # store the new value in instrumentnum
	
	move a1, t3 # restore original a1 value
	jal _keyb_loop

	pop ra
	jr ra

play_note: # function to play a note

	push ra 
	push s0
	push s1

	move a0, s0 # note to play
	move a1, s1 # duration of note
	lb a2, instrumentnum # instrument type
	li a3, 100 # volume

	li v0, 31
	syscall

	pop s0
	pop s1
	pop ra
	jr ra

translate_note:

	push ra

	blt s0, 0, _exit_minus_one
	bgt s0, 127, _exit_minus_one 

	la t1, key_to_note_table
	add t2, t1, s0
	lb a0, (t2)
	lb s0, (t2)
   
	bne a0, -1, _jump_to_play

	pop ra 
	jr ra


	_exit_minus_one: # return -1 if ascii < 0 || ascii > 127

	li a0, -1
	j _main_loop

	_jump_to_play: # play translated note

	move s0, a0
	li s1, 500

	jal play_note

	pop ra 
	jr ra


case_demo: # calls play_song function

	jal play_song 
	j _main_loop

play_song:

	push ra

	#move t5, a1
	#move t6, a2

	la t1, demo_notes
	la t2, demo_times
	li t3, 500
	
	_loop_song:

	lb a0, (t1)
	lw a1, (t2)
	
	lb s0, (t1)
	lb s1, (t2)
	jal play_note

	move a0, t3
	li v0, 32 # sleep
	syscall

	#add t3, t3, 5
	add t1, t1, 1 # indexing demo notes
	lb t4, (t1)
	beq t4, -1, _loop_end # jumps to end loop when sees a -1 note

	add t2, t2, 4
	j _loop_song

	_loop_end:

	pop ra
	jr ra

case_record:

	jal record # does the keyboard stuff
	j _main_loop

record:

	push ra

	la t3, recorded_notes
	la t4, recorded_times
	li t6, 0

	_rec_loop:

	la a0, input
    li a1, INPUT_SIZE
    li v0, 12
    syscall

    beq v0, '\n', _rec_break # exits if the user hits 'enter'
    move a0, v0
    move s0, v0

    li v0, 30
    syscall

    add t6, t6, 1
    sw v0, (t4)
    move a0, v0
    add t4, t4, 4

    #move t6, v0
	#move a0, t6    
    #li v0, 1
    #syscall
    move a0, s0
    jal translate_note
  

    sb a0, (t3)
    add t3, t3, 1

    j _rec_loop

	_rec_break:
#	add t6, t6, 1
#	sw v0, (t4)
#	move a0, v0
#	la t4, recorded_times
#	la t5, recorded_times

#	_check:
#	add t5, t5, 4
##	move a0, t3
#	li v0 1
##	sw t3, (t4)
#	lw t7, (t4)	

#	move a0, t7
#	li v0, 1
#	syscall

#	sub t6, t6, 1
#	add t4, t4, 4
#	bgt t6, 0, _check

	pop ra
	jr ra

case_play:

	jal play 
	j _main_loop

play:

	push ra
	li t5, 0
	la t3, recorded_notes
	la t4, recorded_times

	_play_loop:

	lb t2, (t3)
	beq t2, -1, _play_break
	lb s0, (t3)
	lb a0, (t3)
	lw s1, (t4)
	lw a1, (t4)
	add t5, t5, 1
	
	jal play_note

	add t3, t3, 1
	add t4, t4, 4 
	j _play_loop

	_play_break:

	move a0, t5
	
	pop ra
	jr ra

quit:
    li v0, 10
    syscall