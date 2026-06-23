function croppedMovie = crop(imgs, centerX, centerY, sqImgLen)
    if mod(sqImgLen, 2) == 1
        error('cropped img length must be an even number');
    end
    [~, ~, numFrames] = size(imgs);
    % Preallocate cropped array
    croppedMovie = zeros(sqImgLen, sqImgLen, numFrames, class(imgs));

    halfSize = floor(sqImgLen/2);
    xmin= centerX - halfSize + 1;
    ymin = centerY - halfSize + 1;
    xmax = centerX + halfSize;
    ymax = centerY + halfSize;
    for i=1:numFrames
        croppedMovie(:, :, i) =  imgs(ymin:ymax, xmin:xmax, i);
    end
end