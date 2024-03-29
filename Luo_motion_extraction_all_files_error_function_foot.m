%%acquisition of the needed data from the motion capture.
function [error_Ix_off,error_Ix_strike,general,files]...
    = Luo_motion_extraction_all_files_error_function_foot(set,...
    side_choice,disc,sweep,PeakHeight,PeakDistance,PeakProminence)
myFolder = 'D:\stage\test_marche_synchro\all_c3d_event'; %define the folder where the files to compute are
files=get_file_names_c3d(myFolder); %Get the names of the files inside the folder
for k=1:size(files,1)   %will go through all the files of the folder
    k
    clearvars -except disc sweep PeakHeight PeakDistance PeakProminence files k...
        error_I_strike error_Ix_strike error_Iy_strike error_Iz_strike...
        error_I_off error_Ix_off error_Iy_off error_Iz_off set side_choice  %clear all variables that aren't needed to execute a new loop or that need to be saved
    file = files(k).name   %select the file that will be computed    
    acq = btkReadAcquisition(file);             %read the file
    all_labels = fieldnames(btkGetMarkers(acq));    %get the labels of the markers
    all_markers_values = btkGetMarkersValues(acq);  %give an array filled with the coordinates of the marker (x,y,z of first marker, x,y,z of second, and so on)
    [events,labels_events]=btkGetEventsValues(acq); %get the events and their labels
    frequency=btkGetPointFrequency(acq);    %get the frequency of the point acquisition
    events_frame=events/(1/frequency);  %the timing of the events are given in seconds and are translated in frame
    file_for_save=erase(file,'.c3d');   %erase the .c3d in the name of the file to save the plot figures 
    
    X_RTOE=all_markers_values(:,(find(all_labels=="R_HAL")-1)*3+1);
X_LTOE=all_markers_values(:,(find(all_labels=="L_HAL")-1)*3+1);
if X_RTOE(end)-X_RTOE(1)<0
    X_RTOE=-X_RTOE;
    X_LTOE=-X_LTOE;
