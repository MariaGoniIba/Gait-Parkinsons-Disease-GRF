function ntrees = RFtuning(data, Classes)

% Cross-validation
k = 10;
[TrainInd, TestInd] = M_cross_validation(size(data,1),'Kfold',k);

%Grid search
n_Trees = [16, 32, 64, 128];
nfeat = ceil(sqrt(size(data,2)));

classpredict=[];
for i=1:k
    opttrees(i)=1; optBalAcc = 0;
    for j=1:length(n_Trees)
        RFmodel = TreeBagger(n_Trees(j),data(TrainInd{i},:),Classes(TrainInd{i},:),'Method', 'classification', 'OOBPrediction', 'on','NumPredictorsToSample', nfeat);
        [classp, score] = RFmodel.predict(data(TestInd{i},:));
        score=score(:,2);
        classreal=Classes(TestInd{i},:);
        classp = str2num(cell2mat(classp));
        Results.TP = length(find(classreal==1 & classp==1));
        Results.TN = length(find(classreal==0 & classp==0));
        Results.FP = length(find(classreal==0 & classp==1));
        Results.FN = length(find(classreal==1 & classp==0));
        Results.Sens=Results.TP/(Results.TP+Results.FN);
        Results.Spec=Results.TN/(Results.TN+Results.FP);
        Results.BalAcc=(Results.Sens+Results.Spec)/2;

        if Results.BalAcc > optBalAcc
            optBalAcc = Results.BalAcc;
            opttrees(i)=n_Trees(j);
        end
    end
end

ntrees = mode(opttrees);