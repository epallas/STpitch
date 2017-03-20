clear all
load('workspace_aacorrB.mat')

[C,p] = voicingPresision (myLabelsTotalFolder, labelsTotalFolder)


F0TotalFolder_medianFilt = medfilt1(F0TotalFolder,5);

voicedAsVoicedIndex = find((myLabelsTotalFolder + labelsTotalFolder)==2);
voicedAsVoiced_f0ref = f0refTotalFolder(voicedAsVoicedIndex);
voicedAsVoiced_F0    = F0TotalFolder_medianFilt   (voicedAsVoicedIndex);

% figure
% plot(f0refTotalFolder)
% hold on
% plot(F0TotalFolder,'r')
% hold off


% Gross voiced errors: In voiced frames, detected as voiced, Pitch errors greater than 20%
errHigher20 = find((abs(voicedAsVoiced_f0ref - voicedAsVoiced_F0)./voicedAsVoiced_f0ref) > 0.2);
gverrors = length(errHigher20)/length(voicedAsVoiced_f0ref)

errLower20 = find((abs(voicedAsVoiced_f0ref - voicedAsVoiced_F0)./voicedAsVoiced_f0ref) <= 0.2);
errMSE  = mean((voicedAsVoiced_f0ref(errLower20)-voicedAsVoiced_F0(errLower20)).^2)
errSMSE = mean(abs(voicedAsVoiced_f0ref(errLower20)-voicedAsVoiced_F0(errLower20)))

figure
plot(f0refTotalFolder)
hold on
plot(F0TotalFolder_medianFilt,'r')
hold off