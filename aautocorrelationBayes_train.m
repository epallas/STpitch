win = 32/1000; % Size in s
shift = 10/1000; % window movement per frame

labelsTotalFolder_train = [];
f0refTotalFolder_train = [];
myLabelsTotalFolder_train = [];
F0TotalFolder_train = [];

xcorPeakPosTotalFolder_aacorr = [];
xcorNumPeaks_aacorr = [];
xcorrVal13Peaks_aacorr = [];
NsamplesFft = 4000;

h = waitbar(0,'Please wait...');
count = 0;
Nfiles = 300;

for j=1:Nfiles
    s = getRandomTrainingFileName();
    %% Read File and Labels
    [y,Fs] = audioread([s '.wav']);
    f0ref  = readf0ref([s '.f0ref']);
    t = 1/Fs:1/Fs:length(y)/Fs;
    ytest = y;

    labelsJ = f0ref;
    labelsJ(labelsJ>0) = 1;
    
    myLabels = zeros(length(labelsJ),1);
    F0       = zeros(length(labelsJ),1);
    
    %% Sliding window of 32ms, shift 10ms


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
    xcorrVal13Peaks = zeros(numOfFrames-1,1);
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
            if xcorNumpeaks(i+1) < 76 xcorNumpeaks(i+1) > 3
                myLabels(i+1) = 1;
                F0(i+1) = 1/abs(tpeak2-tpeak1);
            end
            
            peaksMat(indexPeak2,:) = [];

            [peak3, indexPeak3] = max(peaksMat(:,1));
            locPeak3 = peaksMat(indexPeak3,2);
            tpeak3 = locPeak3/Fs;
            peaksMat(indexPeak3,:) = [];
            xcorrVal13Peaks(i+1) = peak3/peak1;
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
    labelsJ  = labelsJ; %  (1:numOfFrames-3);
    myLabels = myLabels (1:length(labelsJ));
    F0       = F0       (1:length(labelsJ));
    f0ref    = f0ref    (1:length(labelsJ));
    xcorPeakPos = xcorPeakPos (1:length(labelsJ));
    xcorNumpeaks = xcorNumpeaks (1:length(labelsJ));
    xcorrVal13Peaks = xcorrVal13Peaks (1:length(labelsJ));
    
    
    labelsTotalFolder_train = [labelsTotalFolder_train; labelsJ];
    myLabelsTotalFolder_train = [myLabelsTotalFolder_train; myLabels];
    xcorPeakPosTotalFolder_aacorr = [xcorPeakPosTotalFolder_aacorr; xcorPeakPos];
    xcorNumPeaks_aacorr = [xcorNumPeaks_aacorr; xcorNumpeaks];
    xcorrVal13Peaks_aacorr = [xcorrVal13Peaks_aacorr; xcorrVal13Peaks];
    F0TotalFolder_train = [F0TotalFolder_train; F0];
    f0refTotalFolder_train = [f0refTotalFolder_train; f0ref];
    
    count = count + 1;
    waitbar(count/Nfiles,h);
end
close(h)
gscatter(xcorrVal13Peaks_aacorr,xcorNumPeaks_aacorr,labelsTotalFolder_train,'bg','..')

[C,p] = voicingPresision (myLabelsTotalFolder_train, labelsTotalFolder_train)

figure
plot(f0refTotalFolder_train)
hold on
plot(F0TotalFolder_train,'r')
hold off



figure
hist(xcorNumPeaks_aacorr(find(labelsTotalFolder_train==1)))

