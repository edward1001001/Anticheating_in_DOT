function [worstLoss,EgM,EzM] = WorstLossCal(TBpos,Yo)
N = length(Yo);
EgMp = zeros(1,N);
EzMp = zeros(2,N);
for itag = 1:N
%     if itag == 1
%         EgMp(itag) = 0;
%     else
        z_i = TBpos(:,itag);
        idifY = Yo - Yo(itag);
        idifY(idifY<0) = 0;
        iEgM = z_i(:).*idifY(:); 
        [EgMp(itag),idx] = max(iEgM);
        EzMp(1,itag) = z_i(idx); % how many questions can be copied
        EzMp(2,itag) = idx; % from whom to copy
%     end
end
worstLoss = sum(EgMp);
if nargout>2
    EzM = EzMp;
    EgM = EgMp;
elseif nargout>1
    EgM = EgMp;
end
end