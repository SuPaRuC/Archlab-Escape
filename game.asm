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
	openDoorMessage: .asciiz "Vuoi aprire la porta?"
	notOpenDoorMessage: .asciiz "La porta non si apre, devi trovare la chiave"
	looseMessage: .asciiz "Hai perso!\nVuoi ricominciare?"
	openChestMessage: .asciiz "Vuoi aprire la chest?"
	
	# Coordinate dello schermo
	screenX: .word 32
	screenY: .word 32
	
	# Colori utilizzati
	door: .word 0x821717
	lockedDoor: .word 0x7a1414
	border: .word 0x0800ff
	room: .word 0x0072ff
	chest: .word 0xbc9401
	player: .word 0xff00b2
	corridor: .word 0x000000
	life: .word 0xff0004
	stairs: .word 0x6a6f77
	
	# Info sul gioco
	levelDifficulty: .asciiz "Seleziona difficoltà:\n1 - Facile\n2 - Normale\n3 - Difficile"
	easy: .word 8
	normal: .word 6
	hard: .word 4
	
	# Posizione del giocatore
	playerX: .word 12
	playerY: .word 27

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
			j initPlayerPosition
			
		# Se la difficoltà è 'normale'
		normalDiff:
			
			lw $s0, normal
			j initPlayerPosition
			
		# Se la difficoltà è 'difficile'
		hardDiff:
			
			lw $s0, hard
			j initPlayerPosition
			
	initPlayerPosition:
	
		clearPlayerPosition:
		
			# Risistemo il giocatore
			li $a0, 12
			sw $a0, playerX
			li $a0, 27
			sw $a0, playerY
			
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
			
			j drawRoom2
			
	drawRoom2:
	
		li $t0, 0
		li $t1, 0
		li $t2, 22
		li $t3, 1
	
		whileRoom2Right:
		
			beq $t0, 8, whileRoom2Top
			
			move $a1, $t2
			li $a0, 8
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			
			j whileRoom2Right
			
		whileRoom2Top:
		
			beq $t1, 4, doorRoom2
			
			move $a0, $t3
			li $a1, 22
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t3, $t3, 1
			
			j whileRoom2Top
			
		doorRoom2:
		
			li $a0, 5
			li $a1, 22
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, door
			jal Draw
			
			li $a0, 6
			li $a1, 22
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			li $a0, 7
			li $a1, 22
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			j drawRoom3
			
			
	# Aggiunto counter $t3 perchè ci sono 3 pareti
	
	drawRoom3:
	
		li $t0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 1
		li $t4, 1
		li $t5, 15
		
		whileRoom3Left:
		
			beq $t0, 5, whileRoom3Right
			
			move $a1, $t3
			li $a0, 13
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t3, $t3, 1
			
			j whileRoom3Left
			
		whileRoom3Right:
		
			beq $t1, 5, whileRoom3Bottom
			
			move $a1, $t4
			li $a0, 18
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t4, $t4, 1
			
			j whileRoom3Right
			
		whileRoom3Bottom:
		
			beq $t2, 3, doorRoom3
			
			move $a0, $t5
			li $a1, 5
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t2, $t2, 1
			addi $t5, $t5, 1
			
			j whileRoom3Bottom
			
		doorRoom3:
		
			li $a0, 14
			li $a1, 5
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, lockedDoor
			jal Draw
			
			# Disegno la chest
			
			li $a0, 17
			li $a1, 1
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, chest
			jal Draw
			
			j drawRoom4
			
	drawRoom4:
	
		li $t0, 0
		li $t1, 0
		li $t3, 1
		li $t4, 1
		
		whileRoom4Top:
		
			beq $t0, 10, whileRoom4Bottom
			
			move $a0, $t3
			li $a1, 11
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t3, $t3, 1
			
			j whileRoom4Top
			
		whileRoom4Bottom:
		
			beq $t1, 10, drawMissingPartsRoom4
			
			move $a0, $t4
			li $a1, 17
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t4, $t4, 1
			
			j whileRoom4Bottom
			
		drawMissingPartsRoom4:
		
			li $a0, 10
			li $a1, 12
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			li $a0, 10
			li $a1, 13
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			li $a0, 10
			li $a1, 15
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			li $a0, 10
			li $a1, 16
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			# Disegno la porta
			
			li $a0, 10
			li $a1, 14
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, lockedDoor
			jal Draw
			
			# Disegno la chest1
			
			li $a0, 1
			li $a1, 12
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, chest
			jal Draw
			
			# Disegno la chest2
			
			li $a0, 6
			li $a1, 16
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, chest
			jal Draw
			
			j drawRoom5
			
	drawRoom5:
	
		li $t0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 24
		li $t4, 24
		li $t5, 17
		
		whileRoom5Left:
		
			beq $t0, 6, whileRoom5Right
			
			move $a1, $t3
			li $a0, 16
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t3, $t3, 1
			
			j whileRoom5Left
			
		whileRoom5Right:
		
			beq $t1, 6, whileRoom5Top
			
			move $a1, $t4
			li $a0, 23
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t4, $t4, 1
			
			j whileRoom5Right
			
		whileRoom5Top:
		
			beq $t2, 3, drawMissingPartsRoom5
			
			move $a0, $t5
			li $a1, 24
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t2, $t2, 1
			addi $t5, $t5, 1
			
			j whileRoom5Top
			
		drawMissingPartsRoom5:
		
			li $a0, 21
			li $a1, 24
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			li $a0, 22
			li $a1, 24
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			# Disegno la porta
			li $a0, 20
			li $a1, 24
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, door
			jal Draw
			
			# Disegno la chest
			li $a0, 22
			li $a1, 29
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, chest
			jal Draw
			
			j drawRoom6
			
	drawRoom6:
	
		# Aggiunto un counter perchè ci sono 4 pareti
	
		li $t0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 0
		li $t4, 11
		li $t5, 11
		li $t6, 20
		li $t7, 22
		
		whileRoom6Left:
		
			beq $t0, 7, whileRoom6Right
			
			move $a1, $t4
			li $a0, 19
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t4, $t4, 1
			
			j whileRoom6Left
			
		whileRoom6Right:
		
			beq $t1, 7, whileRoom6Top
			
			move $a1, $t5
			li $a0, 27
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t5, $t5, 1
			
			j whileRoom6Right
			
		whileRoom6Top:
		
			beq $t2, 5, whileRoom6Bottom
			
			move $a0, $t6
			li $a1, 11
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t2, $t2, 1
			addi $t6, $t6, 1
			
			j whileRoom6Top
			
		whileRoom6Bottom:
		
			beq $t3, 5, drawMissingPartsRoom6
			
			move $a0, $t7
			li $a1, 17
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t3, $t3, 1
			addi $t7, $t7, 1
			
			j whileRoom6Bottom
			
		drawMissingPartsRoom6:
			
			li $a0, 26
			li $a1, 11
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			li $a0, 20
			li $a1, 17
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			# Disegno la porta1
			
			li $a0, 25
			li $a1, 11
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, lockedDoor
			jal Draw
			
			# Disegno la porta2
			
			li $a0, 21
			li $a1, 17
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, lockedDoor
			jal Draw
			
			# Disegno la chest
			
			li $a0, 23
			li $a1, 14
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, chest
			jal Draw
			
			j drawRoom7
			
	drawRoom7:
	
		li $t0, 0
		li $t1, 0
		li $t2, 22
		li $t3, 1
		
		whileRoom7Bottom:
		
			beq $t0, 9, whileRoom7Left
			
			move $a0, $t2
			li $a1, 8
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			
			j whileRoom7Bottom
			
		whileRoom7Left:
			
			beq $t1, 5, drawMissingPartsRoom7
			
			move $a1, $t3
			li $a0, 22
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw
			
			addi $t1, $t1, 1
			addi $t3, $t3, 1
			
			j whileRoom7Left
			
		drawMissingPartsRoom7:
		
			li $a0, 22
			li $a1, 7
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, border
			jal Draw	
			
			# Disegno la porta
			
			li $a0, 22
			li $a1, 6
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, lockedDoor
			jal Draw
			
			j drawStairs
			
		drawStairs:
			
			li $a0, 29
			li $a1, 1
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, stairs
			jal Draw
				
			li $a0, 30
			li $a1, 1
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, stairs
			jal Draw
				
			li $a0, 29
			li $a1, 2
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, stairs
			jal Draw
				
			li $a0, 30
			li $a1, 2
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, stairs
			jal Draw
				
			# Se si vuole aggiungere lo sfondo alla stanza uno e due decommentare questa linea
			#j drawRoom1BG
				
			j drawPlayer
			
	drawRoom1BG:
	
		li $t0, 0
		li $t1, 0
		li $t2, 1
		li $t3, 1
					
		whileNotAllRoom1:
		
			beq $t0, 25, drawRoom2BG
			
			beq $t1, 5, fullRowRoom1
			
			j goRoom1
			
			fullRowRoom1:
			
				li $t1, 0
				addi $t3, $t3, 1
				li $t2, 1
				
			goRoom1:
			
				move $a0, $t2
				move $a1, $t3
				jal GetCoordinate
				
				move $a0, $v0
				lw $a1, room
				jal Draw
				
				addi $t2, $t2, 1
				addi $t1, $t1, 1
				addi $t0, $t0, 1
				
				j whileNotAllRoom1
				
	drawRoom2BG:
	
		li $t0, 0
		li $t1, 0
		li $t2, 1
		li $t3, 23
					
		whileNotAllRoom2:
		
			beq $t0, 49, drawPlayer
			
			beq $t1, 7, fullRowRoom2
			
			j goRoom2
			
			fullRowRoom2:
			
				li $t1, 0
				addi $t3, $t3, 1
				li $t2, 1
				
			goRoom2:
			
				move $a0, $t2
				move $a1, $t3
				jal GetCoordinate
				
				move $a0, $v0
				lw $a1, room
				jal Draw
				
				addi $t2, $t2, 1
				addi $t1, $t1, 1
				addi $t0, $t0, 1
				
				j whileNotAllRoom2
				
	drawPlayer:
	
		lw $a0, playerX
		lw $a1, playerY
		jal GetCoordinate
		
		move $a0, $v0
		lw $a1, player
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
			li $s2, 0
		
	# Inizio della partita
	
	startGame:

		# Stampo messaggio di benvenuto

		li $v0, 55
		la $a0, welcomeMessage
		li $a1, 1
		syscall
		
	input:
	
		# Prendo l'input da tastiera
		li $t0, 0xffff0000
		lw $t1, ($t0)
		andi $t1, $t1, 0x0001
		
		# Se l'utente non inserisce un nuovo input non faccio nulla
		beqz $t1, doNothing
			
		# Salvo la direzione per l'update
		lw $a2, 4($t0)
		
		j updatePlayerPosition
		
	updatePlayerPosition:
		
		# Direzione update
		beq $a2, 97, updatePlayerLeft
		beq $a2, 100, updatePlayerRight
		beq $a2, 115, updatePlayerBottom
		beq $a2, 119, updatePlayerTop
		
		updatePlayerLeft:
				
			lw $a0, playerX
			lw $a1, playerY	
			
			# In $t5 salvo la direzione
			move $t5, $a2
			
			jal CheckPlayerMovement
			
			beqz $v0, updateRoom
			
			# In $t3, $t4 salvo la posizione del giocatore
			move $t3, $a0
			move $t4, $a1
			
			beq $v0, 2, openDoor
			beq $v0, 3, openLockedDoor
			beq $v0, 4, openChest
			
			# Cancello la vecchia posizione
			lw $a0, playerX
			lw $a1, playerY
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
				
			# Disegno quella nuova								
			lw $a0, playerX
			lw $a1, playerY
			addi $a0, $a0, -1
			
			# Salvo la nuova posizione
			sw $a0, playerX
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, player
			jal Draw
			
			# Torno a chiedere l'input
			j updateRoom
			
		updatePlayerRight:
		
			lw $a0, playerX
			lw $a1, playerY
			
			# In $t5 salvo la direzione
			move $t5, $a2
			
			jal CheckPlayerMovement
			
			beqz $v0, updateRoom
			
			# In $t3, $t4 salvo la posizione del giocatore
			move $t3, $a0
			move $t4, $a1
			
			beq $v0, 2, openDoor
			beq $v0, 3, openLockedDoor
			beq $v0, 4, openChest
				
			# Cancello la vecchia posizione
			lw $a0, playerX
			lw $a1, playerY
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
				
			# Disegno quella nuova								
			lw $a0, playerX
			lw $a1, playerY
			addi $a0, $a0, 1
			
			# Salvo la nuova posizione
			sw $a0, playerX
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, player
			jal Draw
			
			# Torno a chiedere l'input
			j updateRoom
			
		updatePlayerBottom:
		
			lw $a0, playerX
			lw $a1, playerY	
			
			# In $t5 salvo la direzione
			move $t5, $a2
			
			jal CheckPlayerMovement
			
			beqz $v0, updateRoom
			
			# In $t3, $t4 salvo la posizione del giocatore
			move $t3, $a0
			move $t4, $a1
			
			beq $v0, 2, openDoor
			beq $v0, 3, openLockedDoor
			beq $v0, 4, openChest
				
			# Cancello la vecchia posizione
			lw $a0, playerX
			lw $a1, playerY
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
				
			# Disegno quella nuova								
			lw $a0, playerX
			lw $a1, playerY
			addi $a1, $a1, 1
			
			# Salvo la nuova posizione
			sw $a1, playerY
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, player
			jal Draw
			
			# Torno a chiedere l'input
			j updateRoom
			
		updatePlayerTop:
		
			lw $a0, playerX
			lw $a1, playerY
			
			# In $t5 salvo la direzione
			move $t5, $a2
			
			jal CheckPlayerMovement
			
			beqz $v0, updateRoom
		
			# In $t3, $t4 salvo la posizione del giocatore
			move $t3, $a0
			move $t4, $a1
			
			beq $v0, 2, openDoor
			beq $v0, 3, openLockedDoor
			beq $v0, 4, openChest
				
			# Cancello la vecchia posizione
			lw $a0, playerX
			lw $a1, playerY
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
				
			# Disegno quella nuova								
			lw $a0, playerX
			lw $a1, playerY
			addi $a1, $a1, -1
			
			# Salvo la nuova posizione
			sw $a1, playerY
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, player
			jal Draw
			
			# Torno a chiedere l'input
			j updateRoom
			
	openDoor:
	
		la $a0, openDoorMessage
		li $v0, 50
		syscall
		
		beq $a0, 1, updateRoom
		beq $a0, 2, updateRoom
		
		beq $t5, 97, openLeft
		beq $t5, 100, openRight
		beq $t5, 115, openDown
		beq $t5, 119, openUp
		
		openLeft:
		
			move $a0, $t3
			move $a1, $t4
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
			
			j opened
			
		openRight:
		
			move $a0, $t3
			move $a1, $t4
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
			
			j opened
			
		openDown:
		
			move $a0, $t3
			move $a1, $t4
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
			
			j opened
			
		openUp:
		
			move $a0, $t3
			move $a1, $t4
			jal GetCoordinate
			
			move $a0, $v0
			lw $a1, corridor
			jal Draw
			
			j opened
		
		opened:
			j updateRoom
		
	openLockedDoor:
	
		la $a0, openDoorMessage
		li $v0, 50
		syscall
		
		beq $a0, 1, input
		beq $a0, 2, input
		
		la $a0, notOpenDoorMessage
		li $a1, 1
		li $v0, 55
		syscall
		
		j updateRoom
		
	openChest:
	
		la $a0, openChestMessage
		li $v0, 50
		syscall
	
		j updateRoom
		
	updateRoom:
	
		lw $a0, playerX
		lw $a1, playerY
		
		jal GetCoordinate
		move $t0, $v0
		
		# Porta 1
		li $a0, 6
		li $a1, 4
		jal GetCoordinate
		beq $t0, $v0, room1
		
		# Porta 2
		li $a0, 5
		li $a1, 22
		jal GetCoordinate
		beq $t0, $v0, room2
		
		# Porta 3
		li $a0, 14
		li $a1, 5
		jal GetCoordinate
		beq $t0, $v0, room3
		
		# Porta 4
		li $a0, 10
		li $a1, 14
		jal GetCoordinate
		beq $t0, $v0, room4
		
		# Porta 5
		li $a0, 20
		li $a1, 24
		jal GetCoordinate
		beq $t0, $v0, room5
		
		# Porta 6
		li $a0, 21
		li $a1, 17
		jal GetCoordinate
		beq $t0, $v0, room6
		li $a0, 25
		li $a1, 11
		jal GetCoordinate
		beq $t0, $v0, room6
		
		# Porta 7
		
		li $a0, 22
		li $a1, 6
		jal GetCoordinate
		beq $t0, $v0, room7
				
		# In caso di errori
		j endUpdateRoom
			
		room1:
			
			beq $s1, 1, default
			li $s1, 1
			j endUpdateRoom
				
		room2:
			
			beq $s1, 2, default
			li $s1, 2
			j endUpdateRoom
				
		room3:
			
			beq $s1, 3, default
			li $s1, 3
			j endUpdateRoom
				
		room4:
			
			beq $s1, 4, default
			li $s1, 4
			j endUpdateRoom
				
		room5:
			
			beq $s1, 5, default
			li $s1, 5
			j endUpdateRoom
				
		room6:
			
			beq $s1, 6, default
			li $s1, 6
			j endUpdateRoom
			
		room7:
			
			beq $s1, 7, default
			li $s1, 7
			j endUpdateRoom
		
		default:
		
			li $s1, 0
			j endUpdateRoom
				
		endUpdateRoom:
		
			j updateLife
			
	updateLife:
		
		beq $s0, 8, updateEasy
		beq $s0, 6, updateNormal
		beq $s0, 4, updateHard
		
		updateEasy:
			
			# Counter
			li $t0, 0
			
			# Pixel to color
			li $t1, 24
			
			whileUpdateEasy:
			
				beq $t0, $s2, input
				bge $s2, 8, endGame
				
				move $a0, $t1
				li $a1, 31
				jal GetCoordinate
				
				move $a0, $v0
				lw $a1, corridor
				jal Draw
				
				addi $t0, $t0, 1
				addi $t1, $t1, 1
				
				j whileUpdateEasy
				
		
		updateNormal:
		
			
			# Counter
			li $t0, 0
			
			# Pixel to color
			li $t1, 26
			
			whileUpdateNormal:
			
				beq $t0, $s2, input
				bge $s2, 6, endGame
				
				move $a0, $t1
				li $a1, 31
				jal GetCoordinate
				
				move $a0, $v0
				lw $a1, corridor
				jal Draw
				
				addi $t0, $t0, 1
				addi $t1, $t1, 1
				
				j whileUpdateNormal
		
		updateHard:
		
			
			# Counter
			li $t0, 0
			
			# Pixel to color
			li $t1, 28
			
			whileUpdateHard:
			
				beq $t0, $s2, input
				bge $s2, 4, endGame
				
				move $a0, $t1
				li $a1, 31
				jal GetCoordinate
				
				move $a0, $v0
				lw $a1, corridor
				jal Draw
				
				addi $t0, $t0, 1
				addi $t1, $t1, 1
				
				j whileUpdateHard
			
		
	doNothing:
	
		j input	
	
	endGame:
	
		li $a0, 31
		li $a1, 31
		jal GetCoordinate
		
		move $a0, $v0
		lw $a1, corridor
		jal Draw
		
		li $v0, 50
		la $a0, looseMessage
		syscall
		
		beq $a0, 0, main
		
		j EndGame
		
	# Funzione CheckPlayerMovement
	# $a0 -> playerX
	# $a1 -> playerY
	# $a2 -> movimento desiderato dell'utente
	# RITORNO $v0 -> 0 se non devo fare niente 1 se può muoversi 2 se la porta è aperta 3 se la porta è bloccata 4 se vuole aprire una chest
	CheckPlayerMovement:
	
		# Salvo dove sono nello stack dato che dovrò chiamare un'altra funzione
		sw $ra, 0($sp)
	
		lw $t9, border
		lw $t6, lockedDoor
		lw $t7, door
		lw $s7, chest
	
		beq $a2, 100, checkPlayerRight
		beq $a2, 97, checkPlayerLeft
		beq $a2, 119, checkPlayerTop
		beq $a2, 115, checkPlayerBottom
		
		checkPlayerRight:
		
			# Aggiungo 1 per andare a destra
			addi $a0, $a0, 1
			jal GetCoordinate
			
			lw $a3, 0($v0)
			
			beq $a3, $t9, setToZero
			beq $a3, $t6, setToThree
			beq $a3, $t7, setToTwo
			beq $a3, $s7, setToFour
			
			li $v0, 1
			j endCheck
			
		checkPlayerLeft:
		
			# Sottraggo 1 per andare a sinistra
			addi $a0, $a0, -1
			jal GetCoordinate
			
			lw $a3, 0($v0)
			
			beq $a3, $t9, setToZero
			beq $a3, $t6, setToThree
			beq $a3, $t7, setToTwo
			beq $a3, $s7, setToFour
			
			li $v0, 1
			j endCheck
			
		checkPlayerTop:
		
			# Sottraggo 1 per andare in alto
			addi $a1, $a1, -1
			jal GetCoordinate
			
			lw $a3, 0($v0)
			
			beq $a3, $t9, setToZero
			beq $a3, $t6, setToThree
			beq $a3, $t7, setToTwo
			beq $a3, $s7, setToFour
			
			li $v0, 1
			j endCheck
			
		checkPlayerBottom:
		
			# Aggiungo 1 per andare in basso
			addi $a1, $a1, 1
			jal GetCoordinate
			
			lw $a3, 0($v0)
			
			beq $a3, $t9, setToZero
			beq $a3, $t6, setToThree
			beq $a3, $t7, setToTwo
			beq $a3, $s7, setToFour
			
			li $v0, 1
			j endCheck
			
		setToZero:
		
			li $v0, 0
			j endCheck	
			
		setToTwo:
		
			li $v0, 2
			j endCheck
			
		setToThree:
		
			li $v0, 3
			j endCheck
			
		setToFour:
		
			li $v0, 4 
			j endCheck
		
		endCheck:
		
			lw $ra, 0($sp)
			jr $ra

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
