floor = unidrnd(8,100,1);
queue = zeros(8,20);
id = 1;
pop_id = [];
while(~isempty(floor))
    temp_num_in_queue = queue(floor(1),1);
    queue(floor(1),temp_num_in_queue+2) = id;
    queue(floor(1),1) = queue(floor(1),1) + 1;
    floor = floor(2:length(floor));
    id = id + 1;
end
[queue, pop_id] = pop_queue(queue,2,2);
[queue, pop_id] = pop_queue(queue,2,10);
[queue, pop_id] = pop_queue(queue,3,5);
queue