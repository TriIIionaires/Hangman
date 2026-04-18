#Kevin Chen, Zyad Elbialy, Jadon Malvar, Omer Muhammad
#Main Program

.data
enterChar: .asciiz "Enter a character: "
usedOutput: .asciiz "Used characters: "
# hiddenWord: .asciiz "apple"

currentWord: .word 0

word0: .asciiz "apple"
word1: .asciiz "grape"
word2: .asciiz "chair"
word3: .asciiz "tiger"
word4: .asciiz "plane"
word5: .asciiz "bread"
word6: .asciiz "snake"
word7: .asciiz "light"
word8:  .asciiz "dog"
word9:  .asciiz "sun"
word10: .asciiz "book"
word11: .asciiz "tree"
word12: .asciiz "milk"
word13: .asciiz "river"
word14: .asciiz "planet"
word15: .asciiz "house"
word16: .asciiz "mouse"
word17: .asciiz "bread"
word18: .asciiz "stone"
word19: .asciiz "chair"
word20: .asciiz "green"
word21: .asciiz "light"
word22: .asciiz "train"
word23: .asciiz "apple"
word24: .asciiz "grape"
word25: .asciiz "smile"
word26: .asciiz "cloud"
word27: .asciiz "tiger"

hang0: .asciiz " +---+\n |   |\n     |\n     |\n     |\n     |\n=======\n"
hang1: .asciiz " +---+\n |   |\n O   |\n     |\n     |\n     |\n=======\n"
hang2: .asciiz " +---+\n |   |\n O   |\n |   |\n     |\n     |\n=======\n"
hang3: .asciiz " +---+\n |   |\n O   |\n/|   |\n     |\n     |\n=======\n"
hang4: .asciiz " +---+\n |   |\n O   |\n/|\\  |\n     |\n     |\n=======\n"
hang5: .asciiz " +---+\n |   |\n O   |\n/|\\  |\n/    |\n     |\n=======\n"
hang6: .asciiz " +---+\n |   |\n O   |\n/|\\  |\n/ \\  |\n     |\n=======\n"

wordList: .word word0, word1, word2, word3, word4, word5, word6, word7, word8, word9, word10, word11, word12, word13, word14, word15, word16, word17, word18, word19, word20, word21, word22, word23, word24, word25, word26, word27
.eqv WORD_COUNT 28

attemptsMessage: .asciiz "Attempts left: "
invalidMessage: .asciiz "Invalid input. Only letters are allowed."
winMessage: .asciiz "Hangman survived. You win!"
loseMessage: .asciiz "Hangman died. You lose."
newLine: .asciiz "\n"
separator: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

usedCharacters: .space 27
buffer: .space 26

.eqv ATTEMPTS_LEFT $s0
.eqv TOTAL_CHARACTERS $s1
.eqv REMAINING_CHARACTERS $s2
.eqv FOUND_CHARACTERS $s3 #contains ASCII chars; not a number

.macro setupGame
	la $t9, currentWord
	lw $t0, 0($t9)
setup_loopWord:
	lb $t1, 0($t0)
	
	beq $t1, $zero, setup_initFoundChars

	addi TOTAL_CHARACTERS, TOTAL_CHARACTERS, 1
	addi $t0, $t0, 1

	j setup_loopWord

setup_initFoundChars:
	li $v0, 9
	move $a0, TOTAL_CHARACTERS
	syscall
	move FOUND_CHARACTERS, $v0
	move REMAINING_CHARACTERS, TOTAL_CHARACTERS
	move $t0, FOUND_CHARACTERS
	move $t3, TOTAL_CHARACTERS

setup_loopChars:
	lb $t1, 0($t0)
	
	beq $t3, $zero, setup_continue
	
	li $t2, '_'
	sb $t2, 0($t0)
	
	addi $t0, $t0, 1
	addi $t3, $t3, -1
	
	j setup_loopChars

setup_continue:
	li $v0, 4
	la $a0, newLine
	syscall
.end_macro

.macro verifyAnswer(%char)
	la $t9, currentWord
	lw $t1, 0($t9)
	move $t2, FOUND_CHARACTERS
	move $t3, TOTAL_CHARACTERS
	li $t4, 0 #character found = 1, not found = 0

verify_loop:
	lb $t5, 0($t1)
	lb $t6, 0($t2)
	
	beq $t3, $zero, verify_continue
	beq %char, $t5, verify_reveal

