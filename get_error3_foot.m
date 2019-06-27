function [error_strike,error_off,peaks_num] = get_error3_foot(I,labels_events,events_frame,size_sweep,PeakHeight,PeakDistance,PeakProeminence)
I_to_plot=I(1+size_sweep:size(I,2)-size_sweep); %the subsequences reduce the size of the curve
temp_I_max=max(I_to_plot);  %get the maximum value
temp_I_min=min(I_to_plot);  %get the minimum value
peak_proeminence=abs((temp_I_max-temp_I_min)/(mean(I_to_plot)*PeakProeminence));    %compute the value of the minimal proeminence of the peak
[~,locs]=findpeaks(I,'MinPeakHeight',mean(I_to_plot)*PeakHeight,...
    'MinPeakDistance',PeakDistance,'MinPeakProminence',peak_proeminence);   %only get the index of the peaks, i.e. the frame of the peak
peaks_num=size(locs,2);
%{
plot(I);
hold on;
legend('luo x');
xlabel('frames');
ylabel('Mutual information I');
for i=1:size(events_frame,1)
    vline(events_frame(i),'g',labels_events(i));
end
for i=1:size(locs,2)
    vline(locs(i),'b','peak');
end
hold off
save_name=strcat(file_for_save,'_',marker_set_choice,'_',side,'_Ix','_disc_',string1,'_sweep_',string(size_sweep));
saveas(gcf,save_name,'png');
%}
index_strike=find(contains(labels_events,'Strike'));    %find which events are strike events
if isempty(index_strike)==1 %if no strike events are found returns "no strike"
    error_strike=["no strike","no strike"];
else
    for i=1:size(index_strike,1)    % loop for the number of strike
        [temp_error,index_min]=min(abs(locs-events_frame(index_strike(i))));    %get the closest peak to the event
        if temp_error<50
            error_strike(1,i)=string(locs(index_min)-events_frame(index_strike(i)));    %the result is considered valid if it is under 50 frames
        else
            error_strike(1,i)="not found";
        end
    end
end
index_off=find(contains(labels_events,'Off'));  %repeat for off events
if isempty(index_off)==1
    error_off=["no off","no off"];
else
    for i=1:size(index_off,1)
        [temp_error,index_min]=min(abs(locs-events_frame(index_off(i))));
        if temp_error<50
            error_off(1,i)=string(locs(index_min)-events_frame(index_off(i)));
        else
            error_off(1,i)="not found";
        end
    end
end
end