%% File Acquisition

files = dir('./pitch/ST201701_pitch/data/fda_ue/*.wav');
files_ref = dir('./pitch/ST201701_pitch/data/fda_ue/*.f0ref');

%% Parameter definition

w_L = 32; % window length in ms
Si_ms = 15; % Sampling interval in ms
threshold = 0.8;

%% Method Selection

autocorrelationMethod = false;
cepstrumMethod = true;
%% Iteration
if autocorrelationMethod
    for i=1:1:length(files)
        pitch_vect = [];
        j=0;
        files(i)
        [x, fs] = audioread(['./pitch/ST201701_pitch/data/fda_ue/',files(i).name]);
        mean_x = mean(abs(x));
        sampl_numb = length(x);
        figure(2);
        plot(1:sampl_numb, x, 1:sampl_numb, 2*mean_x*ones(sampl_numb,1))
        %pause
        threshold = 1.5*mean_x;
        Si_s = Si_ms * fs / 1000; % Sample interval in indices
        w_Ls = w_L * fs / 1000;   % Window length in indices
        for counter= -Si_s:Si_s:(sampl_numb-Si_s)
            start = counter + 1;
            finish = counter +(w_Ls) + 1;
            if finish>sampl_numb
                x_1 = [x(start:sampl_numb); zeros((w_Ls - length(start:sampl_numb)),1)];
                display(strcat('end', num2str(finish)));
            elseif start<0
                x_1 = [zeros((w_Ls - finish),1); x(1:finish)];
                display(strcat('start', num2str(start)))
            else
                x_1 = x(start:finish);
            end
          X_1 = fft(x_1);
        subplot(2,1,1)
        plot(x_1)
        title('Voiced Speech Signal')
        xlabel('Samples')
        ylabel('Amplitude')
        xlim([0, 640])
        ylim([-0.5, 0.5])
        rxx_1 = autocorr(x_1,3*w_Ls/4);
        %rxx_1 = rxx_aux(640:-1:1);

        subplot(2,1,2)
        plot(rxx_1)
        title('Correlation of a Voiced Speech Signal')
        xlabel('Samples')
        ylabel('Amplitude')
        xlim([0, 640])
        ylim([-4,4]);
pause
    %     cpstr = cceps(x_1);
    %     subplot(3,1,3)
    %     plot(cpstr)
    %     title('Cepstrum of a Voiced Speech Signal')
    %     xlabel('Samples')
    %     ylabel('Amplitude')
    %     xlim([0, 640])
    %     ylim([-4,4]);

        if mean(abs(x_1)) < threshold
            display(strcat('Unvoiced, pitch=',num2str(0)));
            pitchf = 0;
            %display(strcat(int2str(i),' Unvoiced  ', num2str(mean(abs(rxx_1)))));
        else
            %display(strcat(int2str(i),'Voiced ', num2str(mean(abs(rxx_1)))));
            % We know that we will not find a peak in the pitch in the first 
            % 50 samples of the correlation (as 50 -> 400Hz < max(Pitch) )
            sorted = sort(rxx_1);
            sorted_1 = fliplr(transpose(sorted));
            condition = true;
            iterator = 1;
            while condition
                aux = sorted_1(iterator);
                index = find(rxx_1 == aux);
                if index > 80
                    condition = false;
                    pitch = index - 1;
                end
                iterator = iterator + 1;
            end
            pitchf = fs/pitch
            display(strcat('Voiced,   pitch=',num2str(pitchf), ' Hz'));  
        end
        j=j+1;
        pitch_vect = [pitch_vect, pitchf];
        end
        pitch_vect = pitch_vect(2:1:length(pitch_vect));
        name = strsplit(files(i).name, '.');
        name(1)
        fileID = fopen(strcat(name{1}, '.t0'),'w');
        fprintf(fileID, '%f\n', pitch_vect);
        fclose(fileID);
        display(num2str(j));
        display('file fully analyzed');


    end
