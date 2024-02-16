# Exchangeable 2-copula modeling of hierarchical data: Application and prediction


# Introduction
Les données groupées sont souvent modélisé par le modèle linéaire hiéarchique et ses variantes. 
Dans ce projet, nous proposons un modèle alternative à base des copules lorsque le nombre de variable explicative est 2
et nous donnons un exemple d'application.


# Présentation de la forme des données
Nous considérons un modèle avec 3 grappes comme exemples numérotés 1, 2 et 3 ayant respectivement 3, 5, et 4 individus. Le graphique se présente dans la figure 

![Decomposition vine copula](/Cluster.png)

<p align="center">
  <img src="Cluster.png" alt="Disposition des données en cluster">
</p>



%```mermaid
%graph TD;
 %   A-->B;
  %  A-->C;
   % B-->D;
    %C-->D;
%```
## Objectif
L'objectif est de proposer un modélisation de ces données en prenant en compte l'effet cluster.


# Modelling
Le modèle échangeable proposé pour écrire la distribution des variables à l'intérieur d'une grappe avec trois copules explicitement définies C^1, C^2 et C^3  avec comme explication

    1. La copule C^1 et C^3 sont des copules échangeables
    2. La copule C^2 est une copule bivariée quelconque.



![Decomposition vine copula](/Capture.png)



avec $C_{2|1}$, la distribution conditionnelle donnée par
$$C_{2|1}\left\{v|u\right\}=\frac{\partial C^{(2)}(u,v;\delta_2)}{\partial u} \cdot$$


Pour ajuster un modèle de 2-copule échangeable, il faut retrouver alors 5 éléments les deux (2) lois marginales des deux variables et les trois(3).
Pour cela, nous utilisons les procédures habituelles d'ajustement des distributions et des copules.
    
# Application
Nous appliquons ce modèle sur des données ouvertes et traités par les modèles classiques pour comparer les résultats de la prédictions. Les données sont disponibles en tapant le mini code

```r
library(lmeresampler) ; data(jsp728)
```

# Conclusion
Le modèle proposé appelé "2-copule échangeable" améliore la prédiction par rapport à ses concurrents existants.
