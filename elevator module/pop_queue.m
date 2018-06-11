function [ queue, pop_id ] = pop_queue( queue, index ,num_to_pop )
    pop_id = [];
    num_pop = 0;
    if queue(index,1) <= num_to_pop
        num_pop = queue(index,1);
        for i = 2:(num_pop+1)
            pop_id = [pop_id queue(index,i)];
            if queue(index,i) == 0
                bb = 1;
            end
        end
        queue(index,:) = 0;
    else
        num_pop = num_to_pop;
        queue(index,1) = queue(index,1) - num_pop;
        for i = 2:(num_pop +1)
            pop_id = [pop_id queue(index,i)];
            if queue(index,i) == 0
                bb = 1;
            end
            queue(index,i) = 0;
        end
        for i = 2:(queue(index,1)+1)
            queue(index,i) = queue(index,i+num_pop);
            queue(index,i+num_pop) = 0;
        end
        
    end
end

