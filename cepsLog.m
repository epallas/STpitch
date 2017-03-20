function [ceps] = cepsLog (y, NsamplesFft)
    
    y = [y; zeros(NsamplesFft-length(y) ,1)];
    Y = log10(abs(fft(y)));
    ceps = abs(ifft(Y));
    %ceps = ceps(100:round(length(ceps)/2));
end