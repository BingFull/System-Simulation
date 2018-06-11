clear all
close all


% map = imread('campus.jpg');
% imshow(map);
% hold on

%init parameters in Canteen queuing system
S23 = 80;
s23 = 60;
S45 = 80;
s45 = 60;
alpha = 14.8274; %Rayleigh distribution parameter
mu = 60; %Interval distribution of students' arrival time
%get the time of first arrival
t_next = exprnd(mu);
%queue was used for customer waiting
wait_food_queue23 = []; %Record the time to wait for food 
wait_food_queue45 = [];
food_left23 = S23; %The current amount of surplus food
food_left45 = S45;
supply_interval = 1800; %Time interval for supply food
food_make_time_l = 900; %Lower limit of food production time
food_make_time_h = 1800; %Upper limit of food production time
make_food_time = food_make_time_l + (food_make_time_h - food_make_time_l)*rand();%The time of the food production


NodeList=[1 2 3 4 5 6];
NodeLoc=[101 166;310 306;363 302;168 627;186 701;347 942];
EdgeList=[1 2 10; 2 3 0; 1 4 20; 4 5 0; 5 6 15 ; 3 6 30];%[source dest weight]

% scatter(NodeLoc(:,1),NodeLoc(:,2),'yo')

[m n]= size(EdgeList)
% 
% for i = 1:m
%     n_s=EdgeList(i,1);
%     n_d=EdgeList(i,2);
%     line([NodeLoc(n_s,1) NodeLoc(n_d,1)],[NodeLoc(n_s,2) NodeLoc(n_d,2)],'LineWidth',EdgeList(i,3)./5+1);    
% end

%%
%init c_ij for dijkstra
l=length(NodeList);
c=zeros(l)-1;% use -1 for unlimited flag
for i = 1:m
    n_s=EdgeList(i,1);
    n_d=EdgeList(i,2);
    c(n_s,n_d)=   EdgeList(i,3);
    c(n_d,n_s)=   EdgeList(i,3);
end

%%
%init student with randomlized decision graph

%init the event queue
Event_queue= [];

%set the student number
student_num = 100;

%time=sort(randn(1,student_num));
t1 = randn([1, student_num]);
t2 = randn([1, student_num]);
t = t1 * 24.7631 + 93.3616 + t2 * sqrt(8.6084) + 23.7833;
time = sort(t);

c_upper=triu(c);
temp = tril(ones(l,l))-eye(l);
c_upper = c_upper - temp;
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
    s(t).left_canteen_time = 0;
    DecTemp = zeros(l,l);
    for i=1:l-1
        route=Dijkstra(i,s(t).dest,c,NodeList);
        prime_next_node = route(2);
        DecTemp(i,prime_next_node)= 1;
        for j = 1:l
            if(c_upper(i,j)~=-1)
                if (j~=prime_next_node)
                     temp = rand*0.2;
                     DecTemp(i,prime_next_node)= DecTemp(i,prime_next_node) - temp;
                     DecTemp(i,j)= temp;
                end
            end
            
        end
    end
    s(t).desitionG= DecTemp;
   
    %push the initial events
    Event_queue = insert_Event_queue_new(Event_queue, s(t).StartTime, 1,s(t).id);
end

Event_queue = insert_Event_queue_new(Event_queue, supply_interval, -11, 0);
Event_queue = insert_Event_queue_new(Event_queue, supply_interval, -11, 1);
ttt = 0;

endTime = 6000

%eventID:
%1: leaving a node
%2: arriving a node
%21: arriving a queue edge of 2-3
%22: serving finish event of a queue edge of 2-3
%41: arriving a queue edge of 4-5
%42: serving finish event of a queue edge of 4-5


%set a copy of c as the realtime graph with weight of students in edge
w=c_upper;
[I,J] = size(c);
for i=1:I
    for j=1:J
        if w(i,j)~=-1
            w(i,j)=0;
        end
    end
end


