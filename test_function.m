set=6; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet
side=1; %Side choice: 1 or nothing=both, 2=right side, 3=Left side. Medial markers(STRN, CLAV...) are keeped.
disc=119;   %nombre de niveaux de discr�tisations
sweep=14;   %taille des sous-ensemble compar�s
PeakHeight=1;   %r�glage de la hauteur minimale
PeakDistance=26;    %reglage de la distance minimale entre deux pics
PeakProminence=13.43;    %reglage de la pro�minence minimale
[error_Ix_off,error_Ix_strike,general,files]=Luo_motion_extraction_all_files_error_function(set,...
    side,disc,sweep,PeakHeight,PeakDistance,PeakProminence); %function that gives back the errors values

patho(1:45)="CP";   %type of pathologies for the boxplot
patho(46:50)="Creux";
patho(51:55)="Bot";
patho(56:60)="Equin";
patho(61:64)="Plat";
patho(65:84)="ITW";
patho(85:89)="varus";
patho(90:178)=patho;
error_Ix_strike=error_Ix_strike(:);   %vectorize the array

boxplot(error_Ix_strike,patho) %create the boxplot
title('Erreur en nombre d image par pathologie','FontSize',22)
xlabel('Type de pathologie','FontSize',20)
ylabel('erreur en nombre d image (100Hz)','FontSize',20)