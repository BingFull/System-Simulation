function [time, type, id, event_queue  ]=pop_Event_queue_new(event_queue)
time= event_queue(1,1);% move the timer
type = event_queue(2,1);
id = event_queue(3,1);
s = size(event_queue);
if s == [3 1]% only one event existed
    event_queue = [];
else%more than one event existed
    %push the fisrt event out.
    event_queue=event_queue(:,2:s(2));            
end