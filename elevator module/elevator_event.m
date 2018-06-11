clear all
close all

%set the format of event queue, 1st :time 2nd:event type(1,arrival, 2 service
%end)
Event_queue= [];

%queue was used for customer waiting
%queue= [(0),(0),(0),(0),(0),(0),(0),(0)];
queue = zeros(8,40);



%set the status of elevator 
elevator_loc = 1;
elevator_num_threshold = 10;
num_in_elevator = 0;
time_every_floor = 5;
elevator_dst = 0;
queue_in_elevator = [];
elevator_door = 0;


%%
%init student with randomlized decision graph

%set the student number
student_num = 100;

%time=sort(randn(1,student_num));
t1 = randn([1, student_num]);
t2 = randn([1, student_num]);
t = t1 * 24.7631 + 93.3616 + t2 * sqrt(8.6084) + 23.7833;
time = sort(t);

for t=1:student_num
    s(t)=student;
    s(t).id = t;
    s(t).gender = randi(2,1);%1 for male and 2 for female
    if  s(t).gender == 1
        s(t).speed = 5;
    else
        s(t).speed = 3;
    end
    
    s(t).StartTime = time(t);
    s(t).source = 1; % simple version for this demo
    s(t).dest = 6;
    s(t).loc = 1;
    s(t).last_node = 0;
    s(t).food_require = food_require();
    s(t).floor = unidrnd(8);
    s(t).left_elevator = 0;
    %DecTemp = zeros(l,l);
    %s(t).desitionG= DecTemp;
    if s(t).floor == 1
        s(t).left_elevator = s(t).StartTime;
    else
        Event_queue = insert_Event_queue_new(Event_queue, s(t).StartTime, 1,s(t).id);
    end
end
%%
tt = [];
for i = 1:student_num
    tt = [tt s(i).floor];
end
tt



%now start the time series
t=0;
while(~isempty(Event_queue))%keep moving as long as t less than end_time
    

    %check the event queue
    if isempty(Event_queue)
        %no more event, end the simulation
        break
    else%move to the first event in the event_queue
        [t,type,id,Event_queue]=pop_Event_queue_new(Event_queue);
    end
    
            
    if type == -1 %elevator close the door
        elevator_door = 0;
        if elevator_loc == 1 
            for i = 8:-1:1
                if queue(i,1) ~= 0
                    elevator_dst = i;
                    break;
                end
            end
            if i == 1
                elevator_dst = 0;
            else
                Event_queue = insert_Event_queue_new(Event_queue,t+5*(elevator_dst-1), 0, elevator_dst);
            end
        else
            if num_in_elevator < elevator_num_threshold
                if queue(elevator_loc,1) ~= 0
                    [queue, pop_id] = pop_queue(queue,elevator_loc,elevator_num_threshold-num_in_elevator);
                    while(~isempty(pop_id))
                        temp_id = pop_id(1);
                        queue_in_elevator = [queue_in_elevator temp_id];
                        num_in_elevator = num_in_elevator + 1;
                        pop_id = pop_id(2:length(pop_id));
                    end
                end
                time_arrive_next_floor = t + 5;
                Event_queue = insert_Event_queue_new(Event_queue,time_arrive_next_floor, 0, elevator_loc -1);
            else
                time_arrive_next_floor = t + 5;
                Event_queue = insert_Event_queue_new(Event_queue,time_arrive_next_floor, 0, elevator_loc -1);
            end
        end
        
    elseif type == 0 %elevator change the loc
       elevator_loc = id;
       elevator_door = 1;
       if elevator_loc == 1
           while(num_in_elevator ~= 0)
               temp_id = queue_in_elevator(1);
               s(temp_id).left_elevator = t;
               queue_in_elevator = queue_in_elevator(2:length(queue_in_elevator));
               num_in_elevator = num_in_elevator - 1;
           end
           num_in_elevator = 0;
           queue_in_elevator = [];
           elevator_dst = 0;
           Event_queue = insert_Event_queue_new(Event_queue,t+10 + 50 * rand(), -1, elevator_loc);
       elseif elevator_loc == elevator_dst
           elevator_dst = 1;
           time_elevator_close = t + 10 + 50 * rand();
           Event_queue = insert_Event_queue_new(Event_queue,time_elevator_close, -1, elevator_loc);
           if queue(elevator_loc,1) ~= 0
               [queue, pop_id] = pop_queue(queue,elevator_loc,elevator_num_threshold-num_in_elevator);
                while(~isempty(pop_id))
                    temp_id = pop_id(1);
                    queue_in_elevator = [queue_in_elevator temp_id];
                    num_in_elevator = num_in_elevator + 1;
                    pop_id = pop_id(2:length(pop_id));
                end
           end
       elseif elevator_dst == 1 
           if queue(elevator_loc,1) ~= 0 && num_in_elevator < elevator_num_threshold
               [queue, pop_id] = pop_queue(queue,elevator_loc,elevator_num_threshold-num_in_elevator);
                while(~isempty(pop_id))
                    temp_id = pop_id(1);
                    queue_in_elevator = [queue_in_elevator temp_id];
                    num_in_elevator = num_in_elevator + 1;
                    pop_id = pop_id(2:length(pop_id));
                end
                time_elevator_close = t + 10 + 50 * rand();
                Event_queue = insert_Event_queue_new(Event_queue,time_elevator_close, -1, elevator_loc);
           else
                Event_queue = insert_Event_queue_new(Event_queue,t+5, 0, elevator_loc-1);
           end
       end
    
    
    %check the event type
    elseif type == 1% arrival event
        if elevator_loc == s(id).floor && elevator_door == 1
            if num_in_elevator < elevator_num_threshold
                queue_in_elevator = [queue_in_elevator id];
                num_in_elevator = num_in_elevator + 1;
            else
                temp_num_in_queue = queue(s(id).floor,1);
                queue(s(id).floor,temp_num_in_queue+2) = id;
                queue(s(id).floor,1) = queue(s(id).floor,1) + 1;
            end
        elseif queue(s(id).floor,1) == 0
            temp_num_in_queue = queue(s(id).floor,1);
            queue(s(id).floor,temp_num_in_queue+2) = id;
            queue(s(id).floor,1) = queue(s(id).floor,1) + 1;
            if elevator_loc == 1 && elevator_dst == 0
                for i = 8:-1:1
                    if queue(i,1) ~= 0
                        elevator_dst = i;
                        break;
                    end
                end
                Event_queue = insert_Event_queue_new(Event_queue,t+5*(elevator_dst-1), 0, elevator_dst);
            end
        else %else, join the queue
            temp_num_in_queue = queue(s(id).floor,1);
            queue(s(id).floor,temp_num_in_queue+2) = id;
            queue(s(id).floor,1) = queue(s(id).floor,1) + 1;
        end
    end
end

tt = [];
tt1 = [];
for i =1:student_num
    %if s(i).left_elevator ~= s(i).StartTime
        tt = [tt s(i).left_elevator-s(i).StartTime];
        s(i).floor
        s(i).left_elevator-s(i).StartTime
    %end
end
for i =1:student_num
    tt1 = [tt1 s(i).floor];
end
plot(tt);
set(gca,'XTick',0:1:100);
grid on;
mean(tt)
