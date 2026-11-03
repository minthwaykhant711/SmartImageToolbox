function output = translateImage(img, tx, ty, method, mapping)
    % Shift an image by tx pixels right and ty pixels down (sub-pixel allowed).
    % The output keeps the input size; uncovered areas are filled with black.

    if nargin < 4, method = 'bilinear'; end
    if nargin < 5, mapping = 'reverse'; end

    T = [1 0 tx;
         0 1 ty;
         0 0 1];
    output = warpImage(img, T, method, mapping, 'same');
end
