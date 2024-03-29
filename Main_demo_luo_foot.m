addpath(genpath('.\btk'))

folder  = {'.\equin',...
    '.\glissant_att',...
    '.\glissant_dec',...
    '.\normale'};
group = {'equin','glissant_att','glissant_dec','normale'};
diff_global_FO = struct();
diff_global_FS = struct();

set_ctc=6; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet
side_ctc=1; %Side choice: 1 or nothing=both, 2=right side, 3=Left side. Medial markers(STRN, CLAV...) are keeped.
disc_str=273;   %nombre de niveaux de discrétisations
sweep_str=4;   %taille des sous-ensemble comparés
PeakHeight_str=1;   %réglage de la hauteur minimale
PeakDistance_str=39;    %reglage de la distance minimale entre deux pics
PeakProminence_str=49.19488;

set_off=7; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet
side_off=2;
disc_off=358;   %nombre de niveaux de discrétisations
sweep_off=14;   %taille des sous-ensemble comparés
PeakHeight_off=1;   %réglage de la hauteur minimale
PeakDistance_off=35;    %reglage de la distance minimale entre deux pics
PeakProminence_off=30.7623;


for ind_folder = 1:size(folder,2)
    name_files = dir(folder{ind_folder});
    
    diff_global_FO_temp = [];
    diff_global_FS_temp = [];
    for ind_name = 3:size(name_files)
        c3d_filename = name_files(ind_name).name
        c3d_filename = strcat(folder{ind_folder},'\',c3d_filename)
        acq = btkReadAcquisition(c3d_filename);
        % Event detection function
        [Reve_r_str,Leve_l_str]= Luo_motion_extraction_foot_R_L(...
            acq,set_ctc,side_ctc,disc_str,sweep_str,PeakHeight_str,PeakDistance_str,PeakProminence_str,1);
        [Reve_r_off,Leve_l_off]= Luo_motion_extraction_foot_R_L(...
            acq,set_off,side_off,disc_off,sweep_off,PeakHeight_off,PeakDistance_off,PeakProminence_off,2);
        
        % Frame difference calculation from the reference
        refevents = btkGetEvents(acq);
        name_events = fieldnames(refevents);
        
        if isfield(refevents,'Right_Foot_Strike_GS')
            ref_RFS = refevents.Right_Foot_Strike_GS()*btkGetPointFrequency(acq);
            diff_global_FS_temp = [diff_global_FS_temp,calcul_penalty(Reve_r_str,ref_RFS)];
        end
        
        if isfield(refevents,'Right_Foot_Off_GS')
            ref_RFO = refevents.Right_Foot_Off_GS()*btkGetPointFrequency(acq);
            diff_global_FO_temp = [diff_global_FO_temp,calcul_penalty(Reve_r_off,ref_RFO)];
        end
        
        if isfield(refevents,'Left_Foot_Strike_GS')
            ref_LFS = refevents.Left_Foot_Strike_GS()*btkGetPointFrequency(acq);
            diff_global_FS_temp = [diff_global_FS_temp,calcul_penalty(Leve_l_str,ref_LFS)];
        end
        
        if isfield(refevents,'Left_Foot_Off_GS')
            ref_LFO = refevents.Left_Foot_Off_GS()*btkGetPointFrequency(acq);
            diff_global_FO_temp = [diff_global_FO_temp,calcul_penalty(Leve_l_off,ref_LFO)];
        end
    end
    diff_global_FO.(group{ind_folder}) = diff_global_FO_temp;
    diff_global_FS.(group{ind_folder}) = diff_global_FS_temp;
end

% Score by pathology
score_final_FO_equin = sum(exp(diff_global_FO.equin))/size(diff_global_FO.equin,2);
score_final_FS_equin = sum(exp(diff_global_FS.equin))/size(diff_global_FS.equin,2);

score_final_FO_glissant_att = sum(exp(diff_global_FO.glissant_att))/size(diff_global_FO.glissant_att,2);
score_final_FS_glissant_att = sum(exp(diff_global_FS.glissant_att))/size(diff_global_FS.glissant_att,2);

score_final_FO_glissant_dec = sum(exp(diff_global_FO.glissant_dec))/size(diff_global_FO.glissant_dec,2);
score_final_FS_glissant_dec = sum(exp(diff_global_FS.glissant_dec))/size(diff_global_FS.glissant_dec,2);

score_final_FO_normale = sum(exp(diff_global_FO.normale))/size(diff_global_FO.normale,2);
score_final_FS_normale = sum(exp(diff_global_FS.normale))/size(diff_global_FS.normale,2);
% Total score
diff_FO_total = [];
diff_FS_total = [];
for ind_folder = 1:size(folder,2)
    diff_FO_total = [diff_FO_total,diff_global_FO.(group{ind_folder})];
    diff_FS_total = [diff_FS_total,diff_global_FS.(group{ind_folder})];
end
score_final_FO_total = sum(exp(diff_FO_total))/size(diff_FO_total,2);
score_final_FS_total = sum(exp(diff_FS_total))/size(diff_FS_total,2);
disp(strcat('The final score for Foot off is :',num2str(score_final_FO_total)))
disp(strcat('The final score for Foot strike is :',num2str(score_final_FS_total)))
