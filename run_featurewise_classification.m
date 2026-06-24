subjects = [17];  % subjects to process
stats_path = 'C:\Users\7piec\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Stats by Patch';
save_pattern = 'C:\Users\7piec\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Classification by Patch\SHR%03d_%02dPatches_%02dBlockAvg_FeatureWise.mat';

patch_sizes = [100, 225, 400, 900, 1225, 1600, 3600, 4900];
patch_tags = string(patch_sizes) + "Patches";  % avoids matching 1000Patches

n_reps = 50;
num_folds = 5;
num_neighbors = 5;

arm_names = {'arm0', 'arm1'};  % analyze affected and unaffected arms separately
files = dir(fullfile(stats_path, '*.mat'));  % get all .mat files in directory

if ~exist(stats_path, 'dir')
    error('Invalid file path')
end

for subject_id = subjects
    subject_tag = sprintf('SHR%03d', subject_id);

    for file_idx = 1:length(files)
        file_name = files(file_idx).name;

        is_subject_file = contains(file_name, subject_tag);
        is_target_patch = any(contains(file_name, patch_tags));

        if ~(is_subject_file && is_target_patch)
            continue
        end

        full_path = fullfile(stats_path, file_name);
        fprintf('Loading file: %s\n', file_name);
        load(full_path);

        result = struct();
        result.subj = all_data.subj;
        result.numPatch = all_data.numPatch;
        result.avgBy = all_data.avgBy;
        result.imgLen = all_data.imgLen;
        result.centX = all_data.centX;
        result.centY = all_data.centY;

        for arm_idx = 1:length(arm_names)
            arm = arm_names{arm_idx};

            all_x = all_data.(arm){1,1}.stats;
            labels = categorical(all_data.(arm){1,1}.graspname);

            [~, num_patches, ~] = size(all_x);
            num_sub = all_data.(arm){1,1}.subj(1);

            arm_result = run_ordered_feature_analysis(all_x, labels, n_reps, num_folds, num_neighbors);

            if strcmp(arm, 'arm0')
                limb = 'Aff';
            else
                limb = 'UA';
            end

            arm_result.limb = limb;
            result.(arm) = arm_result;

            fprintf('%s arm complete\n', limb);
        end

        save_name = sprintf(save_pattern, num_sub, num_patches, result.avgBy);
        save(save_name, 'result');
    end
end