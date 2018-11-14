% Estimates the label given input and codebook
function est_label=predict(test_data,clusters,mel_vector_length,codebook)
est_label=zeros(size(test_data,1),1);
     for j=1:1:size(test_data,1)
         min_dist=zeros(1,10);
         for z=1:clusters:size(codebook,1)
             dist=0;
            for k=1:mel_vector_length:size(test_data,2)
                %distance of frame from nearest cluster
                disttemp=repmat(test_data(j,k:k+mel_vector_length-1),[clusters,1])-codebook(z:z+clusters-1,:);
                %sum over all frames
                dist=dist+min(sum(disttemp.^2,2));
            end   
            %assign min distance as label
            min_dist(ceil(z/clusters))= dist;
         end
         [~,est_label(j)]=min(min_dist);
         est_label(j)=est_label(j)-1;
     end
end