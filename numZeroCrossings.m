function [numZC] = numZeroCrossings (x)

    aux = x(1:end-1).*x(2:end);
    
    numZC = length(find(aux<0));
    
end