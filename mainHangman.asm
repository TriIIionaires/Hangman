#Kevin Chen, Zyad Elbialy, Jadon Malvar, Omer Muhammad
#Main Program

.data
enterLetter: .asciiz "Enter a letter: "
usedMessage: .asciiz "Used letters: "
invalidMessage: .asciiz "Invalid input. Only letters are allowed."
winMessage: .asciiz "Hangman survived. You win!"
loseMessage: .asciiz "Hangman died. You lose."
newLine: .asciiz "\n"
separator: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

usedLetters: .space 26 #save 26 bytes for 26 letters

hang0: .asciiz " +---+\n |   |\n     |\n     |\n     |\n     |\n=======\n"
hang1: .asciiz " +---+\n |   |\n O   |\n     |\n     |\n     |\n=======\n"
hang2: .asciiz " +---+\n |   |\n O   |\n |   |\n     |\n     |\n=======\n"
hang3: .asciiz " +---+\n |   |\n O   |\n/|   |\n     |\n     |\n=======\n"
hang4: .asciiz " +---+\n |   |\n O   |\n/|\\  |\n     |\n     |\n=======\n"
hang5: .asciiz " +---+\n |   |\n O   |\n/|\\  |\n/    |\n     |\n=======\n"
hang6: .asciiz " +---+\n |   |\n O   |\n/|\\  |\n/ \\  |\n     |\n=======\n"

.eqv ATTEMPTS_LEFT 	$s0
.eqv TOTAL_LETTERS 	$s1
.eqv REMAINING_LETTERS 	$s2
.eqv FOUND_LETTERS 	$s3 #contains ASCII chars (in decimal)

.macro printLabel(%label)
	#print value in %label
	li $v0, 4
	la $a0, %label
	syscall
.end_macro

.macro printResult
	move $t1, FOUND_LETTERS #iterator for FOUND_LETTERS
	move $t2, TOTAL_LETTERS #counter for loop condition

loop:
	beq $t2, $zero, done #if $t2 is equal to 0, jump to done
	
	#if not, $t1 is a character
	lb $t3, 0($t1) #load character in $t1 into $t3
	
	#print character in $t3
	li $v0, 11
	move $a0, $t3
	syscall
	
	#print space character
	li $v0, 11
	li $a0, ' '
	syscall

	addi $t1, $t1, 1 #increment $t1 to next byte
	addi $t2, $t2, -1 #decrement $t2

	j loop

done:
	printLabel(newLine)
.end_macro

.macro printUsedLetters
	la $t1, usedLetters
	
	printLabel(usedMessage)

loop:
	lb $t2, 0($t1) #load byte in $t1 into $t2
	
	beq $t2, $zero, done #if $t2 is equal to zero, jump to done
	
	#if not, $t2 is a character
	#print character in $t2
	li $v0, 11
	move $a0, $t2
	syscall
	
	#print space character
	li $v0, 11
	li $a0, ' '
	syscall
	
	addi $t1, $t1, 1 #increment $t1 to next byte
	
	j loop

done:
	printLabel(newLine)
.end_macro

.macro printHangman
	beq ATTEMPTS_LEFT, 6, stage0 #if ATTEMPTS_LEFT is 6, jump to stage 0
	beq ATTEMPTS_LEFT, 5, stage1 #if ATTEMPTS_LEFT is 5, jump to stage 1
	beq ATTEMPTS_LEFT, 4, stage2 #if ATTEMPTS_LEFT is 4, jump to stage 2
	beq ATTEMPTS_LEFT, 3, stage3 #if ATTEMPTS_LEFT is 3, jump to stage 3
	beq ATTEMPTS_LEFT, 2, stage4 #if ATTEMPTS_LEFT is 2, jump to stage 4
	beq ATTEMPTS_LEFT, 1, stage5 #if ATTEMPTS_LEFT is 1, jump to stage 5
	beq ATTEMPTS_LEFT, 0, stage6 #if ATTEMPTS_LEFT is 0, jump to stage 6

stage0:
	printLabel(hang0)
	j done

stage1:
	printLabel(hang1)
	j done

stage2:
	printLabel(hang2)
	j done

stage3:
	printLabel(hang3)
	j done

stage4:
	printLabel(hang4)
	j done

stage5:
	printLabel(hang5)
	j done

stage6:
	printLabel(hang6)

done:
	printLabel(newLine)
	
.end_macro

.text
main:
	#intialize to guarantee proper behavior
	li ATTEMPTS_LEFT, 6
	li TOTAL_LETTERS, 0
	li REMAINING_LETTERS, 0
	li FOUND_LETTERS, 0
	
	jal selectRandomWord  #choose random word
	
	lw $t0, currentWord #load random word into $t0

loopWord:
	lb $t1, 0($t0) #load byte in $t0 into $t1
	
	beq $t1, $zero, initFields #if $t1 is 0, jump to initFields
	
	#if not, $t1 is a character
	addi TOTAL_LETTERS, TOTAL_LETTERS, 1 #increment TOTAL_LETTERS
	addi $t0, $t0, 1 #increment $t0 to next byte

	j loopWord

