% load('Rng100_trancatedY_Ncase500_20200504_01_08_32')
N = 85;
load('Rng100_trancatedY_Ncase500_20201024_19_55_40.mat')
ResultMat = [Results.F0/N;
    Results.FW0./[N;1];
    Results.Fgen/N;
    Results.FWgen./[N;1];
    Results.Fopt/N;
    Results.FWopt./[N;1]];
meanMat = mean(ResultMat,2);
stdMat = std(ResultMat,0,2);

fileID = fopen('Table1_b.txt','w');
itemp = [meanMat(1),stdMat(1),meanMat(2),stdMat(2),meanMat(3),stdMat(3)]; % F0 (g, gw, gMI)
fprintf(fileID,'None & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
itemp = [meanMat(4),stdMat(4),meanMat(5),stdMat(5),meanMat(6),stdMat(6)]; % Fgen
fprintf(fileID,' GAS & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
itemp = [meanMat(7),stdMat(7),meanMat(8),stdMat(8),meanMat(9),stdMat(9)]; % Fopt
fprintf(fileID,'Opti & %.5f (%.5f) & %.5f (%.5f) & %.5f (%.5f)\r\n',itemp);
fprintf(fileID,'\r\n');
fclose(fileID);