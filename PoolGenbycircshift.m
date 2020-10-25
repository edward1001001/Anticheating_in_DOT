function PCSs = PoolGenbycircshift(M,Mp,stp)
%% PCSs = Mp by M
if nargin<3
    stp = 1;
end

iPCS = 1:Mp;
PCSs = zeros(Mp,M);
for itag = 1:Mp
     PCSs(itag,:) = iPCS(1:M);
     iPCS = circshift(iPCS,stp);
end
end