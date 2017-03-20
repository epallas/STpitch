%% Read file 
filesAudio2 = dir('pitch\ST201701_pitch\data\fda_ue\*.wav');
filesf0ref2 = dir('pitch\ST201701_pitch\data\fda_ue\*.f0ref');

labelsTotalFolder = [];
f0refTotalFolder = [];
myLabelsTotalFolder = [];
F0TotalFolder = [];

xcorPeakPosTotalFolder_aacorr = [];
xcorNumPeaks_aacorr = [];
xcorrAveragePeaksDistance_aacorr = [];
NsamplesFft = 4000;

h = waitbar(0,'Please wait...');
count = 0;

for j=1:length(filesAudio2)
    %% Read File and Labels
    [y,Fs] = audioread(strcat('pitch\ST201701_pitch\data\fda_ue\',filesAudio2(j).name));
    f0ref  = readf0ref(strcat('pitch\ST201701_pitch\data\fda_ue\',filesf0ref2(j).name));
    t = 1/Fs:1/Fs:length(y)/Fs;
    ytest = y;

    labelsJ = f0ref;
    labelsJ(labelsJ>0) = 1;
    
    myLabels = zeros(length(labelsJ),1);
    F0       = zeros(length(labelsJ),1);
    
    %% Sliding window of 15ms, shift 15ms

    win = 15/1000; % Size in s
    shift = 15/1000; % window movement per frame
    numOfShift = ceil(length(ytest)/(shift*Fs));
    numOfFrames = numOfShift - floor(win/shift);
    winSamples = zeros(Fs*win,1);

    numOfSamples = ceil(numOfFrames*shift*Fs + win*Fs - shift*Fs);

    ytest = [ytest; zeros(numOfSamples-length(ytest),1)];
    t = 1/Fs:1/Fs:length(ytest)/Fs;

    plottingAux = zeros(numOfFrames, length(winSamples));
    
    
    %% Start Sliding Window Through Signal
    xcorPeakPos   = zeros(numOfFrames-1,1);
    xcorNumpeaks = zeros(numOfFrames-1,1);
    xcorrAveragePeaksDistance = zeros(numOfFrames-1,1);
%     h1 = waitbar(0,'Please wait...');
%     pos_w1=get(h,'position');
%     pos_w2=[pos_w1(1) pos_w1(2)+pos_w1(4) pos_w1(3) pos_w1(4)];
%     set(h1,'position',pos_w2,'doublebuffer','on');
    
    count2 = 0;
    for i = 0:numOfFrames-2   % Do not compute last frame
        index1 = round(i*shift*Fs+1);
        index2 = round(i*shift*Fs+1+win*Fs);
        winSamples = ytest(index1:index2);

        xc = xcorr(winSamples);
        [fp, ifp] = findpeaks(xc);
        xcorNumpeaks(i+1) = length(fp);
        peaksMat = [fp ifp];
           
        [peak1, indexPeak1] = max(peaksMat(:,1));
        locPeak1 = peaksMat(indexPeak1,2);
        tpeak1 = locPeak1/Fs;
        peaksMat(1:indexPeak1,:) = [];
         
        if length(fp(indexPeak1:end)) >= 3
       
            [peak2, indexPeak2] = max(peaksMat(:,1));
            locPeak2 = peaksMat(indexPeak2,2);
            tpeak2 = locPeak2/Fs;
            if xcorNumpeaks(i+1) < 43
                myLabels(i+1) = 1;
                F0(i+1) = 1/abs(tpeak2-tpeak1);
            end
            
            peaksMat(indexPeak2,:) = [];

            [peak3, indexPeak3] = max(peaksMat(:,1));
            locPeak3 = peaksMat(indexPeak3,2);
            tpeak3 = locPeak3/Fs;
            peaksMat(indexPeak3,:) = [];
            
            xcorPeakPos(i+1) = abs(tpeak2-tpeak1);
        else
            xcorPeakPos(i+1) = 0;
        end
        count2 = count2 + 1;
        %waitbar(count2 / numOfFrames, h1);
    end 
    %close(h1)
    %xcorPeak12 = xcorPeak12(1:length(labelsJ));
    %xcorNumpeaks = xcorNumpeaks(1:length(labelsJ));
    labelsJ  = labelsJ  (1:length(xcorNumpeaks));
    myLabels = myLabels (1:length(xcorNumpeaks));
    F0       = F0       (1:length(xcorNumpeaks));
    f0ref    = f0ref    (1:length(xcorNumpeaks));
    
    labelsTotalFolder = [labelsTotalFolder; labelsJ];
    myLabelsTotalFolder = [myLabelsTotalFolder; myLabels];
    xcorPeakPosTotalFolder_aacorr = [xcorPeakPosTotalFolder_aacorr; xcorPeakPos];
    xcorNumPeaks_aacorr = [xcorNumPeaks_aacorr; xcorNumpeaks];
    xcorrAveragePeaksDistance_aacorr = [xcorrAveragePeaksDistance_aacorr; xcorrAveragePeaksDistance];
    F0TotalFolder = [F0TotalFolder; F0];
    f0refTotalFolder = [f0refTotalFolder; f0ref];
    
    count = count + 1;
    waitbar(count/length(filesAudio2),h)
end
close(h)
% gscatter(xcorPeakPosTotalFolder_aacorr,xcorNumPeaks_aacorr,labelsTotalFolder,'bg','..')

[C,p] = voicingPresision (myLabelsTotalFolder, labelsTotalFolder)

% figure
% plot(f0refTotalFolder)
% hold on
% plot(F0TotalFolder,'r')
% hold off