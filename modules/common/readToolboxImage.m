function image = readToolboxImage(filename)
% READTOOLBOXIMAGE Read RGB, grayscale, indexed, and transparent image files.
    [image, map, alpha] = imread(filename);
    if ~isempty(map), image = ind2rgb(image, map); end
    if ~isempty(alpha)
        opacity = im2double(alpha);
        image = im2double(image) .* opacity + (1 - opacity);
    end
    ImageWorkspace.validateImage(image);
end
