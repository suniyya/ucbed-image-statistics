function [coords, diff_image] = calculate_statistics(grasp_mvt, avg_by, sqImgLen, image_type, show)
    % Input:
    % @grasp_mvt: a movie - dim m x n x 80 frames
    % @avg_by: the block averaging factor (int)
    % crop then take a difference image by
    % taking average of first few and last few frames and subtracting 
    % downsample by block averaging
    % then binarize (mean-binarize)
    % Output: 10-dimensional texture statistics -> can ignore first dim as

    centerX = 512;
    centerY = 512;
    frameRate = 20; % change if nFrames is NOT 80, with 20fps
    start_window = 0.5; % in seconds
    end_window = 1; % in seconds

    % crop the image to zoom into the center, for max motion without noise
    grasp_mvt = crop(grasp_mvt, centerX, centerY, sqImgLen);

    last_nonzero = nFrames;
    for k = nFrames:-1:1
        if any(grasp_mvt(:,:,k), 'all')
            last_nonzero = k;
            break
        end
    end

    end_idx = max(last_nonzero - end_window*frameRate, 1);
    endPos = mean( ...
        grasp_mvt(:, :, end_idx:last_nonzero), 3 ...
        );
    if image_type == "diff_image"
        % take the difference between the mean start and end states
        startPos = mean(grasp_mvt(:, :, 1:start_window*frameRate), 3);
        image = endPos - startPos;
    else
        image = endPos;
    end
    % downsample image
    image = blockAverage(image, avg_by);
    % mean binarize to turn to black and white
    image = image < mean(image(:));
    if show
        imshow(image);
        axis('square');
        colormap('gray');
    end
    counts=btc_map2counts(image);
    corrs=getcorrs_p2x2(counts/sum(counts(:)));
    coords=btc_corrs2vec(corrs);
end