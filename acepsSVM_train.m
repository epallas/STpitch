win = 32/1000; % Size in s
shift = 10/1000; % window movement per frame

labelsTotalFolder_train = [];
f0refTotalFolder_train = [];
myLabelsTotalFolder_ceps_train = [];
F0TotalFolder_train = [];

cepsValPeak18TotalFolder_cepsDemo = [];
cepsNumPeaks_cepsDemo = [];
cepsTPeak_cepsDemo = [];
cepsMaxPosition_cepsDemo = [];
NsamplesFft = 1e4;

h = waitbar(0,'Please wait...');
count = 0;
Nfiles = 50;

for j=1:Nfiles
     s = getRandomTrainingFileName();
    %% Read File and Labels
    [y,Fs] = audioread([s '.wav']);
    f0ref  = readf0ref([s '.f0ref']);

    t = 1/Fs:1/Fs:length(y)/Fs;
    ytest = y;

    labelsJ = f0ref;
    labelsJ(labelsJ>0) = 1;
    myLabels_ceps = zeros(length(labelsJ),1);
    F0 = zeros(length(labelsJ),1);
    %% Sliding window of 15ms, shift 15ms

    numOfShift = ceil(length(ytest)/(shift*Fs));
    numOfFrames = numOfShift - floor(win/shift);
    winSamples = zeros(Fs*win,1);

    numOfSamples = ceil(numOfFrames*shift*Fs + win*Fs - shift*Fs);

    ytest = [ytest; zeros(numOfSamples-length(ytest),1)];
    t = 1/Fs:1/Fs:length(ytest)/Fs;

    plottingAux = zeros(numOfFrames, length(winSamples));
    F0 = zeros(numOfFrames-1,1);
    
    %% Start Sliding Window Through Signal
    cepsValPeak18   = zeros(numOfFrames-1,1);
    cepsNumpeaks = zeros(numOfFrames-1,1);
    cepsTPeak = zeros(numOfFrames-1,1);
    cepsMaxPosition = zeros(numOfFrames-1,1);
   
%     h1 = waitbar(0,'Please wait...');
%     pos_w1=get(h,'position');
%     pos_w2=[pos_w1(1) pos_w1(2)+pos_w1(4) pos_w1(3) pos_w1(4)];
%     set(h1,'position',pos_w2,'doublebuffer','on')
    count2 = 0;
    for i = 0:numOfFrames-2   % Do not compute last frame
        index1 = round(i*shift*Fs+1);
        index2 = round(i*shift*Fs+1+win*Fs);
        winSamples = ytest(index1:index2);

        V = cepsLog (winSamples, NsamplesFft);
        V = V(Fs/350:Fs/50);
        %V = cceps(winSamples);
        %V = V(20:end);
        NumPeaks = 15;
        highestPeaksValue = zeros(NumPeaks,1);
        [valueFP, indexFP] = findpeaks(V);
        cepsNumpeaks(i+1) = length(valueFP);
        
        for k=1:NumPeaks
            [maxValue, indexOfMax] = max(valueFP);
            if k==1
                cepsMaxPosition(i+1) = indexOfMax;
            end
            highestPeaksValue(k) = maxValue;
            valueFP(indexOfMax) = [];
            indexFP(indexOfMax) = [];
        end
        
        iMax = (Fs/350+cepsMaxPosition(i+1));          % Add 100 samples. We removed them previously in cepsLog
        
        cepsTPeak(i+1) = (iMax/Fs)*1000;
        
        cepsValPeak18(i+1) = abs(highestPeaksValue(NumPeaks)/highestPeaksValue(1));
        
%         myLabels_ceps(i+1) = svmclassify(svmStruct,[cepsTPeak(i+1) cepsValPeak18(i+1)]);
%         
%         if myLabels_ceps(i+1) == 1
%             cc = cceps(winSamples);
%             cc = cc(Fs/400:length(cc)/2);
%             [maxCC, indexOfCC] = max(cc);
%             F0(i+1) = 1/(indexOfCC/Fs);
%         end
        
        count2 = count2 + 1;
        %waitbar(count2 / numOfFrames, h1);
    end 
    %close(h1)
    %xcorPeak12 = xcorPeak12(1:length(labelsJ));
    %xcorNumpeaks = xcorNumpeaks(1:length(labelsJ));
    labelsJ       = labelsJ;
    myLabels_ceps = myLabels_ceps (1:length(labelsJ));
    F0            = F0            (1:length(labelsJ));
    f0ref         = f0ref         (1:length(labelsJ));
    cepsTPeak     = cepsTPeak     (1:length(labelsJ));
    cepsValPeak18 = cepsValPeak18 (1:length(labelsJ));
    
    labelsTotalFolder_train = [labelsTotalFolder_train; labelsJ];
    cepsValPeak18TotalFolder_cepsDemo = [cepsValPeak18TotalFolder_cepsDemo; cepsValPeak18];
    cepsNumPeaks_cepsDemo = [cepsNumPeaks_cepsDemo; cepsNumpeaks];
    cepsTPeak_cepsDemo = [cepsTPeak_cepsDemo; cepsTPeak];
    cepsMaxPosition_cepsDemo = [cepsMaxPosition_cepsDemo; cepsMaxPosition];
    myLabelsTotalFolder_ceps_train = [myLabelsTotalFolder_ceps_train; myLabels_ceps];
    F0TotalFolder_train = [F0TotalFolder_train; F0];
    f0refTotalFolder_train = [f0refTotalFolder_train; f0ref];
    
    count = count + 1;
    waitbar(count/Nfiles,h)
end
close(h)
% gscatter(cepsMaxPosition_cepsDemo,cepsValPeak18TotalFolder_cepsDemo,labelsTotalFolder,'bg','..')
gscatter(cepsTPeak_cepsDemo,cepsValPeak18TotalFolder_cepsDemo,labelsTotalFolder_train,'bg','..')
[C,p] = voicingPresision (myLabelsTotalFolder_ceps_train, labelsTotalFolder_train)

options = statset('maxIter',5e5);
%svmStruct = svmtrain([cepsTPeak_cepsDemo cepsValPeak18TotalFolder_cepsDemo] ,labelsTotalFolder_train,'ShowPlot',true)
svmStruct = svmtrain([cepsTPeak_cepsDemo cepsValPeak18TotalFolder_cepsDemo] ,labelsTotalFolder_train,'ShowPlot',true,'Options', options)


