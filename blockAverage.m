function downsampledImg = blockAverage(img, factor)
    % downsample image by the factor by averaging values within
    % neighborhoods of n by n blocks (where n = factor) to fill one pixel
    % in the downsampled image. Size of downsampled image should be 
    % w/factor, h/factor. 
    % fails if image height and width is not divisible by the factor.
    [h, w] = size(img);
    if mod(h, factor) ~= 0 || mod(w, factor) ~= 0
        error('Image size must be divisible by factor');
    end
    newW = w / factor;
    newH = h / factor;

    img = double(img); % convert to double for averaging
    img = reshape(img, factor, newW, factor, newH);
    downsampledImg = squeeze(mean(mean(img, 1), 3));
    downsampledImg = squeeze(downsampledImg);
end