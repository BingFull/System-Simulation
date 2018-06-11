function [time, type, event_queue ]=pop_Event_queue(event_queue)
time= event_queue(1,1);% move the timer
type = event_queue(2,1);
s = size(event_queue);
if s == [2 1]% only one event existed
    event_queue = [];
else%more than one event existed
    %push the fisrt event out.
    event_queue=event_queue(:,2:s(2));            
end