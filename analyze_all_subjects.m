function [arm0, arm1] = analyze_all_subjects(subs, avg_by, sqImgLen)
    % names of grasps to cover
    grasps = {'iflex', 'key', 'pinch', 'point', 'power', 'rpower', 'tripod',...
        'wext', 'wflex', 'wrot'}; 
    % set path to all data
    path_to_data = 'C:\Users\suniy\Box\Work\ultrasound\data';
    % path_to_static_state_dir
    for subj_num=subs
        disp(strcat('subject', num2str(subj_num)));
        path_to_ss = sprintf('%s/SHR%03dSS/SHR%03d', path_to_data, subj_num, subj_num);
        if ~isfolder(path_to_ss)
           continue
        end
        fprintf('Analyzing subject %d\n', subj_num);
        arm0 = struct('stats', zeros(0, 10), 'graspname', {});
        arm1 = struct('stats', zeros(0, 10), 'graspname', {});
        for grasp=grasps
            grasp
            [image_stats0, graspname0, limb0] = grasps_to_image_stats(path_to_ss, grasp, 0, avg_by, sqImgLen);
            [image_stats1, graspname1, limb1] = grasps_to_image_stats(path_to_ss, grasp, 1, avg_by, sqImgLen);
            if ~isfield(arm0, 'subj')
                arm0(1).subj = repmat(subj_num, length(graspname0), 1);
                arm1(1).subj = repmat(subj_num, length(graspname1), 1);
                arm0.stats = image_stats0;
                arm0.graspname = graspname0;
                arm1.stats = image_stats1;
                arm1.graspname = graspname1;
            else
                arm0.stats = cat(1, arm0.stats, image_stats0);
                arm1.stats = cat(1, arm1.stats, image_stats1);
                arm0.subj =  cat(1, arm0.subj, repmat(subj_num, length(graspname0), 1));
                arm1.subj =  cat(1, arm1.subj, repmat(subj_num, length(graspname1), 1));
                arm0.graspname = cat(1, arm0.graspname, graspname0);
                arm1.graspname = cat(1, arm1.graspname, graspname1);
            end
        end
        [coeff, limb0, ~, ~, explained] = pca(arm0.stats);
        [coeff, limb1, ~, ~, explained2] = pca(arm1.stats);
        disp('Var explained');
        disp(explained);
        disp(explained2);
    end
    % calc stats for all grasps, one subject, both arms on one, color coded, 
    % calc stats for all grasps, one subject, one arm each, grasps color coded
    % RDMs for grasps for each arm. 
    
    % do this for all participants and visually inspect. 
    % calculate group averages. 
    %cat(1, arm0.graspname{:}, arm1.graspname{:})
end