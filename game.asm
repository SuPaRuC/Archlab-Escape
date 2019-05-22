.data
	
	welcomeMessage: .asciiz "Benvenuto!"

.text
.globl main

main:

	li $v0, 55
	la $a0, welcomeMessage
	li $a1, 1
	syscall