################################################################################
#                  Fonctions d'affichage et d'entrée clavier                   #
################################################################################

# Ces fonctions s'occupent de l'affichage et des entrées clavier.
# Il n'est pas nécessaire de les modifier.!!!

.data

# Tampon d'affichage du jeu 256*256 de manière linéaire.

frameBuffer: .word 0 : 1024  # Frame buffer

# Code couleur pour l'affichage
# Codage des couleurs 0xwwxxyyzz où
#   ww = 00
#   00 <= xx <= ff est la couleur rouge en hexadécimal
#   00 <= yy <= ff est la couleur verte en hexadécimal
#   00 <= zz <= ff est la couleur bleue en hexadécimal

colors: .word 0x00000000, 0x00ff0000, 0xff00ff00, 0x00396239, 0x00ff00ff
.eqv black 0
.eqv red   4
.eqv green 8
.eqv greenV2  12
.eqv rose  16

# Dernière position connue de la queue du serpent.

lastSnakePiece: .word 0, 0

.text
j main

############################# printColorAtPosition #############################
# Paramètres: $a0 La valeur de la couleur
#             $a1 La position en X
#             $a2 La position en Y
# Retour: Aucun
# Effet de bord: Modifie l'affichage du jeu
################################################################################

printColorAtPosition:
lw $t0 tailleGrille
mul $t0 $a1 $t0
add $t0 $t0 $a2
sll $t0 $t0 2
sw $a0 frameBuffer($t0)
jr $ra

################################ resetAffichage ################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Réinitialise tout l'affichage avec la couleur noir
################################################################################

resetAffichage:
lw $t1 tailleGrille
mul $t1 $t1 $t1
sll $t1 $t1 2
la $t0 frameBuffer
addu $t1 $t0 $t1
lw $t3 colors + black

RALoop2: bge $t0 $t1 endRALoop2
  sw $t3 0($t0)
  add $t0 $t0 4
  j RALoop2
endRALoop2:
jr $ra

################################## printSnake ##################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement ou se
#                trouve le serpent et sauvegarde la dernière position connue de
#                la queue du serpent.
################################################################################

printSnake:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 tailleSnake
sll $s0 $s0 2
li $s1 0

lw $a0 colors + greenV2
lw $a1 snakePosX($s1)
lw $a2 snakePosY($s1)
jal printColorAtPosition
li $s1 4

lw $a0 colors + green		# On définit la couleur du premier pixel de la queue
PSLoop:
bge $s1 $s0 endPSLoop
  lw $a1 snakePosX($s1)
  lw $a2 snakePosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  addi $a0 $a0 -3570	    # On change la couleur d'impression à chaque nouveau pixel
  j PSLoop
endPSLoop:

subu $s0 $s0 4
lw $t0 snakePosX($s0)
lw $t1 snakePosY($s0)
sw $t0 lastSnakePiece
sw $t1 lastSnakePiece + 4

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################ printObstacles ################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement des obstacles.
################################################################################

printObstacles:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 numObstacles
sll $s0 $s0 2
li $s1 0

POLoop:
bge $s1 $s0 endPOLoop
  lw $a0 colors + red
  lw $a1 obstaclesPosX($s1)
  lw $a2 obstaclesPosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  j POLoop
endPOLoop:

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################## printCandy ##################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage à l'emplacement du bonbon.
################################################################################

printCandy:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + rose
lw $a1 candy
lw $a2 candy + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

eraseLastSnakePiece:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + black
lw $a1 lastSnakePiece
lw $a2 lastSnakePiece + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

################################## printGame ###################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Effectue l'affichage de la totalité des éléments du jeu.
################################################################################

printGame:
subu $sp $sp 4
sw $ra 0($sp)

jal eraseLastSnakePiece
jal printSnake
jal printObstacles
jal printCandy

lw $ra 0($sp)
addu $sp $sp 4
jr $ra

############################## getRandomExcluding ##############################
# Paramètres: $a0 Un entier x | 0 <= x < tailleGrille
# Retour: $v0 Un entier y | 0 <= y < tailleGrille, y != x
################################################################################

getRandomExcluding:
move $t0 $a0
lw $a1 tailleGrille
li $v0 42
syscall
beq $t0 $a0 getRandomExcluding
move $v0 $a0
jr $ra

