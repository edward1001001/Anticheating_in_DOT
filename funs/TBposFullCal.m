function TBposFull = TBposFullCal(Positions)
N = size(Positions,1);
TBposFull = zeros(N,N); % TBpos(i,j) means z copied by Pos_j from Pos_i
for i = 1:N
    RefOrder = Positions(i,:);
    for j = 1:N
        Order = Positions(j,:);
        if i==j
            TBposFull(i,j) = 1;
        else
            TBposFull(i,j) =  ASC_Cal(RefOrder,Order,0);
        end
    end
end
end