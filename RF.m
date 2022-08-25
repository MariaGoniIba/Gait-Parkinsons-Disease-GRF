% This is a function to return result of a RF classification
% INPUT
% data:     data (n subjects x m features)
% Classes   array of 0 and 1 (2 classes)
% OOB:      whether store out-of-bag predictor importance. Options: 'on', 'off' (default)
% OUTPUT
% Results   structure with performance metrics
% 
% WRITTEN BY
% Maria Goni, 04 August 2022

function Results = RF(data, Classes, OOB)

    %Set up parameters
    switch nargin
        case {0,1}
            error('Data and classes are needed!')
        case 2
            OOB = 'off'; %save predictor importance
    end

   % Cross-validation
   k = 10;
   [TrainInd, TestInd] = M_cross_validation(size(data,1),'Kfold',k);

   %Grid search
   n_Trees = [16, 32, 64, 128];

   % Number of features to consider
   nfeat = ceil(sqrt(size(data,2)));

   classpredict=[]; classreal=[]; Score=[]; weights=[]; opttrees=[]; %optimal number of trees
   for i = 1:k
        opttrees(i) = RFtuning(data(TrainInd{i},:), Classes(TrainInd{i},:));
        
        RFmodel = TreeBagger(opttrees(i),data(TrainInd{i},:),Classes(TrainInd{i},:),'Method', 'classification', 'OOBPredictorImportance', OOB, 'NumPredictorsToSample', nfeat);
        if find(strcmp(OOB,'on'))
           weights = [weights; RFmodel.OOBPermutedPredictorDeltaError];
        end
        [classp, score] = RFmodel.predict(data(TestInd{i},:));
        classpredict = [classpredict; classp];
        Score=[Score; score(:,2)];
        classreal=[classreal; Classes(TestInd{i},:)];
    
        clear RFmodel classp score
   end
   classpredict = str2num(cell2mat(classpredict));

   Results.Acc = length(find(classreal == classpredict)); %corregir!
   Results.TP = length(find(classreal==1 & classpredict==1));
   Results.TN = length(find(classreal==0 & classpredict==0));
   Results.FP = length(find(classreal==0 & classpredict==1));
   Results.FN = length(find(classreal==1 & classpredict==0));
   Results.Sens=Results.TP/(Results.TP+Results.FN);
   Results.Spec=Results.TN/(Results.TN+Results.FP);
   Results.BalAcc=(Results.Sens+Results.Spec)/2;
   Results.Precision=Results.TP/(Results.TP+Results.FP);
   Results.Recall=Results.TP/(Results.TP+Results.FN);
   Results.F1Score=2*((Results.Recall*Results.Precision)/(Results.Recall+Results.Precision));

   [Results.XX,Results.YY,Results.TT,Results.AUC]=perfcurve(classreal,Score,1,'XCrit', 'fpr', 'YCrit', 'sens', 'Xvals', [0:0.01:1], 'UseNearest', 'off');
   %plot(Results.XX,Results.YY)  

   Results.ntrees = opttrees;
   if find(strcmp(OOB,'on'))
       Results.weights=weights;
   end

end