########################### newRandomObjectPosition ############################
# Description: Renvoie une position aléatoire sur un emplacement non utilisé
#              qui ne se trouve pas devant le serpent.
# Paramètres: Aucun
# Retour: $v0 Position X du nouvel objet
#         $v1 Position Y du nouvel objet
################################################################################

newRandomObjectPosition:
subu $sp $sp 4
sw $ra ($sp)

lw $t0 snakeDir
or $t0 0x2
bgtz $t0 horizontalMoving
li $v0 42
lw $a1 tailleGrille
syscall
move $t8 $a0
lw $a0 snakePosY
jal getRandomExcluding
move $t9 $v0
j endROPdir

horizontalMoving:
lw $a0 snakePosX
jal getRandomExcluding
move $t8 $v0
lw $a1 tailleGrille
li $v0 42
syscall
move $t9 $a0
endROPdir:

lw $t0 tailleSnake
sll $t0 $t0 2
la $t0 snakePosX($t0)
la $t1 snakePosX
la $t2 snakePosY
li $t4 0

ROPtestPos:
bge $t1 $t0 endROPtestPos
lw $t3 ($t1)
bne $t3 $t8 ROPtestPos2
lw $t3 ($t2)
beq $t3 $t9 replayROP
ROPtestPos2:
addu $t1 $t1 4
addu $t2 $t2 4
j ROPtestPos
endROPtestPos:

bnez $t4 endROP

lw $t0 numObstacles
sll $t0 $t0 2
la $t0 obstaclesPosX($t0)
la $t1 obstaclesPosX
la $t2 obstaclesPosY
li $t4 1
j ROPtestPos

endROP:
move $v0 $t8
move $v1 $t9
lw $ra ($sp)
addu $sp $sp 4
jr $ra

replayROP:
lw $ra ($sp)
addu $sp $sp 4
j newRandomObjectPosition

################################# getInputVal ##################################
# Paramètres: Aucun
# Retour: $v0 La valeur 0 (haut), 1 (droite), 2 (bas), 3 (gauche), 4 erreur
################################################################################

getInputVal:
lw $t0 0xffff0004
li $t1 115
beq $t0 $t1 GIhaut
li $t1 122
beq $t0 $t1 GIbas
li $t1 113
beq $t0 $t1 GIgauche
li $t1 100
beq $t0 $t1 GIdroite
li $v0 4
j GIend

GIhaut:
li $v0 0
j GIend

GIdroite:
li $v0 1
j GIend

GIbas:
li $v0 2
j GIend

GIgauche:
li $v0 3

GIend:
jr $ra

################################ sleepMillisec #################################
# Paramètres: $a0 Le temps en milli-secondes qu'il faut passer dans cette
#             fonction (approximatif)
# Retour: Aucun
################################################################################

sleepMillisec:
move $t0 $a0
li $v0 30
syscall
addu $t0 $t0 $a0

SMloop:
bgt $a0 $t0 endSMloop
li $v0 30
syscall
j SMloop

endSMloop:
jr $ra

##################################### main #####################################
# Description: Boucle principale du jeu
# Paramètres: Aucun
# Retour: Aucun
################################################################################

main:

# Initialisation du jeu

jal resetAffichage
jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4

# Boucle de jeu

mainloop:

jal getInputVal
move $a0 $v0
jal majDirection
jal updateGameStatus
jal conditionFinJeu
bnez $v0 gameOver
jal printGame
lw $a0 speed                    # Pour accélérer le jeu
jal sleepMillisec
j mainloop

gameOver:
jal affichageFinJeu
li $v0 10
syscall

################################################################################
#                                Partie Projet                                 #
################################################################################

# À vous de jouer !

.data

tailleGrille:  .word 16        # Nombre de case du jeu dans une dimension.

# La tête du serpent se trouve à (snakePosX[0], snakePosY[0]) et la queue à
# (snakePosX[tailleSnake - 1], snakePosY[tailleSnake - 1])
tailleSnake:   .word 1         # Taille actuelle du serpent.
snakePosX:     .word 0 : 1024  # Coordonnées X du serpent ordonné de la tête à la queue.
snakePosY:     .word 0 : 1024  # Coordonnées Y du serpent ordonné de la t.

# Les directions sont représentés sous forme d'entier allant de 0 à 3:
snakeDir:      .word 4         # Direction du serpent: 0 (haut), 1 (droite)
                               #                       2 (bas), 3 (gauche)
