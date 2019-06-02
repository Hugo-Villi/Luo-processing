function proba_r_s_global=compute_C_luo_mod(n,displacement,discretization,labels,length_subsequence)
matrix_r_s_global=zeros(n-1,n-1,size(displacement,1));   %declare the matrix
for k=length_subsequence:(size(displacement,1)-length_subsequence)
    sum_test=0;
    for j=(k-length_subsequence+1):k
        for i=1:max(size(labels,1),size(labels,2))
            r=find(histcounts(displacement(j,i),discretization)==1);    %get the position in the histogram at the frame f
            s=find(histcounts(displacement(j+length_subsequence,i),discretization)==1);  %get the position in the histogram at the frame f+1
            matrix_r_s_global(r,s,k)=matrix_r_s_global(r,s,k)+1;    %same but for the global matrix
        end
    end
end
proba_r_s_global=matrix_r_s_global/(size(labels,1)*length_subsequence);   %compute the global proba
end