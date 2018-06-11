clear all
close all

start_time = cputime
%set the simulation time,unit min
end_time = 10000;

%set the step size
step = 0.01;%0.1 0.5


%assume there is only one server and one queue
%set the arrival rate and service rate
lamda = 1/6;
mu = 1/8;

%get the time of first arrival
t_next = exprnd(lamda);

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

    %check whether there is customer arrived
    if t > t_next %customer arrived
        %check queue first        
        if length(queue) == 0
        %if queue if empty, check server status
            if server_status == 0
            %if server is free, get serivce time
                t_service = t + exprnd(mu);
                server_status = 1;%set the server into busy
                %record something
                wait_time = [wait_time 0];
                busy_time = busy_time + t_service - t;
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
        t_next = t + exprnd(lamda);
    else
        %do nothing
    end
    
    %if server is busy check whether it will finish in this slot
   if server_status == 1 && t > t_service
       server_status = 0;
       t_service = 0;
       %check whether there is customer waiting in the queue
       if length(queue) > 0
        %if queue is not empty, get the first node serviced
            temp_time_wait = queue(1);
            queue = queue(2:length(queue));
            t_service = t + exprnd(mu);
            server_status = 1;%set the server into busy
                
            %record something   
            wait_time = [wait_time t-temp_time_wait];
            busy_time = busy_time + t_service - t;
       else
           %do nothing, waiting for next customer
       end
   end  
end

wait_sim=mean(wait_time)
rho=mu/lamda;
wait_theroy=rho.^2/(1-rho)*lamda

utilization=busy_time/end_time
plot(wait_time)

last_time = cputime - start_time
