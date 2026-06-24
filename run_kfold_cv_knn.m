function [mean_acc, allYPred, allYTrue] = run_kfold_cv_knn(X, Y, num_folds, num_neighbors)
    cvp = cvpartition(Y, 'KFold', num_folds);
    foldAcc = zeros(num_folds, 1);
    allYPred = [];
    allYTrue = [];

    for fold = 1:num_folds
        XTrain = X(training(cvp, fold), :);
        YTrain = Y(training(cvp, fold));
        XTest = X(test(cvp, fold), :);
        YTest = Y(test(cvp, fold));
    
        mdl = fitcknn(XTrain, YTrain, 'NumNeighbors', num_neighbors);
        YPred = predict(mdl, XTest);
        foldAcc(fold) = mean(YPred == YTest);
    
        allYPred = [allYPred; YPred];
        allYTrue = [allYTrue; YTest];
    end
    
    mean_acc = mean(foldAcc);
end