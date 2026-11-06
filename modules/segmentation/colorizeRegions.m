function image = colorizeRegions(labels)
% COLORIZEREGIONS Display any number of watershed regions with stable colors.
    validateattributes(labels, {'numeric'}, {'2d','real','finite','nonnegative','integer'});
    count = max(1, double(max(labels(:))));
    hue = mod((0:count-1)' * 0.61803398875, 1);
    colors = hsv2rgb([hue, ones(count,1)*0.65, ones(count,1)*0.95]);
    image = label2rgb(labels, colors, 'k', 'noshuffle');
end
