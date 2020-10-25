function [TBin,y] = TBinGen(settings)
% number of students
N = settings.N;
% # of choices in each MCQ
Q = settings.Q;

ita = settings.ita;
allcheatflg = settings.allcheatflg;

% student performances
if isfield(settings,'Y')
    y = settings.Y;
else
mu = (1/Q+1)/2;
sigma = (1-1/Q)/6;
y = sort(randn(1,N)*sigma + mu);
y = y(end:-1:1);
y(y>1) = 1;
y(y<(1/Q*1.001)) = 1/Q*1.001;
y = deRepetition4Y(y');
end

% active cheating table

% version 1, with small part yi in denominator
% ytot = sum(y);
% TBp = zeros(N,N);
% TBp(1,1) = 1;
% for i = 2:N
%     denominator = ytot - i*y(i);
%     for j = 1:(i-1)
%         TBp(j,i) =  (y(j)-y(i))/denominator;
%     end
%     TBp(i,i) = sum(y(i+1:end))/denominator;
% end

% version 2
TBp = zeros(N,N);
TBp(1,1) = 1;
ytot = sum(y);
% ita = 5; %ita>1, will increase the cheating probability; 0<ita<1 will reduce the cheating probability
% allcheatflg = 1;
for i = 2:N
    if allcheatflg
       TBp(i,i) = 0;
    else
       TBp(i,i) = (sum(y(i+1:end))/ytot)^ita;
    end
    denominator = sum(y(1:i)) - i*y(i);
    for j = 1:(i-1)
        TBp(j,i) =  (y(j)-y(i))/denominator*(1-TBp(i,i));
    end
end


% inherent term table
TBin = zeros(N,N);
for i = 2:N
    for j = 1:(i-1)
        TBin(j,i) = (y(j) - y(i))*TBp(j,i);
    end
end

end