function pop_wait_food_queue(wait_food_queue)
s = size(wait_food_queue);
if s == [2 1]% only one event existed
    wait_food_queue = [];
else%more than one event existed
    %push the fisrt event out.
    wait_food_queue=wait_food_queue(:,2:s(2));            
end