%%
%now start the simulation
queue23 = [];
queue45 = [];
server_status23 = 0;
server_status45 = 0;
t = 0;
while(~isempty(Event_queue) && t < endTime)
    
    %check the event queue
    if isempty(Event_queue)
        %no more event, end the simulation
        break
    else%move to the first event in the event_queue
        [t,type,id,Event_queue]=pop_Event_queue_new(Event_queue);
    end
    
    
    if type == -11 %check the food left
        if id == 0 %the node 23
            if food_left23 < s23
                make_food_time = food_make_time_l + (food_make_time_h - food_make_time_l)*rand();
                Event_queue = insert_Event_queue_new(Event_queue, t+make_food_time, -12, 0);
            end
            Event_queue = insert_Event_queue_new(Event_queue, t+supply_interval, -11,0);
        elseif id == 1 %the node 45
            if food_left45 < s45
                make_food_time = food_make_time_l + (food_make_time_h - food_make_time_l)*rand();
                Event_queue = insert_Event_queue_new(Event_queue, t+make_food_time, -12, 1);
            end
            Event_queue = insert_Event_queue_new(Event_queue, t+supply_interval, -11,1);
        end
        
    elseif type == -12 %supplement food
        if id == 0 %the node 23
            food_left23 = food_left23 + S23;
            while (length(wait_food_queue23) > 0)
                id_temp = wait_food_queue23(1);
                if food_left23 > s(id_temp).food_require
                    food_left23 = food_left23 - s(id_temp).food_require;
                    wait_food_queue23 = wait_food_queue23(2:length(wait_food_queue23));
                    %sent the served student to next node
                    s(id_temp).loc = 3;
                    s(id_temp).last_node = 2;
                    s(id_temp).left_canteen_time = t;
                    ttt = ttt+1;
                    Event_queue = insert_Event_queue_new(Event_queue, t, 2,s(id_temp).id);
                    disp(['Time:',num2str(t),', student ',num2str(id_temp),' leveing queue process of node 2.']);
                else
                    break;
                end
            end
        elseif id == 1 %the node 45
            food_left45 = food_left45 + S45;
            while (length(wait_food_queue45) > 0)
                id_temp = wait_food_queue45(1);
                if food_left45 > s(id_temp).food_require
                    food_left45 = food_left45 - s(id_temp).food_require;
                    wait_food_queue45 = wait_food_queue45(2:length(wait_food_queue45));
                    %sent the served student to next node
                    s(id_temp).loc = 5;
                    s(id_temp).last_node = 4;
                    s(id_temp).left_canteen_time = t;
                    ttt = ttt+1;
                    Event_queue = insert_Event_queue_new(Event_queue, t, 2,s(id_temp).id);
                    disp(['Time:',num2str(t),', student ',num2str(id_temp),' leveing queue process of node 4.']);
                else
                    break;
                end
            end
        end   
        
    %process the events
    elseif type ==1 %leaving a node
        %find the current node
        n_s = s(id).loc;
        %make the decision of next node
        DecTemp = s(id).desitionG;
        temp = rand();% throw the dice
        n_d = 0;
        for i=1:I
            if (DecTemp(n_s,i) ~= 0)
                if(temp <= DecTemp(n_s,i))
                    n_d = i;
                    disp(['The next node of student ',num2str(id),' is :',num2str(n_d)]);
                    break;
                else
                    temp = temp - DecTemp(n_s,i);
                end
            end
        end
        if n_d == 0
            disp('something wrong');
            break
        end
        %check whether the next edge is a moving edge or a queue edge
        if c(n_s,n_d) ~= 0%moving edge
            tempW = w(n_s,n_d);
            distance = c(n_s,n_d);
            v=BPR(s(id).speed,tempW,20);
            time = t + distance./v;
            s(id).loc = n_d;
            s(id).last_node = n_s;
            w(n_s,n_d) = w(n_s,n_d) + 1;
            Event_queue = insert_Event_queue_new(Event_queue, time, 2,s(id).id);
            disp(['Time:',num2str(t),', student ',num2str(id),' start moving from node:',num2str(s(id).last_node),' to node:',num2str(s(id).loc),' via speed:',num2str(v)]);
        
        elseif c(n_s,n_d) == 0%queue edge
            
            %join the queue edge
            if n_s == 2
                Event_queue = insert_Event_queue_new(Event_queue, t, 21,s(id).id);
            elseif n_s ==4
                Event_queue = insert_Event_queue_new(Event_queue, t, 41,s(id).id);
            end
                
        else% something wrong
            disp('something wrong')
        end
    elseif type ==2 %arriving a node
        w(s(id).last_node,s(id).loc) = w(s(id).last_node,s(id).loc) - 1;
        disp(['Time:',num2str(t),', student ',num2str(id),' arrives node:',num2str(s(id).loc),' from node:',num2str(s(id).last_node)]);
        if s(id).loc == s(id).dest %arrival final dest
            disp(['Time:',num2str(t),', student ',num2str(id),' arrives dest'])
        else
            Event_queue = insert_Event_queue_new(Event_queue, t, 1,s(id).id);%loop in the route
        end
        
    elseif type ==21 %arriving a queue edge 23
        disp(['Time:',num2str(t),', student ',num2str(id),' starts the queueing process in node:',num2str(s(id).loc)]);
        w(2,3) = w(2,3) + 1;
        if length(queue23) == 0
        %if queue if empty, check server status
            if server_status23 == 0
            %if server is free, get serivce time
                t_service = t + raylrnd(alpha);
                %insert the event into event queue
                Event_queue = insert_Event_queue_new(Event_queue, t_service, 22,s(id).id);
                %Event_queue = insert_Event_queue(Event_queue,t_service, 2);
                server_status23 = 1;%set the server into busy

            %else, join the queue
            else
                queue23 = [queue23 s(id).id];
                %queue_length = [queue_length length(queue)];
            end
        %else, join the queue
        else
            queue23 = [queue23 s(id).id]; 
           
            %queue_length = [queue_length length(queue)];
        end
    elseif type ==22 %serving finish of a queue edge 23
        if server_status23 == 1
            if s(id).food_require < food_left23
                food_left23 = food_left23 - s(id).food_require;
                %sent the served student to next node
                s(id).loc = 3;
                s(id).last_node = 2;
                s(id).left_canteen_time = t;
                ttt = ttt+1;
                Event_queue = insert_Event_queue_new(Event_queue, t, 2,s(id).id);
                disp(['Time:',num2str(t),', student ',num2str(id),' leaveing queue process of node 2.']);
            else
                wait_food_queue23 = [wait_food_queue23 id];
            end
            
           server_status23 = 0;
           t_service = 0;
          % w(2,3) = w(2,3) - 1;
            
     
           %check whether there is customer waiting in the queue
           if length(queue23) > 0
            %if queue is not empty, get the first node serviced
                ID_queue = queue23(1);
                queue23 = queue23(2:length(queue23));
                server_status23 = 1;%set the server into busy
                t_service = t + raylrnd(alpha);
                %insert the event into event queue
                 Event_queue = insert_Event_queue_new(Event_queue, t_service, 22,s(ID_queue).id);
           else
               %do nothing, waiting for next customer
           end       
        end
    elseif type ==41 %arriving a queue edge 45
        disp(['Time:',num2str(t),', student ',num2str(id),' starts the queueing process in node:',num2str(s(id).loc)]);
        w(4,5) = w(4,5) + 1;
        if length(queue45) == 0
        %if queue if empty, check server status
            if server_status45 == 0
            %if server is free, get serivce time
                t_service = t + raylrnd(alpha);
                %insert the event into event queue
                Event_queue = insert_Event_queue_new(Event_queue, t_service, 42,s(id).id);
                %Event_queue = insert_Event_queue(Event_queue,t_service, 2);
                server_status45 = 1;%set the server into busy

            %else, join the queue
            else
                queue45 = [queue45 s(id).id];
                %queue_length = [queue_length length(queue)];
            end
        %else, join the queue
        else
            queue45 = [queue45 s(id).id]; 
           
            %queue_length = [queue_length length(queue)];
        end
        
    elseif type ==42 %serving finish of a queue edge 43
        if server_status45 == 1
            if s(id).food_require < food_left45
                food_left45 = food_left45 - s(id).food_require;
               %sent the served student to next node
                s(id).loc = 5;
                s(id).last_node = 4;
                s(id).left_canteen_time = t;
                ttt = ttt+1;
                Event_queue = insert_Event_queue_new(Event_queue, t, 2,s(id).id);
                disp(['Time:',num2str(t),', student ',num2str(id),' leaveing queue process of node 4.']);
            else
                wait_food_queue45 = [wait_food_queue45 id];
            end

            server_status45 = 0;
            t_service = 0;
            
           %check whether there is customer waiting in the queue
           if length(queue45) > 0
            %if queue is not empty, get the first node serviced
                ID_queue = queue45(1);
                queue45 = queue45(2:length(queue45));
                server_status45 = 1;%set the server into busy
                t_service = t + raylrnd(alpha);
                %insert the event into event queue
                 Event_queue = insert_Event_queue_new(Event_queue, t_service, 42,s(ID_queue).id);
           else
               %do nothing, waiting for next customer
           end       
        end
    end
end

tt = [];
for i =1:student_num
    %if s(i).left_elevator ~= s(i).StartTime
        tt = [tt s(i).left_canteen_time - s(i).StartTime];
    %end
end
plot(tt);
set(gca,'XTick',0:1:100);
grid on;
mean(tt)

