function [f0ref] = readf0ref(filename) 
    % Read f0ref given its filename.
    fileID = fopen(filename,'r');
    f0ref = fscanf(fileID,'%f');
end