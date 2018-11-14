% Make sure that audio folders are in current working directory
%mydir1- male
%mydir2-female
currdir=pwd;
mydir1=strcat(currdir,"\Digits male 8Khz complete_data\");
files1=dir(mydir1);
files1=files1(3:end); % all the files for male data
mydir2=strcat(currdir,"\Digits female 8Khz complete_data\");
files2=dir(mydir2);
files2=files2(3:end); %all the files for female data


Window=500; %in ms
Fs=8000;
Winsample=Window*Fs/1000;
bankno=26;
clusters=64;
N=2; %set N=0,1 or 2( N of delta-delta coeffs)
%if male as training data set traingender =1
traingender=0;
speakers=(size(files1,1)+size(files2,1))/2;

data=zeros(20*size(files1,1)+20*size(files2,1),Winsample);
label=zeros(20*size(files1,1)+20*size(files2,1),1);
%speech segmentation from each audio file
for i=1:1:size(files1,1)
    [data(20*(i-1)+1:20*(i-1)+1+19,:),label(20*(i-1)+1:20*(i-1)+1+19)]=endpointer(strcat(mydir1,files1(i).name),1);
end
for i=size(files1,1)+1:1:size(files2,1)+size(files1,1)
    [data(20*(i-1)+1:20*(i-1)+1+19,:),label(20*(i-1)+1:20*(i-1)+1+19)]=endpointer(strcat(mydir2,files2(i-size(files1,1)).name),0);
end

melcoeffs=mfcc(data,bankno,Fs,N);%MFCC coeffs

if N==1 || N==2
    vec_size=bankno*3/2;
else
    vec_size=bankno/2;
end
%N-fold CV by leaving one pseaker out
%[accuracy,trainacc]=CVeval(melcoeffs,label,clusters,vec_size,speakers);

%for match mismatch conditions
[accuracy,trainacc]=twoCVeval(melcoeffs,label,clusters,vec_size,speakers,traingender);

%accuracy vector and train accuracy vectors 