end
    
    if side_choice==1
    Leve_r=[];
    Reve_l=[];
    [markers_values,labels]=marker_set_foot(set,all_labels,all_markers_values,1); %gives back the coordinates values of the selected markers
    markers_values(markers_values==0)=NaN;    
    markers_values=PredictMissingMarkers(markers_values);
    %%calculation of the displacement vector
    displacement=zeros(size(markers_values,1)-1,size(markers_values,2));%preallocation
    for i=1:(size(markers_values,1)-1)                                  %-1 otherwise it will crash trying to reach the last frame + 1
        displacement(i,:)=markers_values(i+1,:)-markers_values(i,:);    %simple soustraction between frame+1-frame
    end
    %give only displacements for x, y and z, to ease the next steps (max/min
    %detection and discretization)
    for i=3:3:size(markers_values,2)
        displacement_x(:,i/3)=displacement(:,i-2);
        displacement_y(:,i/3)=displacement(:,i-1);
        displacement_z(:,i/3)=displacement(:,i);
    end
    %%displacement histogram
    maximum=max(displacement,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum=min(displacement,[],'all');     %same for min
    %the following part get the maximum and minimums of x,y and z displacement
    %to set the range of the histograms
    max_x = max(displacement_x,[],'all');
    min_x = min(displacement_x,[],'all');
    
    max_y = max(displacement_y,[],'all');
    min_y = min(displacement_y,[],'all');
    
    max_z = max(displacement_z,[],'all');
    min_z = min(displacement_z,[],'all');
    
    %creating the histograms
    n = disc ;                                %number of discretizations levels, this setting may have importance on the results
    discretization_x=linspace(min_x,max_x,n);   %the function linspace creates a vector of values envenly distributed along a range
    discretization_y=linspace(min_y,max_y,n);
    discretization_z=linspace(min_z,max_z,n);
    discretization_global=linspace(minimum,maximum,n);
    
    Cx_luo=compute_C_luo_mod_disc(n,displacement_x,discretization_x,labels,sweep);  %returns the C matrix
    Cy_luo=compute_C_luo_mod_disc(n,displacement_y,discretization_y,labels,sweep);
    Cz_luo=compute_C_luo_mod_disc(n,displacement_z,discretization_z,labels,sweep);
    C_max_min_luo=compute_C_luo_mod_disc(n,displacement,discretization_global,labels,sweep);
    
    %compute the joint entropy for each dimension
    Ix_luo_mod=mutual_info_luo(size(displacement,1),Cx_luo);
    Iy_luo_mod=mutual_info_luo(size(displacement,1),Cy_luo);
    Iz_luo_mod=mutual_info_luo(size(displacement,1),Cz_luo);
    I_luo_mod=Ix_luo_mod+Iy_luo_mod+Iz_luo_mod;
    I_max_min_luo_mod=mutual_info_luo(size(displacement,1),C_max_min_luo);
    
    %the get_error function gives back the error for the strike and off
    %events, for each dimension. get_error3_with_plot returns the plot for
    %each file
    [temp_I_strike,temp_I_off]=get_error3_foot(I_luo_mod,labels_events,...
        events_frame,sweep,PeakHeight,PeakDistance,PeakProminence);
    
    [Reve,Leve,peaks_num] = get_event(Ix_luo_mod,sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE);
else
    [markers_values_r,labels_r]=marker_set_foot(set,all_labels,all_markers_values,2); %gives back the coordinates values of the selected markers
    markers_values_r(markers_values_r==0)=NaN;
    markers_values_r=PredictMissingMarkers(markers_values_r);
    
    [markers_values_l,labels_l]=marker_set_foot(set,all_labels,all_markers_values,3); %gives back the coordinates values of the selected markers
    markers_values_l(markers_values_l==0)=NaN;
    markers_values_l=PredictMissingMarkers(markers_values_l);
    %%calculation of the displacement vector
    displacement_r=zeros(size(markers_values_r,1)-1,size(markers_values_r,2));%preallocation
    displacement_l=zeros(size(markers_values_l,1)-1,size(markers_values_l,2));
    for i=1:(size(markers_values_r,1)-1)                                  %-1 otherwise it will crash trying to reach the last frame + 1
        displacement_r(i,:)=markers_values_r(i+1,:)-markers_values_r(i,:);    %simple soustraction between frame+1-frame
        displacement_l(i,:)=markers_values_l(i+1,:)-markers_values_l(i,:);
    end
    %give only displacements for x, y and z, to ease the next steps (max/min
    %detection and discretization)
    for i=3:3:size(markers_values_r,2)
        displacement_x_r(:,i/3)=displacement_r(:,i-2);
        displacement_y_r(:,i/3)=displacement_r(:,i-1);
        displacement_z_r(:,i/3)=displacement_r(:,i);
        
        displacement_x_l(:,i/3)=displacement_l(:,i-2);
        displacement_y_l(:,i/3)=displacement_l(:,i-1);
        displacement_z_l(:,i/3)=displacement_l(:,i);
    end
    %%displacement histogram
    maximum_r=max(displacement_r,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum_r=min(displacement_r,[],'all');     %same for min
    %the following part get the maximum and minimums of x,y and z displacement
    %to set the range of the histograms
    max_x_r = max(displacement_x_r,[],'all');
    min_x_r = min(displacement_x_r,[],'all');
    
    max_y_r = max(displacement_y_r,[],'all');
    min_y_r = min(displacement_y_r,[],'all');
    
    max_z_r = max(displacement_z_r,[],'all');
    min_z_r= min(displacement_z_r,[],'all');
    
    
    %%displacement histogram
    maximum_l=max(displacement_l,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum_l=min(displacement_l,[],'all');     %same for min
    %the following part get the maximum and minimums of x,y and z displacement
    %to set the range of the histograms
    max_x_l = max(displacement_x_l,[],'all');
    min_x_l = min(displacement_x_l,[],'all');
    
    max_y_l = max(displacement_y_l,[],'all');
    min_y_l = min(displacement_y_l,[],'all');
    
    max_z_l = max(displacement_z_l,[],'all');
    min_z_l= min(displacement_z_l,[],'all');
    
    
    %creating the histograms
    n = disc ;                                %number of discretizations levels, this setting may have importance on the results
    discretization_x_r=linspace(min_x_r,max_x_r,n);   %the function linspace creates a vector of values envenly distributed along a range
    %discretization_y=linspace(min_y,max_y,n);
    %discretization_z=linspace(min_z,max_z,n);
    %discretization_global=linspace(minimum,maximum,n);
    
    discretization_x_l=linspace(min_x_l,max_x_l,n);
    
    Cx_luo_r=compute_C_luo_mod_disc(n,displacement_x_r,discretization_x_r,labels_r,sweep);  %returns the C matrix
    %Cy_luo=compute_C_luo_mod_disc(n,displacement_y,discretization_y,labels,sweep);
    %Cz_luo=compute_C_luo_mod_disc(n,displacement_z,discretization_z,labels,sweep);
    %C_max_min_luo=compute_C_luo_mod_disc(n,displacement,discretization_global,labels,sweep);
    
    Cx_luo_l=compute_C_luo_mod_disc(n,displacement_x_l,discretization_x_l,labels_l,sweep);  %returns the C matrix
    
    
    
    %compute the joint entropy for each dimension
    Ix_luo_mod_r=mutual_info_luo(size(displacement_r,1),Cx_luo_r);
    %Iy_luo_mod=mutual_info_luo(size(displacement,1),Cy_luo);
    %Iz_luo_mod=mutual_info_luo(size(displacement,1),Cz_luo);
    %I_luo_mod=Ix_luo_mod+Iy_luo_mod+Iz_luo_mod;
    %I_max_min_luo_mod=mutual_info_luo(size(displacement,1),C_max_min_luo);
    
    Ix_luo_mod_l=mutual_info_luo(size(displacement_l,1),Cx_luo_l);
    %the get_error function gives back the error for the strike and off
    %events, for each dimension. get_error3_with_plot returns the plot for
    %each file
    [Reve,Leve_r,peaks_num_r] = get_event(Ix_luo_mod_r,sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE);
    [Reve_l,Leve,peaks_num_l] = get_event(Ix_luo_mod_l,sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE);
end

    
    %the get_error function gives back the error for the strike and off
    %events, for each dimension. get_error3_with_plot returns the plot for
    %each file
    [temp_I_strike,temp_I_off]=get_error3_foot(I_luo_mod,labels_events,...
        events_frame,sweep,PeakHeight,PeakDistance,PeakProminence);%,'3D');
    [temp_Ix_strike,temp_Ix_off]=get_error3(Ix_luo_mod,labels_events,...
        events_frame,file_for_save,marker_set_choice,side_ch,string(n),sweep,...
        PeakHeight,PeakDistance,PeakProminence);%,'X');
    [temp_Iy_strike,temp_Iy_off]=get_error3(Iy_luo_mod,labels_events,...
        events_frame,file_for_save,marker_set_choice,side_ch,string(n),sweep,...
        PeakHeight,PeakDistance,PeakProminence);%,'Y');
    [temp_Iz_strike,temp_Iz_off]=get_error3(Iz_luo_mod,labels_events,...
        events_frame,file_for_save,marker_set_choice,side_ch,string(n),sweep,...
        PeakHeight,PeakDistance,PeakProminence);%,'Z');
    
    error_I_strike(k,1:size(temp_I_strike,2))=temp_I_strike;    %store the results
    error_I_off(k,1:size(temp_I_off,2))=temp_I_off;
    error_Ix_strike(k,1:size(temp_Ix_strike,2))=temp_Ix_strike;
    error_Ix_off(k,1:size(temp_Ix_off,2))=temp_Ix_off;
    error_Iy_strike(k,1:size(temp_Iy_strike,2))=temp_Iy_strike;
    error_Iy_off(k,1:size(temp_Iy_off,2))=temp_Iy_off;
    error_Iz_strike(k,1:size(temp_Iz_strike,2))=temp_Iz_strike;
    error_Iz_off(k,1:size(temp_Iz_off,2))=temp_Iz_off;
    %end
    %end
