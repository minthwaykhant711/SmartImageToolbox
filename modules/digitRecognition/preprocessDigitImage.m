function [features, processedImage, info] = preprocessDigitImage(img, options)
% PREPROCESSDIGITIMAGE Isolate one digit and normalize to a centered 28x28 image.
% StrokeRadius is optional; the default preserves the original stroke width.
    arguments
        img
        options.StrokeRadius (1,1) double {mustBeInteger,mustBeNonnegative,mustBeLessThanOrEqual(options.StrokeRadius,2)} = 0
        options.Interpolation (1,:) char = 'bilinear'
    end
    ImageWorkspace.validateImage(img);
    gray = im2single(img);
    if size(gray, 3) == 3, gray = rgb2gray(gray); end
    if min(gray(:)) < 0 || max(gray(:)) > 1
        error('preprocessDigitImage:Range', 'Floating-point images must have intensities between zero and one.');
    end
    if max(gray(:)) - min(gray(:)) < 0.02
        error('preprocessDigitImage:NoDigit', 'No digit detected. The image has too little contrast.');
    end
    border = [gray(1,:), gray(end,:), gray(:,1)', gray(:,end)'];
    inverted = median(border) > 0.5;
    if inverted, gray = 1 - gray; border = 1 - border; end
    originalGray = gray;
    gray = max(0, gray - median(border));
    peak = max(gray(:));
    if peak <= 0, error('preprocessDigitImage:NoDigit', 'No handwritten digit detected.'); end
    gray = gray / peak;
    mask = gray > max(graythresh(gray), 0.08);
    mask = bwareaopen(mask, max(3, round(numel(mask) * 0.0005)), 8);
    components = bwconncomp(mask, 8);
    if components.NumObjects == 0
        error('preprocessDigitImage:NoDigit', 'No handwritten digit detected. Crop closer to one digit.');
    end
    stats = regionprops(components, 'Area', 'BoundingBox');
    [largest, primary] = max([stats.Area]);
    box = stats(primary).BoundingBox;
    margin = max(box(3:4)) * 0.3;
    clean = false(size(mask));
    for index = 1:components.NumObjects
        other = stats(index).BoundingBox;
        near = other(1) <= box(1)+box(3)+margin && other(1)+other(3) >= box(1)-margin && ...
            other(2) <= box(2)+box(4)+margin && other(2)+other(4) >= box(2)-margin;
        if index ~= primary && ~near && stats(index).Area >= 0.4 * largest
            error('preprocessDigitImage:MultipleDigits', 'Several foreground objects were found. Crop the image to one digit.');
        end
        if near && stats(index).Area >= max(3, 0.03 * largest)
            clean(components.PixelIdxList{index}) = true;
        end
    end
    [rows, cols] = find(clean);
    % MNIST is already scaled and centered. Avoid interpolation and shifts
    % when the uploaded image already has that geometry and a dark border.
    if isequal(size(gray), [28 28]) && options.StrokeRadius == 0
        mass = sum(originalGray(:));
        cx = sum(sum(originalGray,1).*(1:28))/mass;
        cy = sum(sum(originalGray,2).*(1:28)')/mass;
        extent = max(max(rows)-min(rows)+1, max(cols)-min(cols)+1);
        if max(border) < 0.1 && extent >= 16 && extent <= 22 && ...
                abs(cx-14.5) <= 1 && abs(cy-14.5) <= 1
            processedImage = originalGray;
            features = reshape(processedImage, 1, 784);
            info = struct('Inverted', inverted, 'ForegroundMask', clean, ...
                'BoundingBox', [min(cols), min(rows), max(cols)-min(cols)+1, max(rows)-min(rows)+1], ...
                'StrokeRadius', 0, 'Shift', [0 0], 'PreservedCanonical', true);
            return;
        end
    end
    gray(~imdilate(clean, strel('disk', 1, 0))) = 0;
    cropped = gray(min(rows):max(rows), min(cols):max(cols));
    factor = 20 / max(size(cropped));
    targetSize = max(1, round(size(cropped) * factor));
    resized = resizeImage(cropped, targetSize, options.Interpolation);
    resized = max(0, min(1, resized));
    if options.StrokeRadius > 0
        resized = imdilate(resized, strel('disk', options.StrokeRadius, 0));
    end
    processedImage = zeros(28, 28, 'single');
    first = floor((28 - targetSize) / 2) + 1;
    processedImage(first(1):first(1)+targetSize(1)-1, first(2):first(2)+targetSize(2)-1) = resized;
    mass = sum(processedImage(:));
    cx = sum(sum(processedImage, 1) .* (1:28)) / mass;
    cy = sum(sum(processedImage, 2) .* (1:28)') / mass;
    [activeRows, activeCols] = find(processedImage > 0);
    dx = min(28-max(activeCols), max(1-min(activeCols), round(14.5-cx)));
    dy = min(28-max(activeRows), max(1-min(activeRows), round(14.5-cy)));
    processedImage = translateImage(processedImage, dx, dy, 'nearest', 'reverse');
    features = reshape(processedImage, 1, 784);
    info = struct('Inverted', inverted, 'ForegroundMask', clean, ...
        'BoundingBox', [min(cols), min(rows), max(cols)-min(cols)+1, max(rows)-min(rows)+1], ...
        'StrokeRadius', options.StrokeRadius, 'Shift', [dx dy], 'PreservedCanonical', false);
end
