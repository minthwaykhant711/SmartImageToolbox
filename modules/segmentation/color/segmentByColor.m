function mask = segmentByColor(image, colorSpace, lowerBounds, upperBounds)
% SEGMENTBYCOLOR Select RGB/HSV color ranges; HSV hue can wrap through zero.
    ImageWorkspace.validateImage(image);
    if size(image, 3) ~= 3
        error('segmentByColor:RGBRequired', 'Upload an RGB image for color segmentation.');
    end
    validateattributes(lowerBounds, {'numeric'}, {'vector', 'numel', 3, '>=', 0, '<=', 1, 'finite'});
    validateattributes(upperBounds, {'numeric'}, {'vector', 'numel', 3, '>=', 0, '<=', 1, 'finite'});
    values = im2double(image);
    isHSV = strcmpi(colorSpace, 'HSV');
    if isHSV, values = rgb2hsv(values);
    elseif ~strcmpi(colorSpace, 'RGB'), error('segmentByColor:Space', 'Choose RGB or HSV.'); end
    mask = true(size(image, 1), size(image, 2));
    for channel = 1:3
        plane = values(:, :, channel);
        if isHSV && channel == 1 && lowerBounds(channel) > upperBounds(channel)
            selected = plane >= lowerBounds(channel) | plane <= upperBounds(channel);
        else
            if lowerBounds(channel) > upperBounds(channel)
                error('segmentByColor:Range', 'Each lower bound must be at most its upper bound (except HSV hue wrapping).');
            end
            selected = plane >= lowerBounds(channel) & plane <= upperBounds(channel);
        end
        mask = mask & selected;
    end
end
