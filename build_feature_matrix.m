function feature_matrix = build_feature_matrix(all_x, feature_set)
    [num_trials, num_patches, ~] = size(all_x);

    feature_matrix = zeros(num_trials, num_patches * numel(feature_set));

    for trial_idx = 1:num_trials
        row = [];
        for feature_idx = feature_set
            row = [row, squeeze(all_x(trial_idx, :, feature_idx))];
        end
        feature_matrix(trial_idx, :) = row;
    end
end