numObstacles:  .word 0         # Nombre actuel d'obstacle présent dans le jeu.
obstaclesPosX: .word 0 : 1024  # Coordonnées X des obstacles
obstaclesPosY: .word 0 : 1024  # Coordonnées Y des obstacles
candy:         .word 0, 0      # Position du bonbon (X,Y)
scoreJeu:      .word 0         # Score obtenu par le joueur
speed:         .word 400       # Vitesse du jeu

# Le score est affiché à la fin du jeu, accompagné d'un message :
motGentil1: .asciiz "Score final : "                        # Message précédent l'affichage du score du jeu
motGentil2: .asciiz " points.\nPeut mieux faire !\n"        # Fin de la ligne du score et message final, très encourageant
motUnPeuPlusGentil: .asciiz " points.\nÇa va.\n"            # Idem, pour les joueurs considérés comme moyens
motVraimentGentil:  .asciiz " points.\nPas mal du tout.\n"  # Idem, pour les joueurs considérés comme bons

# Matrice du message graphique :
gOMessage:     .word 0 1 0 0 1 0 0 1 0 0 0 1 0 1 1 1
	           .word 1 0 0 1 0 1 0 1 1 0 1 1 0 1 0 0
	           .word 1 0 0 1 0 1 0 1 0 1 0 1 0 1 1 1
	           .word 1 1 0 1 1 1 0 1 0 1 0 1 0 1 0 0
	           .word 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0
	           .word 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1
	           .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	           .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	           .word 0 1 0 0 1 0 1 0 1 1 1 0 1 1 1 1
	           .word 1 0 1 0 1 0 1 0 1 0 0 0 1 0 0 1
	           .word 1 0 1 0 1 0 1 0 1 1 1 0 1 0 0 1
	           .word 1 0 1 0 1 0 1 0 1 0 0 0 1 1 1 0
	           .word 1 0 1 0 0 1 0 0 1 0 0 0 1 0 1 0
	           .word 0 1 0 0 0 1 0 0 1 1 1 0 1 0 0 1

.text

################################# majDirection #################################
# Paramètres: $a0 La nouvelle position demandée par l'utilisateur. La valeur
#                 étant le retour de la fonction getInputVal.
# Retour: Aucun
# Effet de bord: La direction du serpent à été mise à jour.
# Post-condition: La valeur du serpent reste intacte si une commande illégale
#                 est demandée, i.e. le serpent ne peut pas faire un demi-tour 
#                 (se retourner en un seul tour. Par exemple passer de la 
#                 direction droite à gauche directement est impossible (un 
#                 serpent n'est pas une chouette)
################################################################################

majDirection:
lw $t0 snakeDir
addi $t1 $t0 2             # addi et rem permettent de faire +2 modulo 4 ce qui revient a 
rem $t6 $t1 4              #  Calculer la direction opposée (si dir=2 (descndre) alors res=0 (monter))

beq $t6 $a0 comeback       # On teste si la direction demandé est l'opposée de la précédente (direction non-valide)
bgt $a0 3 exitdir          # Si une mauvaise touche est rentrée, on garde le mouvement précédent
  
sw $a0 snakeDir            # Si direction valide on la met à jour
j exitdir

comeback:
sw $t0 snakeDir             # Si c'est bien la direction opposée, alors on implante à nouveau l'ancienne direction pour continuer tout droit

exitdir:
jr $ra

############################### updateGameStatus ###############################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: L'état du jeu est mis à jour d'un pas de temps. Il faut donc :
#                  - Faire bouger le serpent
#                  - Tester si le serpent à manger le bonbon
#                    - Si oui déplacer le bonbon et ajouter un nouvel obstacle
#                La vitesse du serpent augmente avec chaque bonbon mangé.
#                Le score est mis à jour. 
################################################################################

updateGameStatus:
lw $t1 tailleSnake          # Prendre la taille du snake
mul $t1 $t1 4

loopi:                      # Boucle qui prend la position de
beqz $t1 endloop            # l'avant dernier morceau du snake
addi $t2 $t1 -4             # et la donne au dernier morceau,
lw $t8 snakePosX($t2)       # puis refait pareil pour l'avant-
lw $t9 snakePosY($t2)       # -dernier morceau etc...,
sw $t8 snakePosX($t1)       # jusqu'à arriver à la position
sw $t9 snakePosY($t1)       # de la tête
addi $t1 $t1 -4             #
j loopi                     # ATTENTION : ne met à jour que le
endloop:                    # corps et non la tête

