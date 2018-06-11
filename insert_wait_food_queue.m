function wait_food_queue=insert_wait_food_queue(wait_food_queue, time, id)

if isempty(wait_food_queue)
    wait_food_queue = [time id]';
else
    s = size(wait_food_queue);
    wait_food_queue = [wait_food_queue(:,1:s(2)) [time id]'];
end