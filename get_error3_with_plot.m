function [error_strike,error_off] = get_error3_with_plot(I,labels_events,events_frame,file_for_save,marker_set_choice,side,string1,size_sweep,PeakHeight,PeakDistance,PeakProeminence,dimension)
I_to_plot=I(1+size_sweep:size(I,2)-size_sweep);
temp_I_max=max(I_to_plot);
temp_I_min=min(I_to_plot);
peak_proeminence=abs((temp_I_max-temp_I_min)/(mean(I_to_plot)*PeakProeminence));
[pks,locs]=findpeaks(I,'MinPeakHeight',mean(I_to_plot)*PeakHeight,'MinPeakDistance',PeakDistance,'MinPeakProminence',peak_proeminence);

plot(I);
hold on;
%legend('luo');
title('Information Conjointe issue des marqueurs du mollet selon la composante X','FontSize',22)
xlabel('Images','FontSize',18);
ylabel('Entropie Cojointe I','FontSize',18);
xlim([1+size_sweep size(I,2)-size_sweep])
%{
index_strike=find(contains(labels_events,'Strike'));
for i=1:size(index_strike,1)
    vline(events_frame(i),'g',labels_events(i));
end
for i=1:size(locs,2)
    vline(locs(i),'b','peak');
end
%}
hold off
save_name=strcat(file_for_save,'_',marker_set_choice,'_',side,'_disc_',string1,...
    '_sweep_',string(size_sweep),'_',dimension);
saveas(gcf,save_name,'png');

index_strike=find(contains(labels_events,'Strike'));
if isempty(index_strike)==1
    error_strike=["no strike","no strike"];
else
    for i=1:size(index_strike,1)
        [temp_error,index_min]=min(abs(locs-events_frame(index_strike(i))));
        if temp_error<50
            error_strike(1,i)=string(locs(index_min)-events_frame(index_strike(i)));
        else
            error_strike(1,i)="not found";
        end
    end
end
index_off=find(contains(labels_events,'Off'));
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