lw $t7 snakeDir
lw $t5 snakePosX($0)
lw $t6 snakePosY($0)
beq $t7 0 monte               # Vérifie si le serpent monte
beq $t7 1 droite              # Vérifie si le serpent va à droite
beq $t7 2 descend             # Vérifie si le serpent descend
beq $t7 3 gauche              # Vérifie si le serpent va à gauche
j exitupgs

# Mouvements
#===========
monte:                        # Mise à jour de la tête
addi $t5 $t5 1                # en fonction de snakeDir
j fin_update

droite:
addi $t6 $t6 1
j fin_update

descend:
addi $t5 $t5 -1
j fin_update

gauche:
addi $t6 $t6 -1
    
fin_update:
sw $t5 snakePosX($0)
sw $t6 snakePosY($0)

# Bonbons
#========
testcandy:                    # Compare la postion de la tete avec celle du bonbon
lw $t5 snakePosX($0)
lw $t6 snakePosY($0)
lw $t3 candy
lw $t4 candy + 4
beq $t5 $t3 candyclose        # Test avec X
j exitupgs
    
candyclose:
beq $t6 $t4 candyeaten        # Test avec Y
j exitupgs

candyeaten:                   # Le serpent a mangé le bonbon :

subu $sp $sp 4                # Déplace l'adresse stockée dans $ra
sw $ra ($sp)                  # pour pouvoir jal dans un jal
  
# Vitesse et score
#=================
lw $t0 scoreJeu
addi $t0 $t0 5                # Met à jour le score : cinq points pour chaque bonbon mangé
sw $t0 scoreJeu
  
lw $t0 speed
addi $t0 $t0 -15              # Augmentation de la vitesse du jeu
sw $t0 speed

jal newRandomObjectPosition   # Demande une nouvelle postion aleatoire
sw $v0 candy                  # Met posX aléatoire dans candyPosX
sw $v1 candy + 4              # Met posY aléatoire dans candyPosY

lw $t0 tailleSnake
addi $t2 $t0 1                # Augmentation de la taille du serpent de 1
sw $t2 tailleSnake

# Obstacles
#==========
lw $t7 numObstacles 
addi $t0 $t7 1                # Augmentation du nombre d'obstacles
sw $t0 numObstacles

mul $t7 $t7 4
jal newRandomObjectPosition   # Demande une nouvelle position aléatoire
sw $v0 obstaclesPosX($t7)     # Enregistre dans nouvelle case
sw $v1 obstaclesPosY($t7)     # du tableau pour en avoir plusieurs

lw $ra ($sp)                  # On récupere l'adresse qu'on avait
addu $sp $sp 4                # stockée dans la pile pour pouvoir jr $ra

exitupgs:
jr $ra

############################### conditionFinJeu ################################
# Paramètres: Aucun
# Retour: $v0 La valeur 0 si le jeu doit continuer ou toute autre valeur sinon.
################################################################################

conditionFinJeu:

# On va comparer la position de la tête à celle des autres objets.
# Initialisation des coordonnées du snake :
lw $t0 snakePosX
lw $t1 snakePosY
# Récupération de la taille de la grille : 
lw $t2 tailleGrille

# Cas 1 : Si la tête du serpent dépasse la bordure de la grille
#==============================================================
bge $t0 $t2 finJeu            # Vérification du dépassement X, dans les deux sens
blt $t0 0 finJeu
bge $t1 $t2 finJeu            # Vérification du dépassement Y, dans les deux sens
blt $t1 0 finJeu

# Cas 2 : Si la tête du serpent heurte un obstacle
#=================================================
# On va vérifier tous les obstacles, un par un :
lw $t2 numObstacles            # La condition de sortie est d'avoir épuisé le nombre d'obstacles
la $a0 obstaclesPosX           # Pour accéder à l'abscisse de l'obstacle
la $a1 obstaclesPosY           # Pour accéder à l'ordonnée de l'obstacle
li $t5 1                       # Initialisation du compteur

loop_obstacle:
bgt $t5 $t2 exit_loop_obstacle 

lw $t3 0($a0)                  # Récupérer l'abscisse de l'obstacle
lw $t4 0($a1)                  # Récupérer l'ordonnée de l'obstacle
# Vérification des deux coordonnées simultanément :
bne $t0 $t3 next             
beq $t1 $t4 finJeu
next:
addi $a0 $a0 4			       # Adresse de l'obstacle suivant (X)
addi $a1 $a1 4			       # Adresse de l'obstacle suivant (Y)
addi $t5 $t5 1                 # Mise à jour du compteur

