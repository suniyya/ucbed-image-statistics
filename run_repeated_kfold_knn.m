function out = run_repeated_kfold_knn(X, Y, cfg)
    % X: trial x features matrix
    % Y: class labels

    accs = zeros(cfg.nReps, 1);
    confMats = [];

    for rep = 1:cfg.nReps
        cvp = cvpartition(Y, 'KFold', cfg.nFolds);
        foldAcc = zeros(cfg.nFolds, 1);

        allYPred = [];
        allYTrue = [];

        for fold = 1:cfg.nFolds
            XTrain = X(training(cvp, fold), :);
            YTrain = Y(training(cvp, fold));
            XTest  = X(test(cvp, fold), :);
            YTest  = Y(test(cvp, fold));

            mdl = fitcknn(XTrain, YTrain, 'NumNeighbors', cfg.k);
            YPred = predict(mdl, XTest);

            foldAcc(fold) = mean(YPred == YTest);

            allYPred = [allYPred; YPred];
            allYTrue = [allYTrue; YTest];
        end

        accs(rep) = mean(foldAcc);

        C = confusionmat(allYTrue, allYPred);
        confMats(:,:,rep) = C ./ sum(C, 2);
    end

    out.meanAcc = mean(accs);
    out.accs = accs;
    out.avgConfMat = mean(confMats, 3, 'omitnan');
end