clear all

full_featureset = 0;
%default values - no grid search over params
alpha = 0.6;
lambda = 0.015;
no_baro=0; % 0 - use barometer

X = load('HealthyData.mat');
X = X.F;
%convert labels to binary (1,4=falls, 9=activities/nonfalls)
% Assign fall categories as 1 (falls) or 0 (non-fall)
L = X(:,4); %labels for classification
L=(L<9);%+1;  %binary labeling
subjid = X(:,1:3);  %[subjid, location subjcode]
if full_featureset
    F=X(:,5:end);
else
    F = X(:,943:962); % only magnitude features
end
subj=unique(subjid(:,1));

disp('Training model on all healthy data')
[fvar,b,nz_ind]=Modeltrain(F,L,alpha,lambda,no_baro);
Flab = F; 
Llab = L;

%% Test on amputee lab
Thres = 0.5;
disp('Test model on amputees - lab data')
display = 1;
X_Amp = load('Test_Data_Amputees');
X_Amp = X_Amp.F;
L = X_Amp(:,4); L = L<9;
X_Amp(:,1:4) = [];
if full_featureset
    F=X_Amp(:,1:end);
else
    F = X_Amp(:,939:958); % only magnitude features
end
[pred,conf,confmat] = Modeleval(F,L,fvar,nz_ind,b,Thres,display);


%% Load Home data and test
Thres = 0.5;
display = 0;
load ../SkyFall_HomeData/Nick_Luca_01132017/LucaHomeData.mat
%extract features 
F = [];
F = HomeDataSetup(labelsLuca,1.5); %1.5g threshold for acceleration clips
sprintf('Data length = %.2f h',size(F,1)*5/60/60)
if full_featureset
    F=F(:,1:end);
else
    F = F(:,939:958); % only magnitude features
end
L = zeros(size(F,1),1);
[pred,conf,confmat] = Modeleval(F,L,fvar,nz_ind,b,Thres,display);
sprintf('Spec = %.2f%', length(pred)/(length(pred)+sum(pred)))
figure, histogram(conf)    
figure, histogram(pred)

%% Train on Healthy Lab + home data misclassified clips
indmisc=find(pred);
Fmisc = F(indmisc,:); Lmisc = zeros(length(indmisc),1);
F = [Flab;Fmisc]; L = [Llab;Lmisc];
disp('Training model on lab + misclassified home data')
[fvar,b,nz_ind]=Modeltrain(F,L,alpha,lambda,no_baro);

%test model on amputee dataset
Thres = 0.5;
disp('Test model on amputees - lab data')
display = 1;
X_Amp = load('Test_Data_Amputees');
X_Amp = X_Amp.F;
L = X_Amp(:,4); L = L<9;
X_Amp(:,1:4) = [];
if full_featureset
    F=X_Amp(:,1:end);
else
    F = X_Amp(:,939:958); % only magnitude features
end
[pred,conf,confmat] = Modeleval(F,L,fvar,nz_ind,b,Thres,display);

%% Train on Healthy Lab + home data
load ../SkyFall_HomeData/Nick_Luca_01132017/NickHomeData.mat
%extract features 
F = [];
F = HomeDataSetup(labelsNick,1.5); %1.5g threshold for acceleration clips
if full_featureset
    F=F(:,1:end);
else
    F = F(:,939:958); % only magnitude features
end
L = zeros(size(F,1),1);

F = [Flab;F]; L = [Llab;L];
disp('Training model on lab + home data')
[fvar,b,nz_ind]=Modeltrain(F,L,alpha,lambda,no_baro);

%% Load Home data and test
Thres = 0.5;
display = 0;
%extract features 
F = [];
F = HomeDataSetup(labelsLuca,1.5); %1.5g threshold for acceleration clips
if full_featureset
    F=F(:,1:end);
else
    F = F(:,939:958); % only magnitude features
end
L = zeros(size(F,1),1);
[pred,conf,confmat] = Modeleval(F,L,fvar,nz_ind,b,Thres,display);
sprintf('Spec = %.2f%', length(pred)/(length(pred)+sum(pred)))

figure, histogram(conf)    
figure, histogram(pred)

%% Test on amputee lab

display = 1;
X_Amp = load('Test_Data_Amputees');
X_Amp = X_Amp.F;
L = X_Amp(:,4); L = L<9;
X_Amp(:,1:4) = [];
if full_featureset
    F=X_Amp(:,1:end);
else
    F = X_Amp(:,939:958); % only magnitude features
end
[pred,conf,confmat] = Modeleval(F,L,fvar,nz_ind,b,Thres,display);

%% Test phone model w Gyro features
load ./PhoneModels/MagFeat.mat
F = HomeDataSetup(labelsNick,1.5); %1.5g threshold for acceleration clips
F=F(:,1:end);

L=false(size(F,1),1);

FNZ = F(:,fvar.nzstd);
FN = (FNZ - repmat(fvar.mu,[size(FNZ,1),1])) ./ repmat(fvar.std,[size(FNZ,1),1]); %features normalized
FN = FN(:,nz_ind);
conf= glmval(b, FN, 'logit');
pred= ceil(conf-Thres);

%results
isfall = logical(L);
confmat(:,:)=confusionmat(isfall,pred==1,'order',[false true]);

figure, histogram(conf)    
figure, histogram(pred)
    



