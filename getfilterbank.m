%contructs mel filterbank
function filterbank=getfilterbank(bankno,fl,fh,Fs,nfft)
%mel domain
mh=1125*(log(1+fh/700)); 
ml=1125*(log(1+fl/700));
%partitions in mel
melint=ml:(mh-ml)/(bankno+1):mh;
%freq domain
freqint=700*(exp(melint/1125)-1);
%bin no. corresponding to freq partitions
binno=floor((nfft+1)*freqint/Fs);
filterbank=zeros(bankno,nfft/2+1);

%construct filter bank 
for i=2:1:size(filterbank,1)+1
    for j=0:1:size(filterbank,2)-1
        if j< binno(i-1)
            filterbank(i-1,j+1)=0;
        elseif j<=binno(i) && j>= binno(i-1)
            filterbank(i-1,j+1)=(j-binno(i-1))/(binno(i)-binno(i-1));
        elseif j>=binno(i) && j<= binno(i+1)
            filterbank(i-1,j+1)=(binno(i+1)-j)/(binno(i+1)-binno(i));
        elseif j > binno(i+1)
            filterbank(i-1,j+1)=0;
        end
    end
end
end
