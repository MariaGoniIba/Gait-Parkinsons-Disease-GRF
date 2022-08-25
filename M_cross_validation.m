% This is a function to return indices for training and testing for
% different crossvalidation procedures
% INPUT
% nsubj:    number of subjects
% method:   CV method. It can be "LOO" or "Kfold"
% k:        number of folds if Kfold is chosen as method. By default is 10
% OUTPUT
% TrainInd: cell array with indices for each CV iteration for training
% TestInd:  cell array with indices for each CV iteration for testing
% WRITTEN BY
% Maria Goni, 01 August 2022

function [TrainInd, TestInd] = M_cross_validation(nsubj,method,k)

    %Set up parameters
    switch nargin
        case 1
            error('Specify the type of CV')
        case 2
            switch method
                case 'LOO'
                    k=nsubj;
                case 'Kfold'
                    k=10; %if it is not LOO, and k was not specified, by default k=10
                otherwise
                    error(['unknown method: ' method])
            end
    end
    
    switch method
        case 'LOO'
            exp=1:nsubj;
            TestInd=num2cell(exp); %Index for testing is one each time
            %TrainInd={};
            for i=1:nsubj
                TrainInd{i}=exp(exp~=i);
            end
        case 'Kfold'
            exp=randperm(nsubj);
            C=cvpartition(nsubj,'KFold',k);
            ini=1;
            for i=1:k
                TestInd{i}=exp(ini:(ini+C.TestSize(i)-1));
                TrainInd{i}=exp(find(~ismember(exp,TestInd{i})));
                ini=C.TestSize(i)+ini;
            end
            %case bootstrap
    end
end
