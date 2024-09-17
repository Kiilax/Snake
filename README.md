# Projet : Jeu du Serpent en Assembleur

## Description
Ce projet implémente le jeu classique du serpent en assembleur. L'objectif est de contrôler un serpent qui se déplace sur une grille pour manger des bonbons, tout en évitant les obstacles et en ne touchant pas sa propre queue.

## Fonctionnalités
- **Affichage en couleurs :** Le jeu utilise un tampon d'affichage de 256x256 pixels pour dessiner le serpent, les obstacles et les bonbons. Chaque couleur est codée en hexadécimal avec des composantes rouge, verte et bleue.
- **Gestion des entrées clavier :** Utilisation des touches directionnelles (`z`, `q`, `s`, `d`) pour déplacer le serpent vers le haut, la gauche, le bas et la droite.
- **Mécaniques du jeu :**
  - Le serpent grandit à chaque bonbon mangé.
  - Un nouvel obstacle est généré à chaque bonbon mangé.
  - Le jeu s'accélère progressivement.
  - Le score du joueur est mis à jour à chaque bonbon mangé.
- **Fin du jeu :** Le jeu se termine si le serpent entre en collision avec lui-même ou avec un obstacle.

## Structure du code
- **Affichage et gestion des couleurs :**
  - Les fonctions telles que `printColorAtPosition` et `resetAffichage` sont responsables du rendu des éléments sur la grille de jeu.
- **Mouvements du serpent :**
  - La fonction `updateGameStatus` met à jour la position du serpent à chaque pas de temps, tout en testant si le serpent a mangé un bonbon ou s'il y a collision avec un obstacle.
- **Obstacles et bonbons :**
  - Le jeu génère des positions aléatoires pour les obstacles et les bonbons à des emplacements sûrs, où le serpent ne se trouve pas.

## Fichier de configuration des variables
Les principales variables du jeu sont stockées dans la section `.data`, qui contient :
- `tailleGrille`: Taille de la grille.
- `tailleSnake`: Taille actuelle du serpent.
- `numObstacles`: Nombre actuel d'obstacles.
- `candy`: Position du bonbon.
- `speed`: Vitesse actuelle du jeu.
- `scoreJeu`: Score actuel du joueur.

## Instructions pour lancer le jeu
1. Assurez-vous que vous disposez d'un simulateur MIPS (par exemple MARS ou SPIM).
2. Chargez le fichier source dans le simulateur.
3. Lancez l'exécution en mode **pas-à-pas** ou en continu pour jouer.

## Contrôles
- **z** : Haut
- **q** : Gauche
- **s** : Bas
- **d** : Droite

## Détails techniques
Le projet est écrit en assembleur MIPS et repose sur les fonctions d'entrée/sortie et de gestion des interruptions pour gérer le jeu en temps réel. Le buffer d'affichage est un tableau 2D simulé, et les entrées clavier sont capturées via les adresses mémoire spécifiques à MIPS.

## Améliorations possibles
- Ajout de niveaux de difficulté.
- Sauvegarde des scores et affichage d'un classement.
- Ajout de bonus spéciaux et de nouveaux types d'obstacles.
