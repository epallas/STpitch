%% Read file 
filesAudio2 = dir('pitch\ST201701_pitch\data\fda_ue\*.wav');
filesf0ref2 = dir('pitch\ST201701_pitch\data\fda_ue\*.f0ref');

win = 15/1000; % Size in s
shift = 15/1000; % window movement per frame

labelsTotalFolder = [];
f0refTotalFolder = [];
myLabelsTotalFolder_ceps = [];
F0TotalFolder = [];

cepsValPeak18TotalFolder_cepsDemo = [];
cepsNumPeaks_cepsDemo = [];
cepsTPeak_cepsDemo = [];
cepsMaxPosition_cepsDemo = [];
NsamplesFft = 1e4;

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
        
        myLabels_ceps(i+1) = svmclassify(svmStruct,[cepsTPeak(i+1) cepsValPeak18(i+1)]);
        
        if myLabels_ceps(i+1) == 1
            cc = cceps(winSamples);
            cc = cc(Fs/400:length(cc)/2);
            %[maxCC, indexOfCC] = max(cc);
            F0(i+1) = Fs/iMax;
        end
        
        count2 = count2 + 1;
        %waitbar(count2 / numOfFrames, h1);
    end 
    %close(h1)
    %xcorPeak12 = xcorPeak12(1:length(labelsJ));
    %xcorNumpeaks = xcorNumpeaks(1:length(labelsJ));
    labelsJ       = labelsJ       (1:length(F0));
    myLabels_ceps = myLabels_ceps (1:length(F0));
    F0            = F0            (1:length(F0));
    f0ref         = f0ref         (1:length(F0));
    cepsTPeak     = cepsTPeak     (1:length(F0));
    cepsValPeak18 = cepsValPeak18 (1:length(F0));
    
    labelsTotalFolder = [labelsTotalFolder; labelsJ];
    cepsValPeak18TotalFolder_cepsDemo = [cepsValPeak18TotalFolder_cepsDemo; cepsValPeak18];
    cepsNumPeaks_cepsDemo = [cepsNumPeaks_cepsDemo; cepsNumpeaks];
    cepsTPeak_cepsDemo = [cepsTPeak_cepsDemo; cepsTPeak];
    cepsMaxPosition_cepsDemo = [cepsMaxPosition_cepsDemo; cepsMaxPosition];
    myLabelsTotalFolder_ceps = [myLabelsTotalFolder_ceps; myLabels_ceps];
    F0TotalFolder = [F0TotalFolder; F0];
    f0refTotalFolder = [f0refTotalFolder; f0ref];
    
    count = count + 1;
    waitbar(count/length(filesAudio2),h)
end
close(h)
% gscatter(cepsMaxPosition_cepsDemo,cepsValPeak18TotalFolder_cepsDemo,labelsTotalFolder,'bg','..')
gscatter(cepsTPeak_cepsDemo,cepsValPeak18TotalFolder_cepsDemo,labelsTotalFolder,'bg','..')
[C,p] = voicingPresision (myLabelsTotalFolder_ceps, labelsTotalFolder)

%options = statset('maxIter',10e5);
%svmStruct_test = svmtrain([cepsTPeak_cepsDemo cepsValPeak18TotalFolder_cepsDemo] ,labelsTotalFolder,'ShowPlot',true)
%svmStruct_test = svmtrain([cepsTPeak_cepsDemo cepsValPeak18TotalFolder_cepsDemo] ,labelsTotalFolder_train,'ShowPlot',true,'Options', options)


