%obtains codebook by kmeans
function codebook=getcodebook(data,label,mel_vector_length,clusters)
arrange_arr=[data label];
% group data based on label
arrange_arr=sortrows(arrange_arr,size(arrange_arr,2));
train_arr=arrange_arr(:,1:end-1);
labeltr_arr=arrange_arr(:,end);
codebook=zeros(clusters*10,mel_vector_length);
for j=1:1:10
    temp=train_arr(find(labeltr_arr==j-1),:);
    % each frame in every sample as input point
    temp=transpose(reshape(reshape(temp',1,[]),mel_vector_length,[]));
    %kmeans
    [~, codebook(clusters*(j-1)+1:clusters*j,:)]=kmeans(temp,clusters);
end
end