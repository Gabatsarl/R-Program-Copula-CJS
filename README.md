
# Exchangeable 2-copule modeling of hierarchical data: Application to prediction------##

Exchangeable 2-copule modeling of hierarchical data: Application to prediction


# Introduction
Les données groupées sont souvent modéliséer par le modèle linéaire hiéarchique et ses variantes. 
Dans ce projet, nous proposons un modèle alternative à base des copules lorsque le nombre de variable explicative est 2
et nous donnons un exemple d'application.

# Modélisation
Nous partons d'une décomposition en vigne pour écrire la distribution des variables à l'intérieur d'une grappe avec trois copules explicitement définies C^1, C^2 et C^3  avec comme explication

    1. La copule C^1 et C^3 sont des copules échangeables
    2. La copule C^2 est une copule bivariée quelconque.

Pour ajuster un modèle de 2-copule échangeable, il faut retrouver alors 5 éléments les deux (2) lois marginales des deux variables et les trois(3).
Pour cela, nous utilisons les procédures habituelles d'ajustement des distributions et des copules.

    
# Application
Nous appliquons ce modèle sur des données ouvertes et traités par les modèles classiques pour comparer les résultats de la prédictions. Les données sont disponibles sur 

# Conclusion


# Titre du Projet

Description brève du projet.

## Installation

1. Cloner le dépôt.
2. Exécuter la commande suivante pour installer les dépendances :

```bash
npm install
