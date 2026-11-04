function output = scaleImage(img, sx, sy, method, mapping)
    % Scale (zoom) an image by sx horizontally and sy vertically.
    % The output canvas grows or shrinks to fit the scaled image.

    if nargin < 3 || isempty(sy), sy = sx; end
    if nargin < 4, method = 'bilinear'; end
    if nargin < 5, mapping = 'reverse'; end

    if sx <= 0 || sy <= 0
        error('scaleImage:factor', 'Scale factors must be positive.');
    end

    T = [sx 0  0;
         0  sy 0;
         0  0  1];
    output = warpImage(img, T, method, mapping, 'full');
end
