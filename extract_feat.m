% INPUT
% data:     subject (signals for each sensor for an specific subject)
% weight:   weight of the subject
% OUTPUT
% Featurea  Table with features for the classification analysis
% 
% WRITTEN BY
% Maria Goni, 14 August 2022

function Features = extract_feat(subject, weight)

subject = table2array(subject);
subject = subject(:,2:end);

fs=100;
[B, A] = butter(4, 6/fs);
for i=1:size(subject,2)
    subject(:,i) = filtfilt(B, A, subject(:,i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACTION OF GAIT CYCLE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate when they lift the foot and when they step again
IC={}; LC={}; %initial contact, toe up; last contact, toe down
for n = 1:size(subject,2)
    i=1; ICtemp=[]; LCtemp=[];
    temp = subject(:,n);
    while i<length(temp)
        if temp(i)<0.3*weight && temp(i+1)>0.3*weight
            ICtemp=[ICtemp (i+1)];
        end
        if temp(i)>0.3*weight && temp(i+1)<0.3*weight
            LCtemp=[LCtemp i];
        end
        i=i+1; 
    end
    IC{n} = ICtemp; LC{n} = LCtemp;
    % plot(temp)
    % hold on
    % plot(IC{n},temp(IC{n}),'go','MarkerSize',8)
    % plot(LC{n},temp(LC{n}),'ro','MarkerSize',8)
    clear temp ICtemp LCtemp
end

%%%%%%%%%%%%%%%
% Time series %
%%%%%%%%%%%%%%%

% Stride time: time elapsed between the first contact of a foot and the first following contact of the same foot
stride = {};
for i=1:size(subject,2)
    ICtemp = IC{i};
    stride{i} = ICtemp(2:end)-ICtemp(1:(end-1));
    clear ICtemp
end

stance = {}; % Stance phase: period when the foot is in contact with the ground
swing = {}; % Period during which the foot is not in contact with the ground
press = {}; % Maximum pressure
for n=1:size(subject,2)
    ICtemp = IC{n}; LCtemp = LC{n};
    l_IC = length(ICtemp);
    l_LC = length(LCtemp);
    
    stancetemp =[]; swingtemp = []; presstemp = [];
    if ICtemp(1) < LCtemp(1)
        for i = 1:(min(l_IC,l_LC)-1)
            stancetemp = [stancetemp LCtemp(i)-ICtemp(i)];
            swingtemp = [swingtemp ICtemp(i+1)-LCtemp(i)];
            presstemp = [presstemp max(subject(ICtemp(i):LCtemp(i)))];
        end
        if l_IC > l_LC
            stancetemp = [stancetemp LCtemp(i)-ICtemp(i)];
            swingtemp = [swingtemp ICtemp(i+1)-LCtemp(i)];
            presstemp = [presstemp max(subject(ICtemp(i):LCtemp(i)))];
        else
            stancetemp = [stancetemp LCtemp(i)-ICtemp(i)];
            presstemp = [presstemp max(subject(ICtemp(i):LCtemp(i)))];
        end
    
    elseif ICtemp(1) > LCtemp(1)
        for i = 1:(min(l_IC,l_LC)-1)
            stancetemp = [stancetemp LCtemp(i+1)-ICtemp(i)];
            swingtemp = [swingtemp ICtemp(i)-LCtemp(i)];
            presstemp = [presstemp max(subject(ICtemp(i):LCtemp(i+1)))];
        end
        if l_LC > l_IC
            stancetemp = [stancetemp LCtemp(i+1)-ICtemp(i)];
            swingtemp = [swingtemp ICtemp(i)-LCtemp(i)];
            presstemp = [presstemp max(subject(ICtemp(i):LCtemp(i+1)))];
        else
            swingtemp = [swingtemp ICtemp(i)-LCtemp(i)];
        end
    end
    stance{n} = stancetemp;
    swing{n} = swingtemp;
    press{n} = presstemp;
    clear ICtemp LCtemp stancetemp swingtemp presstemp
end

% Stance ratio, swing ratio and swing-stance ratio
Rstance={}; Rswing={}; Rswingstance = {};
for i =1:size(subject,2)
    stridetemp = stride{i};
    stancetemp = stance{i};
    swingtemp = swing{i};
    LCtemp = LC{i}; ICtemp = IC{i};
    if LCtemp(1)<ICtemp(1)
        swingtemp = swingtemp(2:end);
    end
    if length(stancetemp) > length(stridetemp)
        stancetemp(end) = [];
    end
    Rstance{i} = stancetemp./stridetemp;
    Rswing{i} = stridetemp./stancetemp;
    Rswingstance{i} = swingtemp./stancetemp;
    clear stridetemp stancetemp swingtemp
end

% fluctiation magnitude variability as per "Parkinson s Disease Diagnosis and Severity Assessment Using Ground Reaction Forces and Neural Networks"
for i = 1:8
    FMV{i} = (abs(subject(:,i)-subject(:,i+8)))./subject(:,i);
end
FMV{i+1} = (abs(subject(:,17)-subject(:,18)))./subject(:,17); %total force under the left and right foot

% I delete far outliers
for i = 1:size(subject,2)
    stride{i} = delete_outliers(stride{i});
    stride{i} = stride{i}/fs; %in seconds
    stance{i} = delete_outliers(stance{i});
    stance{i} = stance{i}/fs; %in seconds
    swing{i} = delete_outliers(swing{i});
    swing{i} = swing{i}/fs; %in seconds
    press{i} = delete_outliers(press{i});
    Rstance{i} = delete_outliers(Rstance{i});
    Rswing{i} = delete_outliers(Rswing{i});
    Rswingstance{i} = delete_outliers(Rswingstance{i});
end
for i = 1:size(FMV,2)
FMV{i} = delete_outliers(FMV{i});
end

%%%%%%%%%%%%
% Features %
%%%%%%%%%%%%

for i = 1:size(subject,2)
    n_steps{i} = length(stride{n});
    cadence{i} = n_steps{i}/((length(subject)/fs)/60);% Cadence (steps/min)
    stride_m{i} = mean(stride{i});
    stride_std{i} = std(stride{i});
    stride_cv{i}=stride_std{i}./stride_m{i}; %Stride Variability (coefficient of variation)
    stance_m{i} = mean(stance{i});
    stance_std{i} = std(stance{i});
    stance_cv{i} = stance_std{i}./stance_m{i};
    swing_m{i} = mean(swing{i});
    swing_std{i} = std(swing{i});
    swing_cv{i} = swing_std{i}./swing_m{i};
    press_m{i} = mean(press{i});
    press_std{i} = std(press{i});
    press_cv{i} = press_std{i}./press_m{i};
    Rstance_m{i} = mean(Rstance{i});
    Rstance_std{i} = std(Rstance{i});
    Rstance_cv{i} = Rstance_std{i}./Rstance_m{i};
    Rswing_m{i} = mean(Rswing{i});
    Rswing_std{i} = std(Rswing{i});
    Rswing_cv{i} = Rswing_std{i}./Rswing_m{i};
    Rswingstance_m{i} = mean(Rswingstance{i});
    Rswingstance_std{i} = std(Rswingstance{i});
    Rswingstance_cv{i} = Rswingstance_std{i}./Rswingstance_m{i};
end

for i = 1:size(FMV,2)
    FMV_m{i} = mean(FMV{i});
    FMV_std{i} = std(FMV{i});
    FMV_cv{i} = FMV_std{i}./FMV_m{i};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create table with all features %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Features=[];
for i = 1:size(subject,2)
    Features = [Features n_steps{i} cadence{i} stride_m{i} stride_std{i} stride_cv{i} ...
    stance_m{i} stance_std{i} stance_cv{i} swing_m{i} swing_std{i} swing_cv{i} ...
    press_m{i} press_std{i} press_cv{i} Rstance_m{i} Rstance_std{i} Rstance_cv{i} ...
    Rswing_m{i} Rswing_std{i} Rswing_cv{i} Rswingstance_m{i} Rswingstance_std{i} ...
    Rswingstance_cv{i}];
end
for i = 1:size(FMV_m)
    Features = [Features FMV_m{i} FMV_std{i} FMV_cv{i}];
end

Features = array2table(Features);



