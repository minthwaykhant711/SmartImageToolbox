function output = affineTransform(img, A, method, mapping, outputView)
    % Apply a general affine transformation.
    %   A - 2x3 [a b tx; c d ty] or 3x3 matrix (last row must be [0 0 1]),
    %       mapping [x'; y'] = A(1:2,1:2) * [x; y] + A(1:2,3)

    if nargin < 3, method = 'bilinear'; end
    if nargin < 4, mapping = 'reverse'; end
    if nargin < 5, outputView = 'full'; end

    if isequal(size(A), [2 3])
        A = [A; 0 0 1];
    elseif ~isequal(size(A), [3 3]) || any(abs(A(3, :) - [0 0 1]) > 1e-12)
        error('affineTransform:matrix', 'A must be 2x3 or 3x3 with last row [0 0 1].');
    end
    if abs(det(A(1:2, 1:2))) < 1e-10
        error('affineTransform:singular', 'The affine matrix is singular.');
    end

    output = warpImage(img, A, method, mapping, outputView);
end
