%Takes the whole data and performs N-fold CV eval by leaving one speaker
%out
function [accuracy,trainacc]=CVeval(data,label,clusters,mel_vector_length,speakers)

accuracy=zeros(speakers,1);
trainacc=zeros(speakers,1);
sp=1;
tarrr= zeros(0);
outss=tarrr;
for i =1:1:speakers
    %separate test data and training data by leaving one speaker out
    test_data=data(40*(i-1)+1:40*i,:);
    training_data=[data(1:40*(i-1),:) ; data(40*i+1:end,:)];
    test_label=label(40*(i-1)+1:40*i,:);
    train_label=[label(1:40*(i-1),:) ; label(40*i+1:end,:)];
    %get codebook
    codebook=getcodebook( training_data,train_label,mel_vector_length,clusters);
    
    %Training accuracy
    est_label=predict(training_data,clusters,mel_vector_length,codebook);
    trainacc(sp)=size(find(est_label-train_label==0),1)/size(est_label,1);
    %Testing accuracy
    est_label=predict(test_data,clusters,mel_vector_length,codebook);
    accuracy(sp)=size(find(est_label-test_label==0),1)/size(est_label,1);
    sp=sp+1;
    
    %for confusion matrix
    tar=transpose(test_label+1);
    targets = zeros(10,size(tar,2));
    outputs = zeros(10,size(tar,2));
    targetsIdx = sub2ind(size(targets), tar, 1:size(tar,2));
    outputsIdx = sub2ind(size(outputs), transpose(est_label+1),1:size(tar,2));
    targets(targetsIdx) = 1;
    outputs(outputsIdx) = 1;
    tarrr=[tarrr targets];
    outss=[outss outputs];
    
    
end
plotconfusion(tarrr,outss);
end