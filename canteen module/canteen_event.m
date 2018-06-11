clear all
close all

%set the simulation time,unit min
end_time = 10000

%set the step size
%step = 0.01
S = 80;
s = 60;

%assume there is only one server and one queue
%set the arrival rate and service rate
alpha = 14.8274; %Rayleigh distribution parameter
mu = 60;

%get the time of first arrival
t_next = exprnd(mu);

%set the format of event queue, 1st :time 2nd:event type(1,arrival, 2 service
%end)
Event_queue= [];
Event_queue = insert_Event_queue(Event_queue,t_next, 1);

%queue was used for customer waiting
wait_for_serve_queue= [];

%set the status of server, 0 means free 1 means busy
server_status = 0;
%t_service = 0;

%set the record values for statistic
%wait_time = [];
%queue_length=[];
busy_time = 0;

wait_food_queue = []; %Record the time to wait for food 
wait_food_time = []; %Record how long everyone waits for food
food_left = S; %The current amount of surplus food
supply_interval = 1800; %Time interval for supply food
food_make_time_l = 900; %Lower limit of food production time
food_make_time_h = 1800; %Upper limit of food production time
food_require_in_queue = []; %Food needs of everyone in the queue
wait_queue_time = []; %Waiting time in queue
student_num = 0; %The number of students
food_left_list = [];
fd = [];
x = [];
fl = [];
wq = [];
wf = [];
make_food_time = food_make_time_l + (food_make_time_h - food_make_time_l)*rand();
last_make_food_time = make_food_time;
check_times = 1;
Event_queue = insert_Event_queue(Event_queue,supply_interval, -1);
%now start the time series
t=0;
while(t<end_time)%keep moving as long as t less than end_time
    

    %check the event queue
    if isempty(Event_queue)
        %no more event, end the simulation
        break
    else%move to the first event in the event_queue
        [t type Event_queue]=pop_Event_queue(Event_queue);
    end
    
    
%     if mod(t,supply_interval) >= make_food_time && t/supply_interval >= check_times
%         if(food_left < s)
%             food_left = food_left + S;
%             last_make_food_time = make_food_time;
%             make_food_time = food_make_time_l + (food_make_time_h - food_make_time_l)*rand();
%             check_times = check_times + 1;
%         end
%     end
%     
%     while (length(food_require_in_queue) > 0 && (food_left > food_require_in_queue(1)))
%         if food_require_in_queue(1) == 0
%             wait_food_time = [wait_food_time 0];
%             food_require_in_queue = food_require_in_queue(2:length(food_require_in_queue));
%         else
%             food_left = food_left - food_require_in_queue(1);
%             wait_food_time = [wait_food_time (check_times-1)*supply_interval + last_make_food_time - wait_food_queue(1)];
%             wait_food_queue = wait_food_queue(2:length(wait_food_queue));
%             food_require_in_queue = food_require_in_queue(2:length(food_require_in_queue));
%         end
%     end
    
    x = [x, t];
    fl = [fl, food_left];
    wq = [wq, length(wait_for_serve_queue)];
    wf = [wf, length(wait_food_queue)];
    
    if type == -1 %check the food left
        if(food_left < s)
            make_food_time = food_make_time_l + (food_make_time_h - food_make_time_l)*rand();
            Event_queue = insert_Event_queue(Event_queue,t+make_food_time, 0);
        end
        Event_queue = insert_Event_queue(Event_queue,t+supply_interval, -1);
        
    elseif type == 0 %supplement food
        food_left = food_left + S;
        while (length(food_require_in_queue) > 0 && (food_left > food_require_in_queue(1)))
            if food_require_in_queue(1) == 0
                wait_food_time = [wait_food_time 0];
                food_require_in_queue = food_require_in_queue(2:length(food_require_in_queue));
            else
                food_left = food_left - food_require_in_queue(1);
                wait_food_time = [wait_food_time t - wait_food_queue(1)];
                wait_food_queue = wait_food_queue(2:length(wait_food_queue));
                food_require_in_queue = food_require_in_queue(2:length(food_require_in_queue));
            end
        end
    
    %check the event type
    elseif type == 1% arrival event
        student_num = student_num + 1;
        food_left_list = [food_left_list food_left];
         %check queue first        
        if length(wait_for_serve_queue) == 0
        %if queue if empty, check server status
            if server_status == 0
            %if server is free, get serivce time
                t_talk = t + raylrnd(alpha);
                %insert the event into event queue
                Event_queue = insert_Event_queue(Event_queue,t_talk, 2);
                server_status = 1;%set the server into busy
                %record something
                wait_queue_time = [wait_queue_time 0];
                busy_time = busy_time + t_talk-t;
            %else, join the queue
            else
                wait_for_serve_queue = [wait_for_serve_queue t_next];
                %queue_length = [queue_length length(queue)];
            end
        %else, join the queue
        else
            wait_for_serve_queue = [wait_for_serve_queue t_next];    
            %queue_length = [queue_length length(queue)];
        end
        % now set the arrival time of next customer
        t_next = t + exprnd(mu);
        %insert the event into event queue
        Event_queue = insert_Event_queue(Event_queue,t_next, 1);
        
    elseif type == 2
       if server_status == 1
           food_req = food_require();
           fd = [fd food_req];
           if food_req <= food_left
                food_require_in_queue = [food_require_in_queue 0];
                food_left = food_left - food_req;
           else
                wait_food_queue = [wait_food_queue t_talk];
                food_require_in_queue = [food_require_in_queue food_req];
           end
           
           server_status = 0;
           t_service = 0;
           %record something

           %check whether there is customer waiting in the queue
           if length(wait_for_serve_queue) > 0
            %if queue is not empty, get the first node serviced
                temp_time_wait = wait_for_serve_queue(1);
                wait_for_serve_queue = wait_for_serve_queue(2:length(wait_for_serve_queue));
                t_talk = t + raylrnd(alpha);
                server_status = 1;%set the server into busy
                %insert the event into event queue
                Event_queue = insert_Event_queue(Event_queue,t_talk, 2);
                
                %record something   
                wait_queue_time = [wait_queue_time t-temp_time_wait];
                busy_time = busy_time + t_talk - t;
           else
               %do nothing, waiting for next customer
           end       
        end
    end
        
        
    
end

wait_mean=mean(wait_queue_time)
wait_food_mean = mean(wait_food_time)
% rho=mu/lamda;
% wait_theroy=rho.^2/(1-rho)*lamda
% 
 utilization=busy_time/end_time

student_num
food_require_mean = mean(fd)


figure
plot(x,wq,x,wf)
set(gca,'XTick',0:1000:12000);
legend('排队人数','等待食物人数');
figure
plot(x,fl)
set(gca,'XTick',0:1000:12000);
title('食物余量')
