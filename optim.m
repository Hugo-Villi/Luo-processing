clearvars
%X=[disc;sweep;PeakHeight;PeakDistance;PeakProminence];
opts = optimoptions('ga','PlotFcn',@gaplotbestf);
% Optimisation
 % Anonymous function (to pass extra parameters)
%Xini=[16;10;1;30;10];
%M =[0;0];
Xini=[16;10;30;10];
M =[0;0];
%IntCon = [1,2,4];
IntCon = [1,2,3];
%lb = [2;2;1;1;0.001];
%ub = [300;32;1.001;100;20];
lb = [50;15;10;1];
ub = [100;20;30;5];
global ite J Save_x
ite=0;
C = @(X)fun(X,M);
%[X,~,exitflag] = fminsearch(C,Xini,options);
[x,~,exitflag,output] = ga(C,4,[],[],[],[],lb,ub,[],IntCon,opts);

function J_temp = fun(X,M)
global ite J Save_x
ite=ite+1
Save_x(ite,:)=X;
% Objective function
clearvars -except ite J save_x X M
exp_sum=0;
myFolder = 'D:\stage\Sofamehack2019\all_files'; %define the folder where the files to compute are
files=get_file_names_c3d(myFolder); %Get the names of the files inside the folder
for k=1:size(files,1)
    Number_of_strike=[4;5;4;6;4;5;5;5;5;4;6;7;4;6;4;6;5;5;5;7;5;5;7;4;5;5;5;...
        4;3;4;5;6;5;5;6;6;6;4;6;6;4;4;5;7;5;5;3;4;5;5;6;6;5;5;4;4;4;5;4;4;...
        3;5;5;4;5;6;5;7;4;7;6;5;5;6;4;5;4;6;5;6;4;5;5;6;4;3;6;5;4];

    %for set_choice=1:6
    %for side_choice=1:3
    %clearvars -except files k marker_set SAVE_DATA save_file_name first_frame g...
    %side_choice locs_save error error_I error_Ix error_Iy error_Iz set_choice %clear all the variables except the one needed toexecute the loop over all the files
    clearvars -except disc sweep PeakHeight PeakDistance PeakProminence files k...
        error_I_strike error_Ix_strike error_Iy_strike error_Iz_strike...
        error_I_off error_Ix_off error_Iy_off error_Iz_off X M ite J Save_x...
        Number_of_strike exp_sum
    file = files(k).name;    
    acq = btkReadAcquisition(file);             %read the file
    all_labels = fieldnames(btkGetMarkers(acq));    %get the labels of the markers
    all_markers_values = btkGetMarkersValues(acq);  %give an array filled with the coordinates of the marker (x,y,z of first marker, x,y,z of second, and so on)
    [events,labels_events]=btkGetEventsValues(acq);
    frequency=btkGetPointFrequency(acq);
    events_frame=events/(1/frequency);
    file_for_save=erase(file,'.c3d');
    %settings for the function: marker_set(choice of set, labels,marker_values,side)
    %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet
    set_choice=5;
    %Side choice: 1 or nothing=both, 2=right side, 3=Left side. Medial markers
    %(STRN, CLAV...) are keeped.
    side_choice=1;
    if side_choice~=1
        Number_of_strike=Number_of_strike/2;
    end
    [markers_values,labels]=marker_set(set_choice,all_labels,all_markers_values,side_choice);
    switch set_choice
        case 1
            marker_set_choice='all';
        case 2
            marker_set_choice='minimal';
        case 3
            marker_set_choice='lower';
        case 4
            marker_set_choice='legs';
        case 5
            marker_set_choice='shanks';
        case 6
            marker_set_choice='feet';
    end
    
    switch side_choice
        case 1
            side='both';
        case 2
            side='right';
        case 3
            side='left';
    end
    %%calculation of the displacement vector
    displacement=zeros(size(markers_values,1)-1,size(markers_values,2));%preallocation
    for i=1:(size(markers_values,1)-1)                                  %-1 otherwise it will crash trying to reach the last frame + 1
        displacement(i,:)=markers_values(i+1,:)-markers_values(i,:);    %simple soustraction between frame+1-frame
    end
    %give only displacements for x, y and z, to ease the next steps (max/min
    %detection and discretization)
    for i=3:3:size(markers_values,2)
        displacement_x(:,i/3)=displacement(:,i-2);
        %displacement_y(:,i/3)=displacement(:,i-1);
        %displacement_z(:,i/3)=displacement(:,i);
    end
    %%displacement histogram
    maximum=max(displacement,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum=min(displacement,[],'all');     %same for min
    %the following part get the maximum and minimums of x,y and z displacement
    %to set the range of the histograms
    max_x = max(displacement_x,[],'all');
    min_x = min(displacement_x,[],'all');
    
    %max_y = max(displacement_y,[],'all');
    %min_y = min(displacement_y,[],'all');
    
    %max_z = max(displacement_z,[],'all');
    %min_z = min(displacement_z,[],'all');
    
    %creating the histograms
    n = X(1) ;                                %number of discretizations levels, this setting may have importance on the results
    discretization_x=linspace(min_x,max_x,n);   %the function linspace creates a vector of values envenly distributed along a range
    %discretization_y=linspace(min_y,max_y,n);
    %discretization_z=linspace(min_z,max_z,n);
    %discretization_global=linspace(minimum,maximum,n);
    for i=1:size(displacement_x,1)    %will generate an histogram for each frame for the x,y and z coordinates
        histogram_x(i,:)=histcounts(displacement_x(i,:),discretization_x);
     %   histogram_y(i,:)=histcounts(displacement_y(i,:),discretization_y);
     %   histogram_z(i,:)=histcounts(displacement_z(i,:),discretization_z);
      %  histogram_max_min(i,:)=histcounts(displacement(i,:),discretization_global);
    end
    
    %computing the probabilities, simply by dividing the histogram by the
    %number of marker
    for i=1:size(histogram_x)
        prob_x(i,:)=histogram_x(i,:)/(size(markers_values,2)/3);
       % prob_y(i,:)=histogram_y(i,:)/(size(markers_values,2)/3);
        %prob_z(i,:)=histogram_z(i,:)/(size(markers_values,2)/3);
        %prob_global(i,:)=histogram_max_min(i,:)/(size(markers_values,2)/3);
    end
    
    size_sweep=round(X(2));
    Cx_luo=compute_C_luo_mod_disc(n,displacement_x,discretization_x,labels,size_sweep);
    %{
    Cy_luo=compute_C_luo_mod_disc(n,displacement_y,discretization_y,labels,size_sweep);
    Cz_luo=compute_C_luo_mod_disc(n,displacement_z,discretization_z,labels,size_sweep);
    C_max_min_luo=compute_C_luo_mod_disc(n,displacement,discretization_global,labels,size_sweep);
    %}
    %compute the mutual information for each dimension and sum it to get the
    %total mutual information I
    
    Ix_luo_mod=mutual_info_luo(size(displacement,1),Cx_luo,prob_x);
    %{
    Iy_luo_mod=mutual_info_luo(size(displacement,1),Cy_luo,prob_y);
    Iz_luo_mod=mutual_info_luo(size(displacement,1),Cz_luo,prob_z);
    I_luo_mod=Ix_luo_mod+Iy_luo_mod+Iz_luo_mod;
    I_max_min_luo_mod=mutual_info_luo(size(displacement,1),C_max_min_luo,prob_global);
    %}
    
    
    %[temp_I_strike,temp_I_off]=get_error3(I_luo_mod,labels_events,events_frame,file_for_save,marker_set_choice,side,string(n),size_sweep,X(3),X(4),X(5));
    [temp_Ix_strike,temp_Ix_off,peaks_num]=get_error3(Ix_luo_mod,labels_events,events_frame,file_for_save,marker_set_choice,side,string(n),size_sweep,1,X(3),X(4));
    %[temp_Iy_strike,temp_Iy_off]=get_error3(Iy_luo_mod,labels_events,events_frame,file_for_save,marker_set_choice,side,string(n),size_sweep,X(3),X(4),X(5));
    %[temp_Iz_strike,temp_Iz_off]=get_error3(Iz_luo_mod,labels_events,events_frame,file_for_save,marker_set_choice,side,string(n),size_sweep,X(3),X(4),X(5));
    
    error_Ix_off(k,1:size(temp_Ix_off,2))=temp_Ix_off;
    %{
    error_I_strike(k,1:size(temp_I_strike,2))=temp_I_strike;
    error_I_off(k,1:size(temp_I_off,2))=temp_I_off;
    error_Ix_strike(k,1:size(temp_Ix_strike,2))=temp_Ix_strike;
    
    error_Iy_strike(k,1:size(temp_I_strike,2))=temp_Iy_strike;
    error_Iy_off(k,1:size(temp_I_off,2))=temp_Iy_off;
    error_Iz_strike(k,1:size(temp_I_strike,2))=temp_Iz_strike;
    error_Iz_off(k,1:size(temp_I_off,2))=temp_Iz_off;
    %}
    %end
    %end
    exp_sum=exp_sum+exp(abs(peaks_num-Number_of_strike(k)));
end
error_Ix_off=str2double(error_Ix_off);
mean_errorx_off=nanmean(error_Ix_off);
std_errorx_off=std(error_Ix_off,'omitnan');
%{
error_I_strike=str2double(error_I_strike);
error_Ix_strike=str2double(error_Ix_strike);
error_Iy_strike=str2double(error_Iy_strike);
error_Iz_strike=str2double(error_Iz_strike);
error_I_off=str2double(error_I_off);

error_Iy_off=str2double(error_Iy_off);
error_Iz_off=str2double(error_Iz_off);

mean_error_strike=nanmean(error_I_strike);
mean_errorx_strike=nanmean(error_Ix_strike);
mean_errory_strike=nanmean(error_Iy_strike);
mean_errorz_strike=nanmean(error_Iz_strike);
mean_error_off=nanmean(error_I_off);

mean_errory_off=nanmean(error_Iy_off);
mean_errorz_off=nanmean(error_Iz_off);

std_error_strike=std(error_I_strike,'omitnan');
std_errorx_strike=std(error_Ix_strike,'omitnan');
std_errory_strike=std(error_Iy_strike,'omitnan');
std_errorz_strike=std(error_Iz_strike,'omitnan');
std_error_off=std(error_I_off,'omitnan');

std_errory_off=std(error_Iy_off,'omitnan');
std_errorz_off=std(error_Iz_off,'omitnan');
%}
w1=1;
w2=2;
J_temp=sqrt(w1*(mean(mean_errorx_off)-M(1,1))^2+w2*(mean(std_errorx_off)-M(2,1))^2)+exp_sum;
J(ite) = J_temp;
%hold on
end