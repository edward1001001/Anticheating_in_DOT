function ASC = ASC_Cal(RefOrder,Order,p1)
ASC = 0;
for itag = 1:length(Order)
    RefPortion = RefOrder(1:itag);
    if sum(RefPortion == Order(itag))
        ASC = ASC+1;
    else
        ASC = ASC+p1;
    end
end
ASC = ASC/length(Order);
end