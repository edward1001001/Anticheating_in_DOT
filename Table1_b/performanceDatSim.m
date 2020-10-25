clear
clc

rng(100);

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

% 
% PSH = zeros(settings.N,settings.N);
% tLoss = 1000;

% input student ability
Yo = [1,0.75,0.7,0.65,0.4,0.35];
settings.Y = Yo;

% number of instances
Ncases = 500;
%%
addpath('..\funcs')
% PSets pool calculation
savingfoldername = '.\SimResults';
mkdir(savingfoldername)

PSetsPool = PoolGenbycircshift(M,Mp,-1);
TBposFull = TBposFullCal(PSetsPool);

F0 = zeros(1,Ncases); %conventional scinario
Fb = zeros(1,Ncases); % blind scinario
Fgen = zeros(1,Ncases); % general scheme scinario
Fopt = zeros(1,Ncases); % optimized scinario
Foptw = zeros(1,Ncases);
FoptMI = zeros(1,Ncases);

FW0 = zeros(2,Ncases);
FWb = zeros(2,Ncases);
FWgen = zeros(2,Ncases);
FWopt = zeros(2,Ncases);
FWoptw = zeros(2,Ncases);
FWoptMI = zeros(2,Ncases);

Nrep = 10; % multistage optimization, number of repetition, times of sampling from the pool
Nop = 30; % multistage optimization, number of iteration
settings.Nrep = Nrep;
settings.Nop = Nop;

hwait = waitbar(0,'please wait'); 
tic
for iter = 1:Ncases  % changing TBinGen, to estimate mean, std, etc.
    waitbar(iter/Ncases,hwait)
    
    settings = rmfield(settings,'Y');
    [TBin,Yo] = TBinGen(settings);
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
    
    
    PSTA0 = GenSchemeV2(settings);
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
    
    for irep = 1:2*Nrep
        PSTA = randsample(1:Mp,N,true);
    end
%     % opt_gW
%     PSTA = PSTA0;
%     tLoss = 1000;
%     tPSTA = PSTA0;
%     for irep = 1:Nrep
%         for itag = 1:Nop
%             [FlossR, nPSTA] = PosOptimization_gW(Yo,PSTA,TBposFull);
%             if sum(abs(nPSTA(:)-PSTA(:)))==0
%                 PSTA = nPSTA;
%                 break;
%             else
%                 PSTA = nPSTA;
%             end
%         end
%         if tLoss>FlossR(end)
%             tLoss = FlossR(end);
%             tPSTA = PSTA;
%         end
%         PSTA = randsample(1:Mp,N,true);
%     end
%     TBposOPTW= TBposInitFunc(tPSTA, TBposFull);
%     Foptw(iter) = sum(TBposOPTW(:).*TBin(:)); % optimized
%     [worstLoss,EgM,~] = WorstLossCal(TBposOPTW,Yo);
%     FWoptw(1,iter) = worstLoss;
%     FWoptw(2,iter) = max(EgM);
%     
% 
%     
%     % opt_gMI
%     PSTA = PSTA0;
%     tLoss = 1000;
%     tPSTA = PSTA0;
%     for irep = 1:Nrep
%         for itag = 1:Nop
%             [FlossR, nPSTA] = PosOptimizationMIlimited(Yo,PSTA,TBposFull);
%             if sum(abs(nPSTA(:)-PSTA(:)))==0
%                 PSTA = nPSTA;
%                 break;
%             else
%                 PSTA = nPSTA;
%             end
%         end
%         if tLoss>FlossR(end)
%             tLoss = FlossR(end);
%             tPSTA = PSTA;
%         end
%         PSTA = randsample(1:Mp,N,true);
%     end
%     TBposOPTMI= TBposInitFunc(tPSTA, TBposFull);
%     FoptMI(iter) = sum(TBposOPTMI(:).*TBin(:)); % optimized
%     [worstLoss,EgM,~] = WorstLossCal(TBposOPTMI,Yo);
%     FWoptMI(1,iter) = worstLoss;
%     FWoptMI(2,iter) = max(EgM);

    Results.F0 = F0(iter);
    Results.Fb = Fb(iter);
    Results.Fgen = Fgen(iter);
    
    Results.PSTAopt = tPSTA;
    
    Results.FW0 = FW0(1:2,iter);
    Results.FWb = FWb(1:2,iter);
    Results.FWgen = FWgen(1:2,iter);
    Results.FWopt = FWopt(1:2,iter);
    
    timestp = datestr(now,'yyyymmdd_HH_MM_SS');
    savefileName = sprintf('SingleNcase_i%d_N%d_Mp%d_M%d_',iter,N,Mp,M);
    save([savingfoldername,'\',savefileName,timestp,'.mat'],'Results','settings','TBin');
end
toc
close(hwait)


%%
Results.F0 = F0;
Results.Fb = Fb;
Results.Fgen = Fgen;
Results.Fopt = Fopt;
Results.Foptw = Foptw;
Results.FoptMI = FoptMI;

Results.FW0 = FW0;
Results.FWb = FWb;
Results.FWgen = FWgen;
Results.FWopt = FWopt;
Results.FWoptw = FWoptw;
Results.FWoptMI = FWoptMI;
%%
timestp = datestr(now,'yyyymmdd_HH_MM_SS');
% save(['Rng100_trancatedY_Ncase500_',timestp,'.mat'],'F0','Fb','Fgen','Fopt','Foptw','FW0','FWb','FWgen','FWopt','FWoptw','settings');
save(['Rng100_trancatedY_Ncase',num2str(Ncases),'_',timestp,'.mat'],'Results','settings');





