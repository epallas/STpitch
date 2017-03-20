function [ceps] = cepsLog2 (y, NsamplesFft)
    
    y = [y; zeros(NsamplesFft-length(y) ,1)];
    Y = log10(abs(fft(y)));
    ceps = real(ifft(Y));
    %ceps = ceps(100:round(length(ceps)/2));
end