function [selected_markers,new_labels,marker_set_choice,side_ch] = marker_set_foot(marker_set_choice,labels,markers_values,varargin)
%this function will return an array with the position of the selected
%markers for each frame
default_set=1;  %the values taken by default if the corresponding field is not filled
default_side=1;

p = inputParser;    %declares an input parser
addRequired(p,'marker_set_choice'); %all required settings are obligatory to run the function
addRequired(p,'labels');
addRequired(p,'markers_values');
addOptional(p,'side',default_side); %the side is optinal and the field could be left empty
parse(p,marker_set_choice,labels,markers_values,varargin{:});
labels=p.Results.labels;    %get the whole label list
markers_values=p.Results.markers_values;    %get the markers values
side=p.Results.side;    %get the side

switch side
    case 1
        side_ch='both';
    case 2
        side_ch='right';
    case 3
        side_ch='left';
end

switch p.Results.marker_set_choice  %depending on the choice different set of markers are keeped
    case 1
        marker_set=string(labels);  %keep all labels
        marker_set_choice='all';
    case 2  %without arms and C7
        marker_set=["L_IAS";"L_IPS";"R_IPS";"R_IAS";"L_FTC";"L_FLE";"L_FME";...
            "L_FAX";"L_TTC";"L_FAL";"L_TAM";"L_FCC";"L_FM1";"L_FM2";"L_FM5";...
            "R_FTC";"R_FLE";"R_FME";"R_FAX";"R_TTC";"R_FAL";"R_TAM";"R_FCC";...
            "R_FM1";"R_FM2";"R_FM5";"L_HAL";"L_FMP1";"L_FMP2";"L_FMP5";"L_FCCM";...
            "L_FCCL";"R_HAL";"R_FMP1";"R_FMP2";"R_FMP5";"R_FCCM";"R_FCCL"];
        marker_set_choice='minimal';
    case 3 %without pelvis
        marker_set=["L_FTC";"L_FLE";"L_FME";"L_FAX";"L_TTC";"L_FAL";"L_TAM";...
            "L_FCC";"L_FM1";"L_FM2";"L_FM5";"R_FTC";"R_FLE";"R_FME";"R_FAX";...
            "R_TTC";"R_FAL";"R_TAM";"R_FCC";"R_FM1";"R_FM2";"R_FM5";"L_HAL";...
            "L_FMP1";"L_FMP2";"L_FMP5";"L_FCCM";"L_FCCL";"R_HAL";"R_FMP1";...
            "R_FMP2";"R_FMP5";"R_FCCM";"R_FCCL"];
        marker_set_choice='lower';
    case 4  %without femur
        marker_set=["L_FAX";"L_TTC";"L_FAL";"L_TAM";"L_FCC";"L_FM1";"L_FM2";...
            "L_FM5";"R_FAX";"R_TTC";"R_FAL";"R_TAM";"R_FCC";"R_FM1";"R_FM2";...
            "R_FM5";"L_HAL";"L_FMP1";"L_FMP2";"L_FMP5";"L_FCCM";"L_FCCL";...
            "R_HAL";"R_FMP1";"R_FMP2";"R_FMP5";"R_FCCM";"R_FCCL"];
        marker_set_choice='legs';
    case 5  %without tibia
        marker_set=["L_FAL";"L_TAM";"L_FCC";"L_FM1";"L_FM2";"L_FM5";"R_FAL";...
            "R_TAM";"R_FCC";"R_FM1";"R_FM2";"R_FM5";"L_HAL";"L_FMP1";"L_FMP2";...
            "L_FMP5";"L_FCCM";"L_FCCL";"R_HAL";"R_FMP1";"R_FMP2";"R_FMP5";...
            "R_FCCM";"R_FCCL"];
        marker_set_choice='shanks';
    case 6  %minus ankle
        marker_set=["L_FCC";"L_FM1";"L_FM2";"L_FM5";"R_FCC";"R_FM1";"R_FM2";...
            "R_FM5";"L_HAL";"L_FMP1";"L_FMP2";"L_FMP5";"L_FCCM";"L_FCCL";...
            "R_HAL";"R_FMP1";"R_FMP2";"R_FMP5";"R_FCCM";"R_FCCL"];
        marker_set_choice='feet';
    case 7  %front foot
        marker_set=["L_FM1";"L_FM2";"L_FM5";"R_FM1";"R_FM2";"R_FM5";"L_HAL";...
            "L_FMP1";"L_FMP2";"L_FMP5";"R_HAL";"R_FMP1";"R_FMP2";"R_FMP5"];
        marker_set_choice='feet+ankle';
    case 8  %back foot
        marker_set=["L_FCC";"R_FCC";"L_FCCM";"L_FCCL";"R_FCCM";"R_FCCL"];
        marker_set_choice='feet+ankle';
end
if side==1  %if both side are selected
    for i=1:size(marker_set,1)
        index_keep(i)=find(labels==marker_set(i));  %gives the index of the selected markers in the whole list
    end
    for i=1:size(index_keep,2)
        selected_markers(:,i*3-2:i*3)=markers_values(:,index_keep(i)*3-2:index_keep(i)*3);  %the labels and the corresponding coordinates are organized the same way,
    end     %it is possible to retrieve the need coordinates by using the index
    new_labels=marker_set;
end

k=1;
l=1;
if side==2  %right side
    while k<=size(marker_set,1)
        temp_test=char(marker_set(k));
        if temp_test(1)~='L'    %if the first letter is different than 'L', the marker is saved
            index_keep(l)=find(labels==marker_set(k));
            l=l+1;
        end
        k=k+1;
    end
    for i=1:size(index_keep,2)
        selected_markers(:,i*3-2:i*3)=markers_values(:,index_keep(i)*3-2:index_keep(i)*3);
        new_labels(i)=labels(index_keep(i));
    end
end

k=1;
l=1;
if side==3
    while k<=size(marker_set,1)
        temp_test=char(marker_set(k));
        if temp_test(1)~='R'
            index_keep(l)=find(labels==marker_set(k));
            l=l+1;
        end
        k=k+1;
    end
    for i=1:size(index_keep,2)
        selected_markers(:,i*3-2:i*3)=markers_values(:,index_keep(i)*3-2:index_keep(i)*3);
        new_labels(i)=labels(index_keep(i));
    end
end
