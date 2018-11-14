% Function takes input the number of filerbanks, speech signal and Sampling Frequrency and gives out the MFCC vectors.
function mel_co=mfcc(data,bankno,Fs,N)

framesize=10;
framestep=5;
framesizesample=framesize*Fs/1000; % no of samples for framesize
framestepsample=framestep*Fs/1000;  % no of samples for framestep

fl=100; % lowest Freq
fh=Fs/2; % Highest Freq
hamm=hamming(framesizesample); %hamming window
hamm=repmat(transpose(hamm),size(data,1),1); %extending for all data
pad=zeros(size(data,1), (512 - framesizesample)/2); % zeropadding
melcoeffs=zeros(size(data,1),bankno/2*(size(data,2)- framesizesample)/framestepsample);
if N==1 || N==2
    mel_delta=melcoeffs;
    del_delta=[melcoeffs melcoeffs melcoeffs ];
end
for i=1:framestepsample:size(data,2)- framesizesample
    frame=hamm.*data(:,i:i+framesizesample-1); %hamming window
    frame=[pad frame pad]; % zeropadding
    framedft=fft(frame,size(frame,2),2); %fft
    framedft=framedft(:,1:floor(size(frame,2)/2) +1); %rejecting values corresponding to negative frequencies
    framepower=1/size(frame,2)*abs(framedft).^2; %power
    %get filterbank only one time
    if i==1
        filterbank=getfilterbank(bankno,fl,fh,Fs,size(frame,2));
    end
    energybank= log(framepower*transpose(filterbank)); % Energy bank obtained
    melcoeff=dct(energybank,size(energybank,2),2); %discrete cosine transform
    % keep only 1-13 coeffs of DCT
    melcoeffs(:,(bankno/2*(ceil(i/framestepsample-1))+1:bankno/2*(ceil(i/framestepsample))))=melcoeff(:,1:size(melcoeff,2)/2 );
end

if N==1
    %compute delta coeffs
    for i=1:1:size(melcoeffs,2)*2/bankno -1
        if i==1
            temp=melcoeffs(:,bankno/2*i+1:bankno/2*(i+1))/2;
            
        elseif i==size(melcoeffs,2)*2/bankno -1
            temp=-1*melcoeffs(:,bankno/2*(i-2)+1:bankno/2*(i-1))/2;
        else
            temp=melcoeffs(:,bankno/2*(i)+1:bankno/2*(i+1)) - melcoeffs(:,bankno/2*(i-2)+1:bankno/2*(i-1)) ;
            temp=temp/2;
        end
        mel_delta(:,bankno/2*(i-1)+1:bankno/2*i)= temp;
    end
    
    %compute delta delta coeffs and create the matrix containing all three of
    %t
    for i=1:1:size(mel_delta,2)*2/bankno -1
        if i==1
            temp=mel_delta(:,bankno/2*i+1:bankno/2*(i+1))/2;
            
        elseif i==size(mel_delta,2)*2/bankno -1
            temp=-1*mel_delta(:,bankno/2*(i-2)+1:bankno/2*(i-1))/2;
        else
            temp=mel_delta(:,bankno/2*(i)+1:bankno/2*(i+1)) -mel_delta(:,bankno/2*(i-2)+1:bankno/2*(i-1)) ;
            temp=temp/2;
        end
        del_delta(:,3/2*bankno*(i-1)+1:3/2*bankno*i)=[ melcoeffs(:,bankno/2*(i-1)+1:bankno/2*i) mel_delta(:,bankno/2*(i-1)+1:bankno/2*i) temp];
    end
    mel_co=del_delta;
    
elseif N==2
    %compute delta coeffs
    for i=1:1:size(melcoeffs,2)*2/bankno -1
        if i==1
            temp=melcoeffs(:,bankno/2*i+1:bankno/2*(i+1)) + melcoeffs(:,bankno/2*(i+1)+1:bankno/2*(i+2)) ;
            temp=temp/4;
        elseif i==2
            temp=melcoeffs(:,bankno/2*i+1:bankno/2*(i+1)) + melcoeffs(:,bankno/2*(i+1)+1:bankno/2*(i+2))- melcoeffs(:,bankno/2*(i-2)+1:bankno/2*(i-1)) ;
            temp=temp/4;
        elseif i==size(melcoeffs,2)*2/bankno -1
            temp=melcoeffs(:,bankno/2*(i-2)+1:bankno/2*(i-1)) +melcoeffs(:,bankno/2*(i-3)+1:bankno/2*(i-2)) ;
            temp=-1*temp/4;
        elseif  i==size(melcoeffs,2)*2/bankno -2
            temp=melcoeffs(:,bankno/2*(i-2)+1:bankno/2*(i-1)) +melcoeffs(:,bankno/2*(i-3)+1:bankno/2*(i-2)) - melcoeffs(:,bankno/2*(i)+1:bankno/2*(i+1)) ;
            temp=-1*temp/4;
        else
            temp=melcoeffs(:,bankno/2*(i)+1:bankno/2*(i+1)) + melcoeffs(:,bankno/2*(i+1)+1:bankno/2*(i+2)) - melcoeffs(:,bankno/2*(i-2)+1:bankno/2*(i-1)) - melcoeffs(:,bankno/2*(i-3)+1:bankno/2*(i-2));
            temp=temp/4;
        end
        mel_delta(:,bankno/2*(i-1)+1:bankno/2*i)= temp;
    end
    
    %compute delta delta coeffs and create the matrix containing all three of
    %t
    for i=1:1:size(mel_delta,2)*2/bankno -1
        if i==1
            temp=mel_delta(:,bankno/2*i+1:bankno/2*(i+1)) + mel_delta(:,bankno/2*(i+1)+1:bankno/2*(i+2)) ;
            temp=temp/4;
        elseif i==2
            temp=mel_delta(:,bankno/2*i+1:bankno/2*(i+1)) + mel_delta(:,bankno/2*(i+1)+1:bankno/2*(i+2))- mel_delta(:,bankno/2*(i-2)+1:bankno/2*(i-1)) ;
            temp=temp/4;
        elseif i==size(mel_delta,2)*2/bankno -1
            temp=mel_delta(:,bankno/2*(i-2)+1:bankno/2*(i-1)) +mel_delta(:,bankno/2*(i-3)+1:bankno/2*(i-2)) ;
            temp=-1*temp/4;
        elseif  i==size(mel_delta,2)*2/bankno -2
            temp=mel_delta(:,bankno/2*(i-2)+1:bankno/2*(i-1)) +mel_delta(:,bankno/2*(i-3)+1:bankno/2*(i-2)) - mel_delta(:,bankno/2*(i)+1:bankno/2*(i+1)) ;
            temp=-1*temp/4;
        else
            temp=mel_delta(:,bankno/2*(i)+1:bankno/2*(i+1)) + mel_delta(:,bankno/2*(i+1)+1:bankno/2*(i+2)) - mel_delta(:,bankno/2*(i-2)+1:bankno/2*(i-1)) - mel_delta(:,bankno/2*(i-3)+1:bankno/2*(i-2));
            temp=temp/4;
        end
        del_delta(:,3/2*bankno*(i-1)+1:3/2*bankno*i)=[ melcoeffs(:,bankno/2*(i-1)+1:bankno/2*i) mel_delta(:,bankno/2*(i-1)+1:bankno/2*i) temp];
    end
     mel_co=del_delta;
else
    mel_co=melcoeffs;
end








end