end
error_I_strike=str2double(error_I_strike);
error_Ix_strike=str2double(error_Ix_strike);
error_Iy_strike=str2double(error_Iy_strike);
error_Iz_strike=str2double(error_Iz_strike);
error_I_off=str2double(error_I_off);
error_Ix_off=str2double(error_Ix_off);
error_Iy_off=str2double(error_Iy_off);
error_Iz_off=str2double(error_Iz_off);



mean_error_strike=nanmean(error_I_strike);
mean_errorx_strike=nanmean(error_Ix_strike);
mean_errory_strike=nanmean(error_Iy_strike);
mean_errorz_strike=nanmean(error_Iz_strike);
mean_error_off=nanmean(error_I_off);
mean_errorx_off=nanmean(error_Ix_off);
mean_errory_off=nanmean(error_Iy_off);
mean_errorz_off=nanmean(error_Iz_off);

std_error_strike=std(error_I_strike,'omitnan');
std_errorx_strike=std(error_Ix_strike,'omitnan');
std_errory_strike=std(error_Iy_strike,'omitnan');
std_errorz_strike=std(error_Iz_strike,'omitnan');
std_error_off=std(error_I_off,'omitnan');
std_errorx_off=std(error_Ix_off,'omitnan');
std_errory_off=std(error_Iy_off,'omitnan');
std_errorz_off=std(error_Iz_off,'omitnan');


