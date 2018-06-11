clear all
close all

start_time = 0;
%set the simulation time,unit min
end_time = 10800.1;

%set the step size
step = 0.01;%0.1 0.5

s = 60; %Inventory threshold
S = 60; %The amount of food made
alpha = 14.8274; %Rayleigh distribution parameter  
wait_food_queue = []; %Record the time to wait for food 
wait_food_time = []; %Record how long everyone waits for food
food_left = S; %The current amount of surplus food
supply_interval = 1800; %Time interval for supply food
supply_time = 0; %The time to supply food next time
supply_status = 0; %Set the status of suppling food, 0 means needing to supply food, 1 means the opposite
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
%assume there is only one server and one queue
%set the arrival rate and service rate
mu = 60;

%get the time of first arrival
t_next = exprnd(mu);

%set the format of queue, the first node is 0 means the start.
queue = [];

%set the status of server, 0 means free 1 means busy
server_status = 0;
t_service = 0;

%set the record values for statistic
wait_time = [];
queue_length=[];
busy_time = 0;
%now set the increment of time line

for t = 0 : step : end_time
    %
    if supply_status == 1 && t >= supply_time
        food_left = food_left + S;
        supply_status = 0;
        
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
    end
   
    if mod(t,1) == 0
        x = [x, t];
        fl = [fl, food_left];
        wq = [wq, length(queue)];
        wf = [wf, length(wait_food_queue)];
    end

    
    if mod(t,supply_interval) == 0
        if(food_left < s)
            supply_status = 1;
            supply_time = t + food_make_time_l + (food_make_time_h - food_make_time_l)*rand();
        end
    end
    
    %check whether there is customer arrived
    if t > t_next %customer arrived
        student_num = student_num + 1;
        food_left_list = [food_left_list food_left];
        %check queue first        
        if isempty(queue)
        %if queue if empty, check server status
            if server_status == 0
            %if server is free, get serivce time
                t_talk = t + raylrnd(alpha);
                server_status = 1;%set the server into busy
               
                %record something
                wait_queue_time = [wait_queue_time 0];
                busy_time = busy_time + t_talk - t;
            %else, join the queue
            else
                queue = [queue t_next];
                %queue_length = [queue_length length(queue)];
            end
        %else, join the queue
        else
            queue = [queue t_next];    
            %queue_length = [queue_length length(queue)];
        end
        
        % now set the arrival time of next customer
        t_next = t + exprnd(mu);
    else
        %do nothing
    end
    
    %if server is busy check whether it will finish in this slot
   if server_status == 1 && t > t_talk
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
       t_talk = 0;
       
       %check whether there is customer waiting in the queue
       if ~isempty(queue)
        %if queue is not empty, get the first node serviced
            temp_time_wait = queue(1);
            queue = queue(2:length(queue));
            t_talk = t + raylrnd(alpha);
            server_status = 1;%set the server into busy
                
            %record something   
            wait_queue_time = [wait_queue_time t-temp_time_wait];
            busy_time = busy_time + t_talk - t;
            
       else
           %do nothing, waiting for next customer
       end
   end 
   
end

wait_mean=mean(wait_queue_time)
wait_food_mean = mean(wait_food_time)
% rho=mu/lamda;
% wait_theroy=rho.^2/(1-rho)*lamda
% 
 utilization=busy_time/end_time

student_num = student_num
food_require_mean = mean(fd)

figure
plot(x,wq,x,wf)
set(gca,'XTick',0:1000:12000);
legend('排队人数','等待食物人数');
figure
plot(x,fl)
set(gca,'XTick',0:1000:12000);
title('食物余量')


