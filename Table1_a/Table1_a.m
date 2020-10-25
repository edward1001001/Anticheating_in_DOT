clear
clc

rng(1000);
addpath('..\funcs')

% number of students
N = 85;
settings.N = N;
% number of MCQs in each Problem set
M = 40;
settings.M = M;
% total number of MCQs in the pool
Mp = 60;
settings.Mp = Mp;
% # of choices in each MCQ
Q = 4;
settings.Q = 4;

settings.ita = 5;
settings.allcheatflg = 1;


% input student ability
load('Yo.mat')
settings.Y = Yo;

[TBin,Yo] = TBinGen(settings);

% PSets pool calculation
PSetsPool = PoolGenbycircshift(M,Mp,-1);
TBposFull = TBposFullCal(PSetsPool);

PSTA0 = GenSchemeV2(settings);
TBposGE= TBposInitFunc(PSTA0, TBposFull);
% load('NoiseMat.mat','NoiseMat')
%% Optimization
tic
PSTA = PSTA0;
tLoss = 1000;
tPSTA = PSTA0;
Nrep = 10;
Nop = 30;
for irep = 1:Nrep
    for itag = 1:Nop
        [FlossR2, ~, nPSTA] = PosOptimizationFullV2(TBin,PSTA,TBposFull);
        if sum(abs(nPSTA(:)-PSTA(:)))==0
            PSTA = nPSTA;
            break;
        else
            PSTA = nPSTA;
        end
    end
    if tLoss>FlossR2(end)
        tLoss = FlossR2(end);
        tPSTA = PSTA;
    end
    
    % some random initialization
    PSTA = randsample(1:Mp,N,true);
    if irep < 4
        PSTA = ones(1,N)*irep; 
    end
end
TBposOPT= TBposInitFunc(tPSTA, TBposFull);
Fopt0 = sum(TBposOPT(:).*TBin(:)); % optimized
[worstLoss,EgM,~] = WorstLossCal(TBposOPT,Yo);
FWopt0(1) = worstLoss;
FWopt0(2) = max(EgM);
toc

%% Results Check
Ncases = 500;
% 
F0 = zeros(3,Ncases); %conventional scinario
Fgen = zeros(3,Ncases); % general scheme scinario
Fopt = zeros(3,Ncases); % optimized scinario

FW0 = zeros(6,Ncases);
FWgen = zeros(6,Ncases);
FWopt = zeros(6,Ncases);

NoiseMat = normrnd(0,0.05,[Ncases,length(Yo)]);

TBposOPTp = TBposOPT;