general=zeros(size(error_I_strike,1)+2,8);
general(1:size(error_I_strike,1),1:2)=error_I_strike;
general(size(error_I_strike,1)+1,1:2)=mean_error_strike;
general(size(error_I_strike,1)+2,1:2)=std_error_strike;

general(1:size(error_Ix_strike,1),3:4)=error_Ix_strike;
general(size(error_Ix_strike,1)+1,3:4)=mean_errorx_strike;
general(size(error_Ix_strike,1)+2,3:4)=std_errorx_strike;

general(1:size(error_Iy_strike,1),5:6)=error_Iy_strike;
general(size(error_Iy_strike,1)+1,5:6)=mean_errory_strike;
general(size(error_Iy_strike,1)+2,5:6)=std_errory_strike;

general(1:size(error_Iz_strike,1),7:8)=error_Iz_strike;
general(size(error_Iz_strike,1)+1,7:8)=mean_errorz_strike;
general(size(error_Iz_strike,1)+2,7:8)=std_errorz_strike;

general(1:size(error_I_off,1),9:10)=error_I_off;
general(size(error_I_off,1)+1,9:10)=mean_error_off;
general(size(error_I_off,1)+2,9:10)=std_error_off;

general(1:size(error_Ix_off,1),11:12)=error_Ix_off;
general(size(error_Ix_off,1)+1,11:12)=mean_errorx_off;
general(size(error_Ix_off,1)+2,11:12)=std_errorx_off;

general(1:size(error_Iy_off,1),13:14)=error_Iy_off;
general(size(error_Iy_off,1)+1,13:14)=mean_errory_off;
general(size(error_Iy_off,1)+2,13:14)=std_errory_off;

general(1:size(error_Iz_off,1),15:16)=error_Iz_off;
general(size(error_Iz_off,1)+1,15:16)=mean_errorz_off;
general(size(error_Iz_off,1)+2,15:16)=std_errorz_off;
end