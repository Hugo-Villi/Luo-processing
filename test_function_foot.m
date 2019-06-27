set_str=6; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet
side_str=1; %Side choice: 1 or nothing=both, 2=right side, 3=Left side. Medial markers(STRN, CLAV...) are keeped.
disc_str=119;   %nombre de niveaux de discrétisations
sweep_str=14;   %taille des sous-ensemble comparés
PeakHeight_str=1;   %réglage de la hauteur minimale
PeakDistance_str=26;    %reglage de la distance minimale entre deux pics
PeakProminence_str=13.43;    %reglage de la proéminence minimale

set_off=6; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet
side_off=1; %Side choice: 1 or nothing=both, 2=right side, 3=Left side. Medial markers(STRN, CLAV...) are keeped.
disc_off=119;   %nombre de niveaux de discrétisations
sweep_off=14;   %taille des sous-ensemble comparés
PeakHeight_off=1;   %réglage de la hauteur minimale
PeakDistance_off=26;    %reglage de la distance minimale entre deux pics
PeakProminence_off=13.43;    %reglage de la proéminence minimale
[error_Ix_off,error_Ix_strike,general,files]=Luo_motion_extraction_all_files_error_function_foot(set,...
    side,disc,sweep,PeakHeight,PeakDistance,PeakProminence); %function that gives back the errors values
[error_Ix_off,error_Ix_strike,general,files]=Luo_motion_extraction_all_files_error_function_foot(set,...
    side,disc,sweep,PeakHeight,PeakDistance,PeakProminence); 
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