elseif cepstrumMethod
    for i=1:1:length(files)
        pitch_vect = [];
        j=0;
        files(i)
        [x, fs] = audioread(['./pitch/ST201701_pitch/data/fda_ue/',files(i).name]);
        Si_s = Si_ms * fs / 1000; % Sample interval in indices
        w_Ls = w_L * fs / 1000;   % Window length in indices
        for counter= 0:Si_s:(sampl_numb-2*Si_s)
            start = counter + 1;
            finish = counter +(w_Ls) + 1;
            if finish>sampl_numb
                x_1 = [x(start:sampl_numb); zeros((w_Ls - length(start:sampl_numb)+1),1)];
                display(strcat('end', num2str(finish)));
            elseif start<0
                x_1 = [zeros((w_Ls - finish),1); x(1:finish)];
                display(strcat('start', num2str(start)))
            else
                x_1 = x(start:finish);
            end
            subplot(3,1,1)
            plot(x_1)
            title('Voiced Speech Signal')
            xlabel('Samples')
            ylabel('Amplitude')
            xlim([0, 640])
            ylim([-0.5, 0.5])
            w = window(@hamming, w_Ls+1);
            x_1w = x_1.*w;
            x1_1 = log(abs(fft(x_1w)));
            x2_1 = ifft(x1_1);
            x3_1 = x2_1(1:(length(x2_1)/2));
            subplot(3,1,2);
            plot(x3_1);
            L = zeros(1, length(x3_1));
            L(30:length(L)) = 1;
            x4_1 = real(x3_1.*L');
            m = mean(abs(x4_1));
            subplot(3,1,3);
            plot(x4_1);
            hold on
            plot(m*ones(1, length(x4_1)), 'r');
            hold off
            sorted = sort(x4_1);
            sorted1 = sorted(length(sorted):-1:1);
            r = sorted1(1)/sorted1(8);
            [pitch_val, pitch_pos] = max(x4_1);
            pitch = pitch_pos;
            if r > 2
            pitchf = fs/pitch
            else
                pitchf = 0
            end
            pause
            title('Correlation of a Voiced Speech Signal')
            xlabel('Samples')
            ylabel('Amplitude')
            xlim([0, 640])
            ylim([-4,4]);

        %     cpstr = cceps(x_1);
        %     subplot(3,1,3)
        %     plot(cpstr)
        %     title('Cepstrum of a Voiced Speech Signal')
        %     xlabel('Samples')
        %     ylabel('Amplitude')
        %     xlim([0, 640])
        %     ylim([-4,4]);

%             if mean(abs(x_1)) < threshold
%                 display(strcat('Unvoiced, pitch=',num2str(0)));
%                 pitchf = 0;
%                 %display(strcat(int2str(i),' Unvoiced  ', num2str(mean(abs(rxx_1)))));
%             else
%                 %display(strcat(int2str(i),'Voiced ', num2str(mean(abs(rxx_1)))));
%                 % We know that we will not find a peak in the pitch in the first 
%                 % 50 samples of the correlation (as 50 -> 400Hz < max(Pitch) )
%                 sorted = sort(rxx_1);
%                 sorted_1 = fliplr(transpose(sorted));
%                 condition = true;
%                 iterator = 1;
%                 while condition
%                     aux = sorted_1(iterator);
%                     index = find(rxx_1 == aux);
%                     if index > 80
%                         condition = false;
%                         pitch = index - 1;
%                     end
%                     iterator = iterator + 1;
%                 end
%                 pitchf = fs/pitch
%                 display(strcat('Voiced,   pitch=',num2str(pitchf), ' Hz'));  
%             end
%             j=j+1;
%             pitch_vect = [pitch_vect, pitchf];
        end
        pitch_vect = pitch_vect(2:1:length(pitch_vect));
        name = strsplit(files(i).name, '.');
        name(1)
        fileID = fopen(strcat(name{1}, '.t0'),'w');
        fprintf(fileID, '%f\n', pitch_vect);
        fclose(fileID);
        display(num2str(j));
        display('file fully analyzed');


    end
end
% % % window_t = 32;
% % % window_t_shift = 10;
% % % fm = 48000;
% % % window_s = window_t*fm/1000;
% % % window_s_shift = window_t_shift*fm/1000;
% % % pos_win=1;
% % % features=[];
% % % labels=[];
% % % 
% % % %for k = 1 : length(files)
% % % for k = 1 : 15
% % %     [audio,fm] = audioread(['./pitch/ST201701_pitch/data/fda_ue/',files(k).name]);
% % %     fileID = fopen(['./pitch/ST201701_pitch/data/fda_ue/',files_ref(k).name]);
% % %     audio_ref = fscanf(fileID,'%f') > 1;
% % %     
% % %     i=0;
% % %     while pos_win+window_s<length(audio)
% % %         
% % %         audio_seg = audio(pos_win:pos_win+window_s);
% % %         seg_corr = xcorr(audio_seg);
% % %         max_corr = max(seg_corr);
% % %         mean_corr = mean(xcorr(audio_seg));
% % %         features = [features ; max_corr];
% % %         pos_win=pos_win+window_s_shift;
% % %         i = i+1;
% % % 
% % %     end
% % %     %----------
% % %     features = features(1:length(features)-3);
% % %     %----------
% % %     %plot(features,'.')
% % %     labels = [labels ; audio_ref];
% % %     disp(i);
% % %     pos_win = 1;
% % %     disp(['iteracio ',num2str(k) ' de ' num2str(length(files))]);
% % %     fclose('all');
% % % end
% % % 
% % % Mdl = fitcnb(double(features),labels)
% % % 
% % % estimates = Mdl.DistributionParameters;
% % % estimates{1}
% % % estimates{2}
% % % 
% % % sampled = datasample(features,100);
% % % scatter(sampled,ones(1,100));
% % % 
% % % 
% % % %evaluation
% % % [audio,fm] = audioread('.\train_database\mic_F09_si2001.wav');
% % % fileID = fopen('.\train_database\mic_F09_si2001.f0ref');
% % % audio_ref = fscanf(fileID,'%f') > 1;
% % % 
% % % i=0;
% % % features = [];
% % % while pos_win+window_s<length(audio)
% % %     audio_seg = audio(pos_win:pos_win+window_s);
% % %     seg_corr = xcorr(audio_seg);
% % %     max_corr = max(seg_corr);
% % %     mean_corr = mean(xcorr(audio_seg));
% % %     features = [features ; max_corr];
% % %     pos_win=pos_win+window_s_shift;
% % %     i = i+1;
% % % end
% % % 
% % % features = features(1:length(features)-3);
% % % result=[];
% % % for j=1:length(features)
% % % current_feature = double(features(j));
% % % prediction =Mdl.predict(current_feature);
% % % result = [result ; prediction];
% % % end
% % % figure(1)
% % % subplot(2,1,1)
% % % plot(audio)
% % % subplot(2,1,2)
% % % plot(features)
% % % comparativa = result==audio_ref
% % % ratio = sum(comparativa)/length(comparativa)
