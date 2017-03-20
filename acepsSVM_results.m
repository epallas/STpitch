%clear all
%load('workspace_acepsSVM.mat')

[C,p] = voicingPresision (myLabelsTotalFolder_ceps, labelsTotalFolder)

%F0TotalFolder_medianFilt = F0TotalFolder;
F0TotalFolder_medianFilt = medfilt1(F0TotalFolder,5);

voicedAsVoicedIndex = find((myLabelsTotalFolder_ceps + labelsTotalFolder)==2);
voicedAsVoiced_f0ref = f0refTotalFolder(voicedAsVoicedIndex);
voicedAsVoiced_F0    = F0TotalFolder_medianFilt   (voicedAsVoicedIndex);

figure
plot(f0refTotalFolder)
hold on
plot(F0TotalFolder,'r')
hold off


% Gross voiced errors: In voiced frames, detected as voiced, Pitch errors greater than 20%
errHigher20 = find((abs(voicedAsVoiced_f0ref - voicedAsVoiced_F0)./voicedAsVoiced_f0ref) > 0.2);
gverrors = length(errHigher20)/length(voicedAsVoiced_f0ref)

errLower20 = find((abs(voicedAsVoiced_f0ref - voicedAsVoiced_F0)./voicedAsVoiced_f0ref) <= 0.2);
aux = ((voicedAsVoiced_f0ref(errLower20)-voicedAsVoiced_F0(errLower20))./voicedAsVoiced_f0ref(errLower20)).^2;
errMSE  = sqrt(sum(aux)/length(voicedAsVoiced_F0(errLower20)))
errSMSE = mean(abs(voicedAsVoiced_f0ref(errLower20)-voicedAsVoiced_F0(errLower20)))

figure
plot(f0refTotalFolder)
hold on
plot(F0TotalFolder_medianFilt,'r')
hold off