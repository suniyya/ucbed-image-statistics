function [image_stats, graspname, limb] = grasps_to_image_stats(path_to_ss, grasp, arm, avg_by, sqImgLen, image_type)
    % Computes image statistics for all repeats of a given grasp for an arm 
    %   Detailed explanation goes here
    % read all files for a given grasp and arm. 
    % grasp - power, pinch, iflex etc
    % arm - 0 for .mat files, 1 for US2 files
    % if US2 <- unaffecteddataMatrixUS2
    % if .mat <- affected
    % return image_stats 10 by m matrix, 10 stats, m grasp movies
    path_to_grasps = sprintf('%s/%s', path_to_ss, grasp{1});
    fileList = dir(path_to_grasps);
    if arm == 0
        limb = 0;
        arm = '';
    else
        if arm == 1
            limb= 1;
            arm = 'US2';
        else
            error('Invalid value for arm');
        end
    end
    % Define the regular expression pattern
    pattern = ['^', grasp{1}, '\d+', arm, '\.mat$'];
    % Initialize an empty cell array to store matching filenames
    matchingFiles = {};
    mvts = {};
   
    % Loop through the file list and match the pattern
    for i = 1:length(fileList)
        filename = fileList(i).name;
        if ~fileList(i).isdir && ~isempty(regexpi(filename, pattern))
            matchingFiles{end+1} = filename; 
            data = load(strcat(path_to_grasps, '/',filename));
            mvts{end+1} = data;
        end
    end
    % for selected files, calculate image statistics 
    % read files from (strcat('./', grasp)) dir
    n_files = length(matchingFiles);
    image_stats = zeros(n_files, 10);
    nc = 6;
    nr = ceil(n_files/nc);
    for i=1:n_files
        grasp_mvt = mvts(i);
        data = strcat('dataMatrix', arm);
        [x, y, t] = size(grasp_mvt{1}.(data));
        [coords, diff_img] = calculate_statistics(grasp_mvt{1}.(data), avg_by, sqImgLen, image_type);
        image_stats(i, :) = coords;
    end
    graspname = repmat(grasp, n_files, 1);
    limb = repmat(limb, n_files, 1);

end