function arm_result = run_forward_selection(all_x, labels, n_reps, num_folds, num_neighbors)
%RUN_FORWARD_SELECTION Greedy forward selection using repeated k-fold kNN classification.
%
% This function ranks image statistics according to their contribution to
% grasp classification performance. The procedure begins by evaluating each
% statistic individually and selecting the one that produces the highest
% classification accuracy. At the next step, each remaining statistic is
% added to the selected set one at a time, and the combination producing
% the highest accuracy is retained. This process is repeated until all
% statistics have been considered, producing an ordered ranking of image
% statistics and a record of classification performance as additional
% statistics are added.
%
% Classification performance for each candidate feature set is estimated
% using repeated k-fold cross-validation with a k-nearest-neighbors
% classifier.
%
% Inputs
% ------
% all_x :
%     Trial x patch x statistic array of image statistics from one sub, one
%     arm
%
% labels :
%     Categorical grasp labels for each trial.
%
% n_reps :
%     Number of repeated k-fold CV runs.
%
% num_folds :
%     Number of folds used in each CV run.
%
% num_neighbors :
%     Number of neighbors used by the kNN classifier.
%
% Outputs
% -------
% arm_result :
%     Structure containing the selected statistic order, statistic ranks,
%     accuracy matrix across step/candidate combinations, and best accuracy
%     per step, for a single arm.
%
% Notes
% -----
% This is a greedy procedure, so it does not guarantee a globally optimal
% feature subset.

    [num_trials, num_patches, num_stats] = size(all_x);

    max_features = num_stats;
    num_features = num_stats;

    selected_features = [];
    feature_rank = [];
    all_features = 1:num_features;

    accuracies_per_step = zeros(max_features, 1);
    all_accuracies = nan(max_features, num_features);

    for step = 1:max_features
        best_mean_acc = -inf;
        best_feature = NaN;

        candidate_features = setdiff(all_features, selected_features);

        for candidate = candidate_features
            feature_set = [selected_features, candidate];

            % Build the feature matrix once for this feature set
            feature_matrix = build_feature_matrix(all_x, feature_set);

            % Run repeated CV iterations
            accs = zeros(n_reps, 1);

            for rep_idx = 1:n_reps
                [mean_acc, ~, ~] = run_kfold_cv_knn(feature_matrix, labels, num_folds, num_neighbors);
                accs(rep_idx) = mean_acc;
            end

            mean_acc = mean(accs);
            all_accuracies(step, candidate) = mean_acc;

            if mean_acc > best_mean_acc
                best_mean_acc = mean_acc;
                best_feature = candidate;
            end
        end

        % Record best
        selected_features = [selected_features, best_feature];
        feature_rank(best_feature) = step;
        accuracies_per_step(step) = best_mean_acc;

        fprintf('Step %d complete, feature %d chosen\n', step, best_feature);
    end

    arm_result.topFeatures = selected_features;
    arm_result.featureRank = feature_rank;
    arm_result.Accuracies = all_accuracies;
    arm_result.accuraciesPerStep = accuracies_per_step;
    arm_result.numTrials = num_trials;
    arm_result.numPatches = num_patches;
    arm_result.numStats = num_stats;
end