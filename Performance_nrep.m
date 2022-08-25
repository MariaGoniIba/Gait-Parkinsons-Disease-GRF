function Results_nrep = Performance_nrep(Results,type)

    nrep = size(Results,2);
    
    Acc=[]; TP=[]; TN=[]; FP=[]; FN=[]; Sens=[]; Spec=[]; BalAcc=[]; Precision=[]; Recall=[]; F1Score=[]; AUC=[]; XX=[]; YY=[];
    for i = 1:nrep
        Acc = [Acc Results{i}.Acc];
        TP = [TP Results{i}.TP];
        TN = [TN Results{i}.TN];
        FP = [FP Results{i}.FP];
        FN = [FN Results{i}.FN];
        Sens = [Sens Results{i}.Sens];
        Spec = [Spec Results{i}.Spec];
        BalAcc = [BalAcc Results{i}.BalAcc];
        Precision = [Precision Results{i}.Precision];
        Recall = [Recall Results{i}.Recall];
        F1Score = [F1Score Results{i}.F1Score];
        AUC = [AUC Results{i}.AUC];
        XX = [XX Results{i}.XX];
        YY = [YY Results{i}.YY];
    end
    Results_nrep.Acc = mean(Acc);
    Results_nrep.TP = mean(TP);
    Results_nrep.TN = mean(TN);
    Results_nrep.FP = mean(FP);
    Results_nrep.FN = mean(FN);
    Results_nrep.Sens = mean(Sens);
    Results_nrep.Spec = mean(Spec);
    Results_nrep.BalAcc = mean(BalAcc);
    Results_nrep.Precision = mean(Precision);
    Results_nrep.Recall = mean(Recall);
    Results_nrep.F1Score = mean(F1Score);
    Results_nrep.AUC = mean(AUC);
    Results_nrep.XX = mean(XX');
    Results_nrep.YY = mean(YY');
    
    if type == "RF"
        if isfield(Results{1}, 'weights') %check if weights were stored, so OOB = 1
            weights = [];
            for i = 1:nrep
                weights = [weights; Results{i}.weights];
            end
            Results_nrep.weights = weights;
        end
    end
end
