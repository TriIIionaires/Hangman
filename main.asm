#Kevin Chen, Zyad Elbialy, Jadon Malvar, Omer Muhammad
#Main Program

.data
enterChar: .asciiz "Enter a character: "
usedOutput: .asciiz "Used characters: "
hiddenWord: .asciiz "apple"
output: .asciiz "_ _ _ _ _ "
attemptsMessage: .asciiz "Attempts left: "
invalidMessage: .asciiz "Invalid input. Only letters are allowed."
winMessage: .asciiz "Hangman survived. You win!"
loseMessage: .asciiz "Hangman died. You lose."
newLine: .asciiz "\n"
separator: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

usedCharacters: .byte 0
buffer: .space 26

.eqv ATTEMPTS_LEFT $s0
.eqv TOTAL_CHARACTERS $s1
.eqv REMAINING_CHARACTERS $s2
.eqv FOUND_CHARACTERS $s3 #contains ASCII chars; not a number

.macro setupGame
	la $t0, hiddenWord
	loopWord:
		lb $t1, 0($t0)
		
		beq $t1, $zero, initFoundChars
	
		add TOTAL_CHARACTERS, TOTAL_CHARACTERS, 1
		add $t0, $t0, 1
	
		j loopWord
	initFoundChars:
		li $v0, 9
		move $a0, TOTAL_CHARACTERS
		syscall
		move FOUND_CHARACTERS, $v0
		move REMAINING_CHARACTERS, TOTAL_CHARACTERS
		move $t0, FOUND_CHARACTERS
		move $t3, TOTAL_CHARACTERS
	loopChars:
		lb $t1, 0($t0)
		
		beq $t3, $zero, continue
		
		li $t2, '_'
		sb $t2, 0($t0)
		
		add $t0, $t0, 1
		sub $t3, $t3, 1
		
		j loopChars
	continue:
		li $v0, 4
		la $a0, newLine
		syscall
.end_macro

.macro verifyAnswer(%char)
	la $t1, hiddenWord
	move $t2, FOUND_CHARACTERS
	move $t3, TOTAL_CHARACTERS
	li $t4, 0 #character found = 1, not found = 0
	loop:
		lb $t5, 0($t1)
		lb $t6, 0($t2)
		
		beq $t3, 0, continue
		beq %char, $t5, reveal
	increment:
		add $t1, $t1, 1
		add $t2, $t2, 1
		sub $t3, $t3 1
		
		j loop
	reveal:
		sb $t5, 0($t2)
		li $t4, 1
		
		sub REMAINING_CHARACTERS, REMAINING_CHARACTERS, 1
		
		j increment
	continue:
		beq $t4, 0, removeAttempt
		beq $t4, 1, done
	removeAttempt:
		sub ATTEMPTS_LEFT, ATTEMPTS_LEFT, 1
	done:
		li $v0, 4
		la $a0, newLine
		syscall
.end_macro

.macro printResult
	move $t1, FOUND_CHARACTERS
	move $t2, TOTAL_CHARACTERS
	loop:
		beq $t2, $zero, done
	
		lb $t3, 0($t1)
	
		li $v0, 11
		move $a0, $t3
		syscall
	
		li $v0, 11
		li $a0, ' '
		syscall
	
		add $t1, $t1, 1
		sub $t2, $t2, 1
	
		j loop
	done:
		li $v0, 4
		la $a0, newLine
		syscall
.end_macro

.macro checkAnswer(%char)
	la $t2, hiddenWord
	loop:
		lb $t1, 0($t2)
		
		beq $t1, $zero, done
		beq $t1, %char, reveal
		
		li $v0, 11
		li $a0, '_'
		syscall
	increment:
		add $t2, $t2, 1
		
		li $v0, 11
		la $a0, ' '
		syscall
		
		j loop
	reveal:
		li $v0, 11
		move $a0, $t1
		syscall
		
		j increment
	done:
		li $v0, 4
		la $a0, newLine
		syscall
.end_macro

.macro appendChar(%char)
	la $t1, usedCharacters
	loop:
		lb $t2, 0($t1)
		
		beq $t2, %char, done
		beq $t2, $zero, append
		
		add $t1, $t1, 1
	
		j loop
	append:
		sb %char, 0($t1)
	done:
		printUsed
.end_macro

.macro printUsed
	la $t1, usedCharacters
	
	li $v0, 4
	la $a0, usedOutput
	syscall
	loop:
		lb $t2, 0($t1)
		
		beq $t2, $zero, done
		
		li $v0, 11
		move $a0, $t2
		syscall
		
		li $v0, 11
		li $a0, ' '
		syscall
		
		add $t1, $t1, 1
		
		j loop
	done:
		li $v0, 4
		la $a0, newLine
		syscall
.end_macro

.macro toLowercase(%char) #Precondition: %char is an ASCII letter
	blt %char, 97, convert
	bge %char, 97, keep
	convert:
		add %char, %char, 32
	keep:
		add %char, %char, $zero
.end_macro

.text
main:
	li ATTEMPTS_LEFT, 6
	li TOTAL_CHARACTERS, 0
	li REMAINING_CHARACTERS, 0
	li FOUND_CHARACTERS, 0
	
	setupGame
	printResult
	
getInput:
	beq ATTEMPTS_LEFT, 0, lose
	beq REMAINING_CHARACTERS, 0, win

	li $v0, 4
	la $a0, enterChar
	syscall
	
	li $v0, 12
	syscall
	move $t0, $v0
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	blt $t0, 65, invalidInput
	bgt $t0, 122, invalidInput
	blt $t0, 91, processInput
	bgt $t0, 96, processInput
invalidInput:
	li $v0, 4
	la $a0, invalidMessage
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	j getInput
processInput:
	li $v0, 4
	la $a0, separator
	syscall
	
	toLowercase($t0)
	verifyAnswer($t0)
	printResult
	appendChar($t0)
	
	li $v0, 4
	la $a0, attemptsMessage
	syscall
	
	li $v0, 1
	move $a0, ATTEMPTS_LEFT
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	j getInput
win:
	li $v0, 4
	la $a0, winMessage
	syscall
	
	j exit
lose:
	li $v0, 4
	la $a0, loseMessage
	syscall
exit:
	li $v0, 10
	syscall
	
	
	
