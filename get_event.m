function [Reve,Leve,peaks_num] = get_event(I,size_sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE)
Reve=[];
Leve=[];
locs=[];
I_to_plot=I(1+size_sweep:size(I,2)-size_sweep); %the subsequences reduce the size of the curve
temp_I_max=max(I_to_plot);  %get the maximum value
temp_I_min=min(I_to_plot);  %get the minimum value
peak_proeminence=abs((temp_I_max-temp_I_min)/(mean(I_to_plot)*PeakProeminence));    %compute the value of the minimal proeminence of the peak
[~,locs]=findpeaks(I,'MinPeakHeight',mean(I_to_plot)*PeakHeight,...
    'MinPeakDistance',PeakDistance,'MinPeakProminence',peak_proeminence);   %only get the index of the peaks, i.e. the frame of the peak
peaks_num=size(locs,2);
j=1;
k=1;
if isempty(locs)~=1
    if strike_off_choice==1
        for i=1:peaks_num
            if X_RTOE(locs(i))>X_LTOE(locs(i))
                Reve(j)=locs(i);
                j=j+1;
            else
                Leve(k)=locs(i);
                k=k+1;
            end
        end
    else
        for i=1:peaks_num
            if X_RTOE(locs(i))<X_LTOE(locs(i))
                Reve(j)=locs(i);
                j=j+1;
            else
                Leve(k)=locs(i);
                k=k+1;
            end
        end
    end
end
if isempty(Leve)==1
    Leve=1;
end
if isempty(Reve)==1
    Reve=1;
end 
end