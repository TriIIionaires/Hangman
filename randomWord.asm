#Kevin Chen, Zyad Elbialy, Jadon Malvar, Omer Muhammad
#Selects a random word

.data
.globl currentWord #allow other assembly files to access currentWord
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

wordList: .word word0, word1, word2, word3, word4, word5, word6, word7, word8, word9, word10, word11, word12, word13, word14, word15, word16, word17, word18, word19, word20, word21, word22, word23, word24, word25, word26, word27
.eqv WORD_COUNT 28

.text
.globl selectRandomWord #allow other assembly files to access selectRandomWord
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