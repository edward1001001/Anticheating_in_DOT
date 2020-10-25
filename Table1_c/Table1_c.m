clear
clc

caseInfo = {'Ncases500_N20_Mp30_M20\r\n';
            'Ncases500_N40_Mp60_M40\r\n';
            'Ncases500_N100_Mp60_M40\r\n';
            'Ncases500_N500_Mp60_M40\r\n'};

fileID = fopen('Table1_c.txt','w');
for itag = 1:4        
filenames = {
        'Ncases500_N20_Mp30_M20_20200705_12_50_15.mat';
        'Ncases500_N40_Mp60_M40_20200705_12_14_02.mat';
        'Ncases500_N100_Mp60_M40_20200705_12_19_43.mat';
        'Ncases500_N500_Mp60_M40_20200705_08_26_49.mat'
};
foldername = './';
subfolders = {
    '\20\';
    '\40\';
    '\100\';
    '\500\'
    };

load([foldername,subfolders{itag},filenames{itag}])
N = settings.N;

ResultMat = [Results.F0/N;
        Results.FW0./[N;1];
        Results.Fgen/N;
        Results.FWgen./[N;1]; % g_W, g_MI
        Results.Fopt/N;
        Results.FWopt./[N;1]]; % g_W, g_MI
meanMat = mean(ResultMat,2);
stdMat = std(ResultMat,0,2);

fprintf(fileID,caseInfo{itag});  
itemp = [meanMat(1),stdMat(1),meanMat(2),stdMat(2),meanMat(3),stdMat(3)]; % F0, FW0_W, FW0_MI
fprintf(fileID,'None & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
itemp = [meanMat(4),stdMat(4),meanMat(5),stdMat(5),meanMat(6),stdMat(6)]; % Fgen, FWgen_W, FWgen_MI
fprintf(fileID,' GAS & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
itemp = [meanMat(7),stdMat(7),meanMat(8),stdMat(8),meanMat(9),stdMat(9)]; % Fopt, FWopt_W, FWopt_MI
fprintf(fileID,'Opti & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
fprintf(fileID,'\r\n');
end
fclose(fileID);