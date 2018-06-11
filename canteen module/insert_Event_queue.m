function event_queue=insert_Event_queue(event_queue,time, type)

if isempty(event_queue)
    event_queue = [time type]';
else
    s = size(event_queue);
    %check the start and end 
    if event_queue(1,1) >= time
        %add to the start
        event_queue = [[time type]' event_queue(:,1:s(2))];
    elseif event_queue(1,s(2)) <= time
        %add to the end
        event_queue = [event_queue(:,1:s(2)) [time type]'];
    else
        for n = 1:s(2)%go through the event queue and find the right place to insert
            if event_queue(1,n)>=time
                %insert the time and type
                event_queue = [event_queue(:,1:n-1) [time type]' event_queue(:,n:s(2))];
                break;
            end
        end
    end
end