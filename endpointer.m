
% Takes audio filelocation as input and segments speech based on energy
function [data,label]=endpointer(filename,male)
%To detect if error occurs but dont stop the computing
try
    %preempahsis filter
    b= [1 -0.1]; 
    a=1;
    %read the file
    [y,Fs]=audioread(filename);
    % A unwanted signal was observed in some files for first few samples.
    % Remove that signal
    setzero=floor(100*Fs/1000);
    y(1:setzero)=0;
    %time of signal
    Time=size(y,1)/Fs;
    
    % figure;
    %plot(1/Fs*(1:1:size(y,1)),y);
    
    %parameters if audio from male
    if male==0
        %For female speakers
        Window=500; %in ms
        Winsample=Window*Fs/1000;
        stepsize=15; %in ms
        stepsample= stepsize*Fs/1000;
        energy= zeros(1,floor(size(y,1)/stepsample));
        energyindex=1:stepsample:size(y,1)-Winsample;
        thresold=1;
        jump=500/stepsample*Fs/1000;
        
    else
       %parameters if audio is from female
        Window=500; %in ms   window size
        Winsample=Window*Fs/1000; % samples in window
        stepsize=5; %in ms sliding window
        stepsample= stepsize*Fs/1000;
        energy= zeros(1,floor(size(y,1)/stepsample));
        energyindex=1:stepsample:size(y,1)-Winsample;
        thresold=0.3;
        jump=500/stepsample*Fs/1000;
    end
    
    %compute energy in moving window
    for i=energyindex
        temp= sum(y(i:i+Winsample).*y(i:i+Winsample));
        if temp>thresold
            energy(1,ceil(i/stepsample))=temp;
        end
    end
    %figure
    %plot(stepsample/Fs*(1:1:size(energy,2)),energy);
   
    [localmax,maxind]=findpeaks(energy); % find local maximas
    nextind=maxind(1); 
    i=1;
    j=1;
    utterind=zeros(1,20);
    
    % Obtain the start point of the utterance based on maximas such that a whole utterance
    % is included
    while(true)
        currind=nextind;
        try
            [~,temp]=max(energy(1,currind:currind+jump)); %maxima in a window
        catch
            [~,temp]=max(energy(1,currind:end));
        end
        temp=currind+temp-1;
        currind=temp;
        utterind(j)=energyindex(temp);
        j=j+1;
        while(currind + jump >= maxind(i))
            i=i+1;
            if i>size(maxind,2)
                break
            end
        end
        if i>size(maxind,2)
            break
        end
        nextind=maxind(i);
    end
    
    % to indicate segmenting boundaries
    temp=zeros(size(y,1),1);
    temp(utterind)= 0.3;
    temp(utterind++Winsample-1)=0.3;
    %figure
    %plot(1/Fs*(1:1:size(y,1)),y,1/Fs*(1:1:size(y,1)),temp);
    data=zeros(20,Winsample);
    label=zeros(20,1);
    
    %segmenting speech
    for i=1:1:20
        data(i,:)=filter(b,a,y(utterind(i):utterind(i)+Winsample-1));
        label(i)=floor(i/2-0.1);
        
    end
catch
    data=Fs;
    label=Time;
    %figure
    %findpeaks(energy);
    
end
end




