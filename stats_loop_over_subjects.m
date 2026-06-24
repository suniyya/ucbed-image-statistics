function all_data = stats_loop_over_subjects(subject_ids, avg_by, sq_img_len, image_type)
    % STATS_LOOP_OVER_SUBJECTS
    %
    % Extract image statistics for each subject, grasp, and arm, then save
    % results in the same format as:
    %
    %   SHR057_100Patches_01BlockAvg_Stats.mat
    %
    % If image_type = 'end_state', use calculate_statistics_end_stats
    % Output structure:
    %
    %   all_data.arm0.stats
    %   all_data.arm0.graspname
    %   all_data.arm0.subj
    %   all_data.arm1.stats
    %   all_data.arm1.graspname
    %   all_data.arm1.subj
    %   all_data.subj
    %   all_data.numPatch
    %   all_data.avgBy
    %   all_data.imgLen
    %   all_data.centX
    %   all_data.centY

    % -----------------------------
    % User-defined / dummy variables
    % -----------------------------

    data_dir = 'C:\Users\suniy\Box\Work\ultrasound\data';

    % Dummy/default values inferred from the attached file.
    % Update these if they are created elsewhere in your real pipeline.
    num_patches = 100;
    cent_x = 512;
    cent_y = 420;

    save_results = true;

    grasp_names = { ...
        'iflex', 'key', 'pinch', 'point', 'power', ...
        'rpower', 'tripod', 'wext', 'wflex', 'wrot'};

    % -----------------------------
    % Loop over subjects
    % -----------------------------

    for subject_id = subject_ids
        fprintf('Subject %d\n', subject_id);

        subject_static_dir = fullfile( ...
            data_dir, ...
            sprintf('SHR%03dSS', subject_id), ...
            sprintf('SHR%03d', subject_id));

        if ~isfolder(subject_static_dir)
            fprintf('  Skipping subject %d: directory not found.\n', subject_id);
            continue
        end

        fprintf('  Analyzing subject %d\n', subject_id);

        arm0 = initialize_arm_result();
        arm1 = initialize_arm_result();

        for grasp_idx = 1:numel(grasp_names)
            grasp_name = grasp_names{grasp_idx};
            fprintf('    Grasp: %s\n', grasp_name);

            [image_stats_arm0, grasp_names_arm0, ~] = grasps_to_image_stats( ...
                subject_static_dir, grasp_name, 0, avg_by, sq_img_len, image_type);

            [image_stats_arm1, grasp_names_arm1, ~] = grasps_to_image_stats( ...
                subject_static_dir, grasp_name, 1, avg_by, sq_img_len, image_type);

            arm0 = append_grasp_result( ...
                arm0, image_stats_arm0, grasp_names_arm0, subject_id);

            arm1 = append_grasp_result( ...
                arm1, image_stats_arm1, grasp_names_arm1, subject_id);
        end

        % -----------------------------
        % Match attached .mat structure
        % -----------------------------

        all_data = struct();

        all_data.arm0 = arm0;
        all_data.arm1 = arm1;

        all_data.subj = subject_id;
        all_data.numPatch = num_patches;
        all_data.avgBy = avg_by;
        all_data.imgLen = sq_img_len;
        all_data.centX = cent_x;
        all_data.centY = cent_y;
        all_data.image_type = image_type;

        % -----------------------------
        % Optional sanity check
        % -----------------------------

        fprintf('  arm0.stats size: %s\n', mat2str(size(all_data.arm0.stats)));
        fprintf('  arm1.stats size: %s\n', mat2str(size(all_data.arm1.stats)));

        % -----------------------------
        % Optional PCA display
        % -----------------------------

        stats_arm0_2d = reshape_stats_for_pca(all_data.arm0.stats);
        stats_arm1_2d = reshape_stats_for_pca(all_data.arm1.stats);

        [~, ~, ~, ~, explained_arm0] = pca(stats_arm0_2d);
        [~, ~, ~, ~, explained_arm1] = pca(stats_arm1_2d);

        fprintf('  Variance explained, arm 0:\n');
        disp(explained_arm0);

        fprintf('  Variance explained, arm 1:\n');
        disp(explained_arm1);

        % -----------------------------
        % Save file
        % -----------------------------

        if save_results
            save_name = sprintf( ...
                'SHR%03d_%dPatches_%02dBlockAvg_Stats.mat', ...
                subject_id, num_patches, avg_by);

            save_path = fullfile(subject_static_dir, save_name);

            save(save_path, 'all_data');

            fprintf('  Saved: %s\n', save_path);
        end
    end
end


function arm_result = initialize_arm_result()
    % Initialize one arm's result structure.

    arm_result = struct();
    arm_result.stats = [];
    arm_result.graspname = {};
    arm_result.subj = [];
end


function arm_result = append_grasp_result( ...
    arm_result, image_stats, grasp_names, subject_id)
    % Append one grasp's data to an arm result structure.

    n_trials = numel(grasp_names);

    arm_result.stats = cat(1, arm_result.stats, image_stats);
    arm_result.graspname = cat(1, arm_result.graspname, grasp_names);
    arm_result.subj = cat(1, arm_result.subj, repmat(subject_id, n_trials, 1));
end


function stats_2d = reshape_stats_for_pca(stats)
    % PCA expects observations x features.
    %
    % If stats is:
    %   trials x patches x statistics
    %
    % reshape to:
    %   trials x flattened_features

    if ndims(stats) == 3
        n_trials = size(stats, 1);
        stats_2d = reshape(stats, n_trials, []);
    else
        stats_2d = stats;
    end
end