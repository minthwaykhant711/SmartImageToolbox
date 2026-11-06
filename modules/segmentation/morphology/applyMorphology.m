function output = applyMorphology(mask, operation, radius)
% APPLYMORPHOLOGY Refine a binary foreground mask with a disk element.
    if nargin < 3, radius = 2; end
    validateattributes(mask, {'numeric', 'logical'}, {'2d', 'nonempty', 'real', 'finite'});
    validateattributes(radius, {'numeric'}, {'scalar', 'integer', 'nonnegative', '<=', 50});
    mask = logical(mask);
    element = strel('disk', radius, 0);
    switch lower(operation)
        case 'dilation', output = imdilate(mask, element);
        case 'erosion', output = imerode(mask, element);
        case 'opening', output = imopen(mask, element);
        case 'closing', output = imclose(mask, element);
        otherwise, error('applyMorphology:Operation', 'Unknown morphological operation.');
    end
end
