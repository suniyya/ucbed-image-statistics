function arm_result = run_ordered_feature_analysis(all_x, labels, n_reps, num_folds, num_neighbors)
%RUN_ORDERED_FEATURE_ANALYSIS Evaluate one statistic at a time.
%
% This function loops through each image statistic separately. For each
% statistic, it builds a trial-by-feature matrix using that single stat,
% runs repeated k-fold kNN classification, and stores the mean accuracy.
%
% Inputs
% ------
% all_x :
%     Trial x patch x statistic array of image statistics.
%
% labels :
%     Categorical grasp labels for each trial.
%
% n_reps :
%     Number of repeated cross-validation runs.
%
% num_folds :
%     Number of folds used in each cross-validation run.
%
% num_neighbors :
%     Number of neighbors used by the kNN classifier.
%
% Outputs
% -------
% arm_result :
%     Structure containing accuracy for each statistic.

    [~, ~, num_stats] = size(all_x);

    accuracies = nan(num_stats, 1);

    for stat_idx = 1:num_stats
        feature_set = stat_idx;  % one statistic at a time

        % Build the feature matrix once for this statistic
        feature_matrix = build_feature_matrix(all_x, feature_set);

        % Run repeated CV iterations
        accs = zeros(n_reps, 1);

        for rep_idx = 1:n_reps
            [mean_acc, ~, ~] = run_kfold_cv_knn(feature_matrix, labels, num_folds, num_neighbors);
            accs(rep_idx) = mean_acc;
        end

        accuracies(stat_idx) = mean(accs);
        fprintf('Stat %d complete\n', stat_idx);
    end

    arm_result.Accuracies = accuracies;
end