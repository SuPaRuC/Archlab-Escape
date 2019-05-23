.data
	
	####################################
	#                                  #
	#          Archlab Escape          #
	#     Unit Width in pixels: 16     #
	#    Unit Height in pixels: 16     #
	#   Display Width in pixels: 512   #
	#  Display Height in pixels: 512   #
	#        Base address: $gp         #
	#                                  #
	####################################
	
	# 119 -> W
	# 97 -> A
	# 115 -> S
	# 100 -> D
	
	welcomeMessage: .asciiz "Benvenuto!"
	
	# Coordinate dello schermo
	screenX: .word 32
	screenY: .word 32
	
	# Colori utilizzati
	door: .word 0x821717
	border: .word 0x0800ff
	room: .word 0x0072ff
	chest: .word 0xbc9401
	player: .word 0xff00b2
	corridor: .word 0x000000

.text
.globl main

	main:
	
	clearBackground:
	
		lw $t0, screenX
		lw $t1, corridor
		li $t2, 4
		
		# Pixel totali
		mult $t0, $t0 
		mflo $a0
		
		# Byte totali
		mult $a0, $t2 
		mflo $a2
		
		# Aggiungo base address
		add $a0, $a0, $a2
		add $a0, $a0, $gp 
		
		# Counter
		add $a1, $gp, $zero 
		
		whileNotClear:
			
			beq $a1, $a0, drawGamerLife
			
			sw $t1, 0($a1) 
			
			addi $a1, $a1, 4 
			
			j whileNotClear
			
	# Disegno la vita del giocatore
			
	drawGamerLife:

		# Stampo messaggio di benvenuto

		li $v0, 55
		la $a0, welcomeMessage
		li $a1, 1
		syscall
		
		j EndGame

	# Funzione Pause
	# $a0 -> numero di millisecondi per la pausa
	# La funzione non ritorna nulla
	
	Pause:
		
		li $v0, 32
		syscall
		jr $ra
		
	# Funzione GetCoordinate
	# $a0 -> coordinata x
	# $a1 -> coordinata y
	# RITORNO $v0 -> pixel da colorare
	
	GetCoordinate:
		
		lw $t8, screenX
		li $a2, 4
		
		#moltiplico la coordinata y per le dimensioni dello schermo
		mult $t8, $a1
		mflo $a3
		
		#aggiungo x
		add $a3, $a3, $a0
		
		#moltiplico per 4 -> numero bit totali
		mult $a3, $a2
		mflo $v0
		
		#aggiungo il base address
		add $v0, $v0, $gp
		
		#ritorno $v0
		jr $ra
		
	# Funzione Draw
	# $a0 -> pixel da colorare
	# $a1 -> colore
	# La funzione non ritorna nulla
	
	Draw:
	
		sw $a1, 0($a0)
		jr $ra
		
	# Funzione EndGame
	# Finisce il gioco, mostra il punteggio e chiede all'utente se vuole rigiocare
	
	EndGame:
		
		li $v0, 10
		syscall