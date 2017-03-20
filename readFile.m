 
files = dir('ptdb_tug_male\data\ptdb_tug\MALE\MIC\M01\*.wav');
% i = input('Enter the index of sequence you want to analyse: ' )
i=4;
[y,Fs] = audioread(strcat('ptdb_tug_male\data\ptdb_tug\MALE\MIC\M01\',files(i).name));

figure
subplot(2,1,1)       % add first plot in 2 x 1 grid
t = [1/Fs:1/Fs:length(y)/Fs];
plot(t,y)
title('Time domain')

subplot(2,1,2)       % add second plot in 2 x 1 grid
th = 0.01;
[yClip] = centerClip(y, th);
plot(t,yClip)
title('Center Clipping')




