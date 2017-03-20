function [] = ceateF0refTXT (filename, F0)

    fileID = fopen(filename,'w');
    fprintf(fileID, '%f\n', F0); 
    fclose(fileID);

end