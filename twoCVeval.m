function [accuracy,trainacc]=twoCVeval(data,label,clusters,mel_vector_length,~,traingender)


sp=1;
for i =1
    %separate test data and train data based on which gender audio has to
    %be trained
    test_data=data(1:40*17,:);
    training_data=data(40*17+1:end,:);
    test_label=label(1:40*17,:,:);
    train_label=label(40*17+1:end,:);
    %if male as training data set traingender =1
    if traingender==1
        temp1=test_data;
        temp2= test_label;
        test_data=training_data;
        test_label=train_label;
        training_data=temp1;
        train_label=temp2;
    end
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
    
    plotconfusion(targets,outputs)
    
end
end