caseInfo = cell(3,1);
%(1) Noisy Y and Heuristic P
casetag = 1;
caseInfo{casetag} = 'Noisy Y and Heuristic P\r\n';
NoiseYmat = zeros(Ncases, length(Yo));
for iter = 1:Ncases
    Y = Yo' + NoiseMat(iter,:);
    Y(Y>1) = 1;
    Y(Y<0.25) = 0.25;
    Y = deRepetition(Y');
    NoiseYmat(iter,:) = Y;
      
    [Y,idx] = sort(Y,'descend') ;
    settings.Y = Y;
    [TBinp,~] = TBinGen(settings);
    F0(casetag,iter) = sum(TBinp(:)); %conventional
    [worstLoss,EgM,~] = WorstLossCal(ones(N,N),Y);
    FW0(2*casetag-1,iter) = worstLoss;
    FW0(2*casetag,iter) = max(EgM);
    
    TBposGEresort = TBposGE(idx,:);
    TBposGEresort = TBposGEresort(:,idx);
    Fgen(casetag,iter) = sum(TBposGEresort(:).*TBinp(:)); % general
    [worstLoss,EgM,~] = WorstLossCal(TBposGEresort,Y);
    FWgen(2*casetag-1,iter) = worstLoss;
    FWgen(2*casetag,iter) = max(EgM);
    
    TBposOPTpresort = TBposOPTp(idx,:);
    TBposOPTpresort = TBposOPTpresort(:,idx);
    Fopt(casetag,iter) = sum(TBposOPTpresort(:).*TBinp(:)); % optimized
    [worstLoss,EgM,~] = WorstLossCal(TBposOPTpresort,Y);
    FWopt(2*casetag-1,iter) = worstLoss;
    FWopt(2*casetag,iter) = max(EgM);
end

%(2) Noisy Y and Random P
fldname = './';
instancefld = sprintf('%d_%d_%d_instances',N,Mp,M);
Insfiles = dir([fldname,instancefld,'/*.mat']);
casetag = 2;
caseInfo{casetag} = 'Noisy Y and Random P\r\n';
for iter = 1:Ncases
    
    Y = NoiseYmat(iter,:);
    
    ifilename = [Insfiles(iter).folder,'/',num2str(iter-1),'.mat'];
    load(ifilename,'instance');
    TBp = instance{1,5}';
    TBinp = TBinCalwithYP(Y,TBp);
    
    F0(casetag,iter) = sum(TBinp(:)); %conventional
    [worstLoss,EgM,~] = WorstLossCal(ones(N,N),Y);
    FW0(2*casetag-1,iter) = worstLoss;
    FW0(2*casetag,iter) = max(EgM);
    
    Fgen(casetag,iter) = sum(TBposGE(:).*TBinp(:)); % general
    [worstLoss,EgM,~] = WorstLossCal(TBposGE,Y);
    FWgen(2*casetag-1,iter) = worstLoss;
    FWgen(2*casetag,iter) = max(EgM);
    
    Fopt(casetag,iter) = sum(TBposOPTp(:).*TBinp(:)); % optimized
    [worstLoss,EgM,~] = WorstLossCal(TBposOPTp,Y);
    FWopt(2*casetag-1,iter) = worstLoss;
    FWopt(2*casetag,iter) = max(EgM);
end

%(3) Accurate Y and Random P
casetag = 3;
caseInfo{casetag} = 'Accurate Y and Random P\r\n';
for iter = 1:Ncases
    
    Y = Yo';
    
    ifilename = [Insfiles(iter).folder,'/',num2str(iter-1),'.mat'];
    load(ifilename,'instance');
    TBp = instance{1,5}';
    TBinp = TBinCalwithYP(Y,TBp);
    
    F0(casetag,iter) = sum(TBinp(:)); %conventional
    [worstLoss,EgM,~] = WorstLossCal(ones(N,N),Y);
    FW0(2*casetag-1,iter) = worstLoss;
    FW0(2*casetag,iter) = max(EgM);
    
    Fgen(casetag,iter) = sum(TBposGE(:).*TBinp(:)); % general
    [worstLoss,EgM,~] = WorstLossCal(TBposGE,Y);
    FWgen(2*casetag-1,iter) = worstLoss;
    FWgen(2*casetag,iter) = max(EgM);
    
    Fopt(casetag,iter) = sum(TBposOPTp(:).*TBinp(:)); % optimized
    [worstLoss,EgM,~] = WorstLossCal(TBposOPTp,Y);
    FWopt(2*casetag-1,iter) = worstLoss;
    FWopt(2*casetag,iter) = max(EgM);
    
end

% result recombined
%          1:3,4:9,10:12,13:18,19:21,22:27         
ResultMat = [F0/N;FW0./[N;1;N;1;N;1];Fgen/N;FWgen./[N;1;N;1;N;1];Fopt/N;FWopt./[N;1;N;1;N;1]];
meanMat = mean(ResultMat,2);
stdMat = std(ResultMat,0,2);


fileID = fopen('Table1_a.txt','w');
for icase = 1:3
fprintf(fileID,caseInfo{icase});    
itemp = [meanMat(icase),stdMat(icase),meanMat(3+2*icase-1),stdMat(3+2*icase-1),meanMat(3+2*icase),stdMat(3+2*icase)];
fprintf(fileID,'None & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
itemp = [meanMat(9+icase),stdMat(9+icase),meanMat(12+2*icase-1),stdMat(12+2*icase-1),meanMat(12+2*icase),stdMat(12+2*icase)];
fprintf(fileID,' GAS & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
itemp = [meanMat(18+icase),stdMat(18+icase),meanMat(21+2*icase-1),stdMat(21+2*icase-1),meanMat(21+2*icase),stdMat(21+2*icase)];
fprintf(fileID,'Opti & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
fprintf(fileID,'\r\n');
end
fclose(fileID);


%%
function Y = deRepetition(Y)
N = length(Y);
for itag = 1:(N-1)
    Nrep = sum(Y==Y(itag));
    if Nrep > 1
        coefM = 0.99999.^((1:Nrep)-1);
        Y(Y==Y(itag)) = Y(Y==Y(itag)).*coefM(:);
    end  
end
end

function TBin = TBinCalwithYP(y,TBp)
N = length(y);
% inherent term table
TBin = zeros(N,N);
for i = 2:N
    for j = 1:N
        TBin(j,i) = (y(j) - y(i))*TBp(j,i);
    end
end
TBin(TBin<0) = 0;
end
