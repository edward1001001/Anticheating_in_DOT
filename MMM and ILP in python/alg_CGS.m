clear
clc

%% loading instances
fldname = '.\';
Ncases = 100; 

settingsCell = {
    [5,3,2]; % 1
    [5,3,3]; % 2
    [10,3,2];% 3
    [10,5,3];% 4
    [10,5,5];% 5
    [100,30,10]; %6
    [100,30,20] %7
    };

for ittt = 1:7

settingTag = ittt;
[N,Mp,M] = ReadSettings(settingsCell{settingTag});

instancefld = sprintf('%d_%d_%d_instances',N,Mp,M);
Insfiles = dir([fldname,instancefld,'/*.mat']);

%%
Q = 4;
settings.Q = Q;

settings = WriteSettings(settings,settingsCell{settingTag});


settings.ita = 5;
settings.allcheatflg = 1;


Yo = [1,0.75,0.7,0.65,0.4,0.35];
settings.Y = Yo;

% PSets pool calculation
addpath('..\funcs')
PSetsPool = PoolGenbycircshift(M,Mp,-1);
TBposFull = TBposFullCal(PSetsPool);
%% running instances
% Ncases = length(Insfiles);
PSTAholder = zeros(Ncases,N);

F0 = zeros(1,Ncases); %conventional scinario
Fb = zeros(1,Ncases); % blind scinario
Fgen = zeros(1,Ncases); % general scheme scinario
Fopt = zeros(1,Ncases); % optimized scinario

FW0 = zeros(2,Ncases);
FWb = zeros(2,Ncases);
FWgen = zeros(2,Ncases);
FWopt = zeros(2,Ncases);

Nrep = 10; % multistage optimization, number of repetition, times of sampling from the pool
Nop = 30; % multistage optimization, number of iteration
settings.Nrep = Nrep;
settings.Nop = Nop;

%% starting optimization
hwait = waitbar(0,'please wait'); 
tic
for iter = 1:Ncases
    waitbar(iter/Ncases,hwait)
    
    % remove Y info
    settings = rmfield(settings,'Y');
    % read new instance
    ifilename = [Insfiles(iter).folder,'/',num2str(iter-1),'.mat'];
    load(ifilename,'instance');
    Yo = instance{1,4};
    TBp = instance{1,5}';
    TBin = TBinCalwithYP(Yo,TBp);
    
    settings.Y = Yo;
    F0(iter) = sum(TBin(:)); %conventional
    [worstLoss,EgM,~] = WorstLossCal(ones(N,N),Yo);
    FW0(1,iter) = worstLoss;
    FW0(2,iter) = max(EgM);
    
    
    PSTA = randsample(1:Mp,N,true);
    TBposBld= TBposInitFunc(PSTA, TBposFull);
    Fb(iter) = sum(TBposBld(:).*TBin(:)); % blind
    [worstLoss,EgM,~] = WorstLossCal(TBposBld,Yo);
    FWb(1,iter) = worstLoss;
    FWb(2,iter) = max(EgM);
    
    
    PSTA0 = GenSchemeV2(settings); % adaptive GEN; dividing range(Y)
    TBposGE= TBposInitFunc(PSTA0, TBposFull);
    Fgen(iter) = sum(TBposGE(:).*TBin(:)); % general
    [worstLoss,EgM,~] = WorstLossCal(TBposGE,Yo);
    FWgen(1,iter) = worstLoss;
    FWgen(2,iter) = max(EgM);
    
    
    % opt_g
    PSTA = PSTA0;
    tLoss = 1000;
    tPSTA = PSTA0;
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
        PSTA = randsample(1:Mp,N,true);
    end
    TBposOPT= TBposInitFunc(tPSTA, TBposFull);
    Fopt(iter) = sum(TBposOPT(:).*TBin(:)); % optimized
    [worstLoss,EgM,~] = WorstLossCal(TBposOPT,Yo);
    FWopt(1,iter) = worstLoss;
    FWopt(2,iter) = max(EgM);
    PSTAholder(iter,:) = tPSTA;
end
toc
close(hwait)

%% result save
Results.F0 = F0;
Results.Fb = Fb;
Results.Fgen = Fgen;
Results.Fopt = Fopt;

Results.PSTAopt = [zeros(1,N);PSTAholder];

Results.FW0 = FW0;
Results.FWb = FWb;
Results.FWgen = FWgen;
Results.FWopt = FWopt;

QSA = Results.PSTAopt;
G_tot = Results.Fopt;
G_W =  Results.FWopt(1,:);
G_MI = Results.FWopt(2,:);

outputfld = [fldname,instancefld];
ifilename =  sprintf('N%d_Mp%d_M%d_alg2.mat',N,Mp,M);
save([outputfld,'/',ifilename],'QSA','G_tot','G_W','G_MI','PSetsPool','settings');

end

%%
function [N,Mp,M] = ReadSettings(isettingCell)
% isettingsCell = [N,Mp,M];
N = isettingCell(1);
Mp = isettingCell(2);
M = isettingCell(3);
if Mp<M
    disp('error! Mp<M')
end
end

function settings = WriteSettings(settings,isettingCell)
% isettingsCell = [N,Mp,M];
settings.N = isettingCell(1);
settings.Mp = isettingCell(2);
settings.M = isettingCell(3);
end

function TBin = TBinCalwithYP(y,TBp)
N = length(y);
% inherent term table
TBin = zeros(N,N);
for i = 2:N
    for j = 1:(i-1)
        TBin(j,i) = (y(j) - y(i))*TBp(j,i);
    end
end

end













