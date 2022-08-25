clear 
close all

% Choose study
list = {'Galit Yogev et al', 'Hausdorff et al', 'Silvi Frenkel-Toledo et al'};
[n_study,tf] = listdlg('ListString',list);

T = readtable('demographics.txt');

T.Properties.VariableNames = ["ID","Study","Group","Subjnum","Gender","Age","Height","Weight","HoehnYahr1","HoehnYahr2","UPDRS","UPDRSM","TUAG","Speed1_1","Speed1_2","Speed2_1","Speed2_2","Speed3_1","Speed3_2","Speed4_1"];
fs = 100;

%%%%%%%%%%%%%%%%%%%%%%%%
% Exploratory analysis %
%%%%%%%%%%%%%%%%%%%%%%%%

%head(T)
% We want to predict the Group they belong to (1 - PD patient, 2 - HC) based on gait features
% HoehnYahr, UPDRS and TUAG are scales to measure disability. We drop them since HC either dont have or would be too different
T(:,9:end)=[];

% Check missing values
for i=3:size(T,2)
    if find(isnan(T{:,i}))
        X = sprintf('%s has %d null values.',cell2mat(T.Properties.VariableNames(i)),length(find(isnan(T{:,i}))))
    end
end

%Since weight has just 2 missing values, I will impute it with the median
ind_nan=find(isnan(T.Weight));
nanclass=T.Group(ind_nan);
pd_ind=find(T.Group==1);
hc_ind=find(T.Group==2);

for i=1:length(ind_nan)
    if nanclass(i) == 1
        temp=median(T.Weight(~isnan(T.Weight(find(pd_ind)))));
        T.Weight(ind_nan(i))=temp;
    else
        temp=median(T.Weight(~isnan(T.Weight(find(hc_ind)))));
        T.Weight(ind_nan(i))=temp;
    end
end

%Since height just has 1 missing value, I will impute it with the median
ind_nan=find(isnan(T.Height));
nanclass=T.Group(ind_nan);
pd_ind=find(T.Group==1);
hc_ind=find(T.Group==2);

for i=1:length(ind_nan)
    if nanclass(i) == 1
        temp=median(T.Height(~isnan(T.Height(find(pd_ind)))));
        T.Height(ind_nan(i))=temp;
    else
        temp=median(T.Height(~isnan(T.Height(find(hc_ind)))));
        T.Height(ind_nan(i))=temp;
    end
end

%%%%%%%%%%%%%%%%%%%%%%
% Feature extraction %
%%%%%%%%%%%%%%%%%%%%%%

Feat = table;
i=1;
while i<=size(T,1)
    try
        file = append(T.ID(i),"_01.txt");
        subject = readtable(file);
        Feat(i,:) = extract_feat(subject,T.Weight(i));
        i = i+1;
    catch
        T(i,:)=[];
    end
end

Feat = [T(:,7:8) Feat]; %add height and weight

% Choose study
if n_study==[1,2,3]
    n_study = 4;
end
switch n_study
    case 1 % Galit Yogev et al
        ind_study = find(strcmp (T.Study,'Ga'));
    case 2 % Hausdorff et al
        ind_study = find(strcmp (T.Study,'Ju'));
    case 3 % Silvi Frenkel-Toledo et al
        ind_study = find(strcmp (T.Study,'Si'));
    otherwise % select all
        ind_study = 1:size(T.Study,1);
end
T=T(ind_study,:);
Feat=Feat(ind_study,:);

% Normalize data
Feat = normalize(Feat);

%%%%%%%%%%%%%%%%%%
% Classification %
%%%%%%%%%%%%%%%%%%

Classes = T.Group;

% Classes (0 or 1)
Classes(Classes==1) = 1; % 1 -> pd
Classes(Classes==2) = 0; % 2 -> hc

nrep = 20;

% RF
OOB = 'on'; %save predictor importance
for i=1:nrep
    Results_RF{i} = RF(Feat, Classes, OOB);
end

%%%%%%%%%%%%%%%
% Performance %
%%%%%%%%%%%%%%%

Results_RF_nrep = Performance_nrep(Results_RF,'RF');