verify_increment:
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	addi $t3, $t3, -1
	
	j verify_loop

verify_reveal:
	lb $t6, 0($t2)          # current displayed char
	bne $t6, '_', verify_increment

	sb $t5, 0($t2)
	li $t4, 1
	addi REMAINING_CHARACTERS, REMAINING_CHARACTERS, -1

	j verify_increment

verify_continue:
	beq $t4, $zero, verify_removeAttempt
	j verify_done

verify_removeAttempt:
	addi ATTEMPTS_LEFT, ATTEMPTS_LEFT, -1

verify_done:
	li $v0, 4
	la $a0, newLine
	syscall
.end_macro

.macro printResult
	move $t1, FOUND_CHARACTERS
	move $t2, TOTAL_CHARACTERS

printResult_loop:
	beq $t2, $zero, printResult_done

	lb $t3, 0($t1)

	li $v0, 11
	move $a0, $t3
	syscall

	li $v0, 11
	li $a0, ' '
	syscall

	addi $t1, $t1, 1
	addi $t2, $t2, -1

	j printResult_loop

printResult_done:
	li $v0, 4
	la $a0, newLine
	syscall
.end_macro


.macro appendChar(%char)
	la $t1, usedCharacters

appendChar_loop:
	lb $t2, 0($t1)
	
	beq $t2, %char, appendChar_done
	beq $t2, $zero, appendChar_append
	
	addi $t1, $t1, 1

	j appendChar_loop

appendChar_append:
	sb %char, 0($t1)
	addi $t1, $t1, 1
	sb $zero, 0($t1)

appendChar_done:
	printUsed
.end_macro

.macro printUsed
	la $t1, usedCharacters
	
	li $v0, 4
	la $a0, usedOutput
	syscall

printUsed_loop:
	lb $t2, 0($t1)
	
	beq $t2, $zero, printUsed_done
	
	li $v0, 11
	move $a0, $t2
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	addi $t1, $t1, 1
	
	j printUsed_loop

printUsed_done:
	li $v0, 4
	la $a0, newLine
	syscall
.end_macro

.macro toLowercase(%char) #Precondition: %char is an ASCII letter
	blt %char, 97, toLowercase_convert
	bge %char, 97, toLowercase_keep

toLowercase_convert:
	addi %char, %char, 32

toLowercase_keep:
	add %char, %char, $zero
.end_macro

.macro printHangman
	beq ATTEMPTS_LEFT, 6, stage0
	beq ATTEMPTS_LEFT, 5, stage1
	beq ATTEMPTS_LEFT, 4, stage2
	beq ATTEMPTS_LEFT, 3, stage3
	beq ATTEMPTS_LEFT, 2, stage4
	beq ATTEMPTS_LEFT, 1, stage5
	beq ATTEMPTS_LEFT, 0, stage6

stage0:
	li $v0, 4
	la $a0, hang0
	syscall
	j doneHangman

stage1:
	li $v0, 4
	la $a0, hang1
	syscall
	j doneHangman

stage2:
	li $v0, 4
	la $a0, hang2
	syscall
	j doneHangman

stage3:
	li $v0, 4
	la $a0, hang3
	syscall
	j doneHangman

stage4:
	li $v0, 4
	la $a0, hang4
	syscall
	j doneHangman

stage5:
	li $v0, 4
	la $a0, hang5
	syscall
	j doneHangman

stage6:
	li $v0, 4
	la $a0, hang6
	syscall

doneHangman:
	li $v0, 4
	la $a0, newLine
	syscall
.end_macro

.text
main:
	li ATTEMPTS_LEFT, 6
	li TOTAL_CHARACTERS, 0
	li REMAINING_CHARACTERS, 0
	li FOUND_CHARACTERS, 0
	
	jal selectRandomWord  #Choose Random Word
	
	setupGame
	printHangman
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
	printHangman
	printResult
	appendChar($t0)
	
	
	j getInput
	
selectRandomWord:
    li $v0, 42          # random int range
    li $a0, 0           # random generator id
    li $a1, WORD_COUNT  # random number in [0, WORD_COUNT-1]
    syscall

    move $t0, $a0       # t0 = random index
    sll $t0, $t0, 2     # multiply by 4 for word array offset

    la $t1, wordList
    add $t1, $t1, $t0
    lw $t2, 0($t1)      # t2 = address of chosen word

    la $t3, currentWord
    sw $t2, 0($t3)

    jr $ra

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