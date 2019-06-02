function I = mutual_info_luo(frame_number,Cx,prob_x)
m=1;
for k=1:frame_number  %go through each frame
    sum=0;
    for i=1:size(Cx,1)  %go through the row and column of the n*n C(r,s) matrices
        for j=1:size(Cx,2)
            if Cx(i,j,k)>0  %if C or prob is equal to 0 the resulting value would be infinite and the zeros will therefore be excluded
                sum=sum+Cx(i,j,k)*log(Cx(i,j,k));  %the equation given in Luo to get the joint entropy value
            end
        end
    end
    I(k)=-sum;
end