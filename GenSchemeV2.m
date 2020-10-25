function PSTA0 = GenSchemeV2(settings)
C = settings.Mp - settings.M + 1;
ymax= max(settings.Y);
ymin= min(settings.Y);
THs = linspace(ymin*0.9999, ymax*1.0001, C+1);

PSTA0 = ClassAssign(THs,settings.Y);
end

function Classlbl = ClassAssign(THs,Y)
Classlbl = zeros(1,length(Y));
Nlbl = length(THs)-1;
idxL = Y<=THs(1);
for itag = 1:Nlbl
    idxU = ~idxL;
    idxL = Y<=THs(itag+1);
    Classlbl(idxU&idxL) = itag;
end
idxU = ~idxL;
Classlbl(idxU) = Nlbl;
% reverse Classlbl to make the highest yi marked as class 1
Classlbl = Nlbl-Classlbl+1;
end