j loop_obstacle

exit_loop_obstacle:

# Cas 3 : Si le serpent rencontre une partie de son propre corps
#===============================================================
# On va vérifier tous les points du corps, un par un, à commencer par le cinquième 
# (car le snake ne peut pas s'enrouler sur les pixels qui suivent immédiatement la tête): 
lw $t2 tailleSnake             # La condition de sortie est le bout du serpent
la $a0 snakePosX               # On reprend les adresses des coordonnées du snake, pour pouvoir examiner son corps
la $a1 snakePosY
# La position de la tete est déjà dans les registres $t0 et $t1 respectivement
li $t3 4                       # Initialisation du compteur : 5e pixel du corps, à commencer par la tete

loop_corps:
bge $t3 $t2 exit_loop_corps

# Récupération des coordonnées :
li $t7 4                       # Offset   		      
add $a0 $a0 $t7
add $a1 $a1 $t7
lw $t5 0($a0)                  # Récupérer l'abscisse de la partie du corps à examiner
lw $t6 0($a1)                  # Récupérer l'ordonnée de la partie du corps à examiner
# Vérification des deux coordonnées simultanément :
bne $t0 $t5 next_
beq $t1 $t6 finJeu
next_:
addi $t3 $t3 1                 # Mise à jour du compteur
j loop_corps

exit_loop_corps:

j exitcfj

finJeu:
li $v0 -1
jr $ra

exitcfj:
li $v0 0
jr $ra

############################### affichageFinJeu ################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Affiche le score du joueur dans le terminal suivi d'un petit
#                mot gentil (Exemple : «Quelle pitoyable prestation!»).
# Bonus:         Affiche le message "Game over" sur l'écran noir, à la fin.
#                Le message console est différencié en fonction du score obtenu.    
################################################################################

affichageFinJeu:
subu $sp $sp 4
sw $ra 0($sp)

jal resetAffichage          # Rétablit l'écran noir

# Affichage console classique, en fonction du score
#==================================================
la $a0 motGentil1
li $v0 4
syscall

lw $a0 scoreJeu             # Affiche le score
li $v0 1
syscall

li $v0 40
bgt $a0 $v0 moyen	        # Renvoie au message à afficher si le score est supérieur à 40
la $a0 motGentil2
j affiche

moyen:                      # Message à afficher pour un joueur moyen
li $v0 85
bgt $a0 $v0 bon		        # Renvoie au message à afficher si le score est supérieur à 85
la $a0 motUnPeuPlusGentil
j affiche

bon:
la $a0 motVraimentGentil    # Message à afficher pour un bon joueur

affiche:
li $v0 4
syscall

# Affichage écran punk !
#=======================
printGameOver:
lw $a0 colors + green       # On imprimera le message en vert fluo
li $a1 1                    # Ligne de départ sur l'écran
li $a2 0                    # Colonne de départ sur l'écran

# Initialisation des registres :
lw $t0 tailleGrille         # Dimensions
li $t1 4                    # Taille d'un élément (en octets)
la $t2 gOMessage            # Adresse de début de la matrice
li $t4 0                    # Initialisation du compteur de colonne
    
# Parcours des colonnes de la matrice :
colonne_loop:
# Calcul de l'adresse de l'élément dans la matrice
mul $t5 $t3 $t0             # Numéro de ligne * nombre de colonnes par ligne
add $t5 $t5 $t4             # Ajout du numéro de colonne
mul $t5 $t5 $t1             # Conversion en octets
add $t5 $t5 $t2             # Adresse
    
lw $t6 0($t5)               # Charger la valeur de l'élément de la matrice
li $t7 1	                # Rendre disponible le 1 (qui correspond à un élément coloré)
    
# Dessiner le pixel
bne $t6 $t7 continue_affichage
jal printColorAtPosition

continue_affichage:
beq $t4 $t0 fin             # Sortir si toutes les colonnes ont été parcourues
addi $t4 $t4 1	            # Colonne suivante dans la matrice
addi $a2 $a2 1	            # Colonne suivante sur l'écran
j colonne_loop

fin:
lw $ra ($sp)
addu $sp $sp 4
jr $ra
