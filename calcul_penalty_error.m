% function punition
% This function allow to detect if there is fake detection event near the
% best detected event (a 20frame windows is opened)
% For each fake event a penalty of 30 frame is added

function[diff_final,error_frame] = calcul_penalty_error(event_detected,ref_event)

diff_final = zeros([1,size(ref_event,2)]);
for ind_ref_event = 1:size(ref_event,2)
    ref_event_temp = ref_event(ind_ref_event);
    [diff_final_temp,pos] = min(abs(ref_event_temp -event_detected));
    error_frame(ind_ref_event)=ref_event_temp -event_detected(pos)
    for ind_indice =1:size(event_detected,2)
        if ind_indice == pos
        elseif abs(ref_event-event_detected(ind_indice))<20
            % Disadvantages for each fake event near the best case
            diff_final_temp = diff_final_temp+30;
        end
    end
    diff_final(ind_ref_event) = diff_final_temp;
end

end