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
	
	# Questo gioco fa uso dei seguenti tools:
	# - Bitmap Display -> indicazioni fornite nell'area soprastante
	# - Keyboard Simulator 
	
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
	life: .word 0xff0004
	
	# Info sul gioco
	levelDifficulty: .asciiz "Seleziona difficoltà:\n1 - Facile\n2 - Normale\n3 - Difficile"
	easy: .word 8
	normal: .word 6
	hard: .word 4

.text
.globl main

	main:
	
		# Chiedo all'utente la difficoltà
		li $v0, 51
		la $a0, levelDifficulty
		syscall
		
		# Controllo se l'input è corretto
		beq $a0, 1, saveDiff
		beq $a0, 2, saveDiff
		beq $a0, 3, saveDiff
		
		# Altrmenti il gioco finisce
		j endGame
		
	# Se l'input è corretto salvo la difficoltà nel registro $s0
	saveDiff:
	
		# Controllo la difficoltà scelta
		beq $a0, 1, easyDiff
		beq $a0, 2, normalDiff
		beq $a0, 3, hardDiff
		
		# Se la difficoltà è 'facile'
		easyDiff:
			
			lw $s0, easy
			j clearBackground
			
		# Se la difficoltà è 'normale'
		normalDiff:
			
			lw $s0, normal
			j clearBackground
			
		# Se la difficoltà è 'difficile'
		hardDiff:
			
			lw $s0, hard
			j clearBackground
			
	# Salvata la difficoltà pulisco lo sfondo
	
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
	
		li $t0, 0
		li $t1, 31
	
		whileLife:
			
			beq $t0, $s0, drawTopBorder
			
			move $a0, $t1
			li $a1, 31
			jal GetCoordinate
		
			move $a0, $v0
			lw $a1, life
			jal Draw
			
			addi $t0, $t0, 1
			addi $t1, $t1, -1
			
			j whileLife
			
	# Una volta disegnata la vita disegno il campo esterno del gioco
	# $t0 -> counter
			
	drawTopBorder:
		
		li $t0, 0
		li $t1, 0
		
		whileTopBorder:
			
			beq $t0, 32, drawRightBorder
			
			move $a0, $t1
			li $a1, 0
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			
			j whileTopBorder
			
	drawRightBorder:
	
		li $t0, 0
		li $t1, 0
		
		whileRightBorder:
			
			beq $t0, 31, drawLeftBorder
			
			move $a1, $t1
			li $a0, 31
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			
			j whileRightBorder
			
	drawLeftBorder:
	
		li $t0, 0
		li $t1, 0
		
		whileLeftBorder:
		
			beq $t0, 32, drawNextLife
			
			li $a0, 0
			move $a1, $t1
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			
			j whileLeftBorder
			
	drawNextLife:
	
		li $t0, 0
		li $t1, 0
		li $t2, 32
		sub $t2, $t2, $s0
		
		whileNextLife:
				
			beq $t0, $t2, drawBottomBorder
				
			move $a0, $t1
			li $a1, 31
			jal GetCoordinate
				
			move $a0, $v0
			lw $a1, border
			jal Draw
				
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			
			j whileNextLife
				
	drawBottomBorder:
	
		li $t0, 0
		li $t1, 0
		
		whileBottomBorder:
			
			beq $t0, 32, drawRoom1
			
			move $a0, $t1
			li $a1, 30
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			
			j whileBottomBorder
			
	# Disegnato il design generale disegno le stanze
	# $t0, $t1 -> counters
	
	drawRoom1:
	
		li $t0, 0
		li $t1, 0
		li $t2, 1
		li $t3, 1
		
		whileRoom1Bottom:
			
			beq $t0, 6, whileRoom1Right
			
			move $a0, $t2
			li $a1, 6
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			
			j whileRoom1Bottom
			
		whileRoom1Right:
		
			beq $t1, 3, doorRoom1
			
			move $a1, $t3
			li $a0, 6
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t3, $t3, 1
			
			j whileRoom1Right
			
		# Disegno la porta + eventuali pixel mancanti
		doorRoom1:
		
			li $a0, 6
			li $a1, 4
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, door
			jal Draw
			
			li $a0, 6
			li $a1, 5
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			j init
		
	init:
	
		clearRegisters:
			
			li $v0, 0
			li $v1, 0
			li $a0, 0
			li $a1, 0
			li $a2, 0
			li $a3, 0
			li $t0, 0
			li $t1, 0
			li $t2, 0
			li $t3, 0
			li $t4, 0
			li $t5, 0
			li $t6, 0
			li $t7, 0
			li $t8, 0
			li $t9, 0 
		
	# Inizio della partita
	
	startGame:

		# Stampo messaggio di benvenuto

		li $v0, 55
		la $a0, welcomeMessage
		li $a1, 1
		syscall
		
	endGame:
		
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
		
		# Moltiplico la coordinata y per le dimensioni dello schermo
		mult $t8, $a1
		mflo $a3
		
		# Aggiungo x
		add $a3, $a3, $a0
		
		# Moltiplico per 4 -> numero bit totali
		mult $a3, $a2
		mflo $v0
		
		# Aggiungo il base address
		add $v0, $v0, $gp
		
		# Ritorno $v0
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
