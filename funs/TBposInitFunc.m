function TBpos = TBposInitFunc(PSTA, TBposFull)
% position term table
N = length(PSTA);
TBpos = zeros(N,N); % TBpos(i,j) means z copied by Pos_j from Pos_i
for i = 1:N
    TBpos(i,:) = TBposFull(PSTA(i),PSTA);
end
end