initFields:
	#allocate data that is TOTAL_LETTERS bytes
	li $v0, 9
	move $a0, TOTAL_LETTERS
	syscall
	
	move FOUND_LETTERS, $v0 #store address of allocated data in FOUND_LETTERS
	move REMAINING_LETTERS, TOTAL_LETTERS #copy TOTAL_LETTERS into REMAINING_LETTERS
	
	move $t0, FOUND_LETTERS #iterator for FOUND_LETTERS
	move $t3, TOTAL_LETTERS #counter for loop condition

loopFound:
	lb $t1, 0($t0) #load byte in $t0 into $t1
	
	beq $t3, $zero, printStart #if $t3 is 0, jump to printStart
	
	#if not, $t1 is a character
	li $t2, '_'
	sb $t2, 0($t0) #store '_' into FOUND_LETTERS
	
	addi $t0, $t0, 1 #increment $t0 to next byte
	addi $t3, $t3, -1 #decrement $t3
	
	j loopFound

printStart:
	printLabel(separator)
	printHangman
	printResult
	printLabel(newLine)
	printUsedLetters
	
getInput:
	beq ATTEMPTS_LEFT, 0, lose #if ATTEMPTS_LEFT is 0, jump to lose
	beq REMAINING_LETTERS, 0, win #if REMAINING_LETTERS is 0, jump to win
	
	printLabel(enterLetter)
	
	#get character from player
	li $v0, 12
	syscall
	move $t0, $v0 #store character into $t0
	
	printLabel(newLine)
	
	#ASCII range for letters: 65-90 (A-Z, both inclusive) and 97-122 (a-z, both inclusive)
	#check if input is a letter
	blt $t0, 65, invalidInput #if $t0 is less than 65, jump to invalidInput
	#if not, $t0 is greater than or equal to 65
	bgt $t0, 122, invalidInput #if $t0 is greater than 122, jump to invalidInput
	#if not, $t0 is between 65 and 122 (both inclusive)
	blt $t0, 91, processInput #if $t0 is less than 91, jump to processInput
	#if not, $t0 is between 91 and 122 (both inclusive)
	bgt $t0, 96, processInput #if $t0 is greater than 96, jump to processInput
	#if not, $t0 is between 91 and 96 (both inclusive)
	
invalidInput:
	printLabel(invalidMessage)
	printLabel(newLine)
	
	j getInput

processInput:
	printLabel(separator)
	
	#check if $t0 is an uppercase letter (ASCII range: 65-90)
	blt $t0, 97, toLowercase #if $t0 is less than 97, jump to toLowercase; prior branching guarantees $t0 is at least 65
	#if not, $t0 is lowercase
	j skip

toLowercase:
	addi $t0, $t0, 32 #difference between uppercase and lowercase in ASCII is 32

skip:
	la $t1, usedLetters

loopUsedLetters:
	lb $t2, 0($t1) #load letter in $t1 (usedLetters) into $t2
	
	#check if letter in $t0 was already used
	beq $t2, $t0, printOutput #if $t2 is equal to $t0, jump to printOutput
	#if not, $t2 is not equal to $t0
	beq $t2, $zero, append #if $t2 is 0 (not a letter), jump to append
	#if not, $t2 is a letter
	
	addi $t1, $t1, 1 #increment $t1 (usedLetters) to next byte

	j loopUsedLetters

append:
	sb $t0, 0($t1) #store $t0 into $t1 (usedLetters)
	#guarantee next byte in $t1 is a null terminator
	addi $t1, $t1, 1 #increment $t1 to next byte
	sb $zero, 0($t1) #store null terminator into byte

verifyAnswer:
	lw $t1, currentWord
	move $t2, FOUND_LETTERS #iterator for FOUND_LETTERS
	move $t3, TOTAL_LETTERS #counter for loop condition
	li $t4, 0 #letter found = 1, not found = 0

loop:
	beq $t3, $zero, validate #if $t3 is 0, jump to validate
	#if not, $t2 still contains characters
	
	lb $t6, 0($t2) #load character in $t2 (FOUND_LETTERS) into $t6
	bne $t6, '_', updateLoop #if $t6 is not '_', jump to updateLoop
	#if not, $t6 is '_'

	lb $t5, 0($t1) #load letter in $t1 (currentWord) into $t5
	beq $t0, $t5, reveal #if $t0 is equal to $t5, jump to reveal
	#if not, letters do not match

updateLoop:
	addi $t1, $t1, 1 #increment $t1 to next byte
	addi $t2, $t2, 1 #increment $t2 to next byte
	addi $t3, $t3, -1 #decrement $t3
	
	j loop

reveal:
	sb $t5, 0($t2) #store letter in $t5 into $t2 (FOUND_LETTERS)
	li $t4, 1 #letter found
	addi REMAINING_LETTERS, REMAINING_LETTERS, -1 #decrement REMAINING_LETTERS

	j updateLoop

validate:
	beq $t4, 1, printOutput #if $t4 is 1, jump to printOutput
	#if not, a letter was not found
	
	addi ATTEMPTS_LEFT, ATTEMPTS_LEFT, -1 #decrement ATTEMPTS_LEFT
	
printOutput:
	printHangman
	printResult
	printLabel(newLine)
	printUsedLetters
	
	j getInput

win:
	printLabel(winMessage)
	
	j exit

lose:
	printLabel(loseMessage)

exit:
	#exit program
	li $v0, 10
	syscall
