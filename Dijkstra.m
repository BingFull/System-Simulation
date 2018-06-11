function route=Dijkstra(source,dest,c,NodeList)
[l,i]=size(c);
D=zeros(1,l);
p=zeros(1,l)+inf;
%source=1;
S=[source];
%find the first itration.
for i=1:l
    if c(source,i)~= -1
        D(i)=c(source,i);
        p(i)=source;
    else
        D(i)=inf;
    end
end
% D %show the init of D 
% p
% S


while(length(S)~=length(NodeList))
    Candidate = setdiff(NodeList,S);
    minCan = [];
    for i=1:length(Candidate)
        minCan = [minCan D(Candidate(i))];
    end
    [Y,I] = min(minCan); %show which node is the next iteration
    I= Candidate(I);
    S=[S I];
    
    Candidate = setdiff(NodeList,S);

    for i=1:length(Candidate)
        if c(I,Candidate(i))~= -1
            temp=D(I)+c(I,Candidate(i));
            if temp < D(Candidate(i))
                D(Candidate(i))=temp;
                p(Candidate(i)) = I;
            end
        end
    end
end


%dest = 6
route =[dest];
while(p(dest)~=source)
    
route = [route p(dest)];
dest = p(dest);
end
route = [route source];     
route = flip(route);

end

