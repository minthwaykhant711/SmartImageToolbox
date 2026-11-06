function output = shapeBasedSegmentation(mask, minArea, maxArea, shape)
% SHAPEBASEDSEGMENTATION Select connected regions by area and eccentricity.
    if nargin < 2, minArea = 20; end
    if nargin < 3, maxArea = Inf; end
    if nargin < 4, shape = 'All shapes'; end
    validateattributes(minArea, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'finite'});
    validateattributes(maxArea, {'numeric'}, {'scalar', '>=', minArea});
    components = bwconncomp(logical(mask), 8);
    stats = regionprops(components, 'Area', 'Eccentricity');
    output = false(size(mask));
    for index = 1:components.NumObjects
        keep = stats(index).Area >= minArea && stats(index).Area <= maxArea;
        switch shape
            case 'Round regions', keep = keep && stats(index).Eccentricity < 0.75;
            case 'Elongated regions', keep = keep && stats(index).Eccentricity >= 0.75;
            case 'All shapes'
            otherwise, error('shapeBasedSegmentation:Shape', 'Unknown shape selection.');
        end
        if keep, output(components.PixelIdxList{index}) = true; end
    end
end
