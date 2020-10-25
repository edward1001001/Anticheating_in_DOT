function [FlossR, Floss0, PSTA] = PosOptimizationFullV2(TBin,PSTA,TBposFull)
% number of students
N = length(PSTA);
% total number of MCQs in the pool
Mp = size(TBposFull,1);


TBpos = TBposInit(PSTA, TBposFull);

Floss0 = sum(TBin(:).*TBpos(:));

FlossR = zeros(1,N);

tLoss0 = TBpos(:)'*TBin(:);
for i = 1:N % ith bit to change
%     iH = PSTA(i); % every J will replace this
    tLoss = 1000; % this surely will be updated with j=1, but it will change back to j=PSTA(i) if j=1 not good
    for j = 1:Mp % change to jth bit in the pool
        % nTBpos = TBposUpdate(i,j,PSTA,TBpos,TBposFull);
        % iLoss = sum(nTBpos(:).*TBin(:));
        iLoss = tLoss0 + dLossOfPosChange(i,j,PSTA,TBpos,TBposFull,TBin);
        if tLoss>iLoss
            tLoss = iLoss;
            iH = j;
        end
    end
    TBpos = TBposUpdate(i,iH,PSTA,TBpos,TBposFull);
    PSTA(i) = iH;
    FlossR(i) = tLoss;
    tLoss0 = tLoss;
end
end


% function nTBpos = TBposUpdate(i,j,PSTA,TBpos,TBposFull)
% nTBpos = TBpos;
% RPos = PSTA(i+1:end);
% nTBpos(i,i:end) = TBposFull(j,[j,RPos]); % right part of row
% if i > 1
%     LPos = PSTA(1:(i-1));
%     nTBpos(1:(i-1),i) = TBposFull(LPos,j);
% end
% end

function dLoss = dLossOfPosChange(i,j,PSTA,TBpos,TBposFull,TBin)
    Loss0 = TBpos(i,:)*TBin(i,:)' + TBpos(:,i)'*TBin(:,i) - TBpos(i,i)'*TBin(i,i);
    PSTA(i) = j;
    Loss1 = TBposFull(j,PSTA)*TBin(i,:)' + TBposFull(PSTA,j)'*TBin(:,i) - TBposFull(j,j)'*TBin(i,i);
    dLoss = Loss1-Loss0;
end


function nTBpos = TBposUpdate(i,j,PSTA,TBpos,TBposFull)
nTBpos = TBpos;
PSTA(i) = j;
nTBpos(i,:) = TBposFull(j,PSTA);
nTBpos(:,i) = TBposFull(PSTA,j);
end

function TBpos = TBposInit2(PSTA, TBposFull)
% position term table
N = length(PSTA);
TBpos = zeros(N,N); % TBpos(i,j) means z copied by Pos_j from Pos_i
for i = 1:N
    for j = 1:N
            TBpos(i,j) = TBposFull(PSTA(i),PSTA(j));
    end
end
end

function TBpos = TBposInit(PSTA, TBposFull)
% position term table
N = length(PSTA);
TBpos = zeros(N,N); % TBpos(i,j) means z copied by Pos_j from Pos_i
for i = 1:N
    TBpos(i,:) = TBposFull(PSTA(i),PSTA);
end
end

function PosOrder = PosArrange(PosRecord,PosLeft)
N = length(PosRecord)+length(PosLeft);
PosOrder = zeros(1,N);
% LeftSel = ones(1,N);
% LeftSel(PosRecord) = zeros(1,length(PosRecord));
% PosOrder(LeftSel) = PosLeft;
PosOrder(PosRecord) = 1:length(PosRecord);
PosOrder(PosOrder==0) = PosLeft;
end

function nPosBox = DelItem(PosBox,idx)
if idx == 1
    nPosBox = PosBox(2:end);
elseif idx == length(PosBox)
    nPosBox = PosBox(1:(end-1));
else
    nPosBox = [PosBox(1:(idx-1)),PosBox((idx+1):end)];
end
end

function [Floss,nTBpos] = LossCal(TBpos,TBin,iPosOrder)
N = length(iPosOrder);
Psdescent = zeros(1,N);
Psdescent(iPosOrder) = 1:N;
nTBpos = zeros(N,N);
for i = 1:N
    for j = (i+1):N
        nTBpos(i,j) = TBpos(Psdescent(i),Psdescent(j));
    end
end
Floss = sum(TBin(:).*nTBpos(:));
end