function Y = deRepetition4Y(Y)
Yshape = size(Y);
Y = Y(:);
N = length(Y);
for itag = 1:(N-1)
    Nrep = sum(Y==Y(itag));
    if Nrep > 1
        coefM = 0.99999.^((1:Nrep)-1);
        Y(Y==Y(itag)) = Y(Y==Y(itag)).*coefM(:);
    end  
end
Y = reshape(Y,Yshape);
end