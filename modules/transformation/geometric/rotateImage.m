function output = rotateImage(img, angleDeg, method, mapping, outputView)
    % Rotate an image counter-clockwise by angleDeg about its centre.
    %   outputView - 'full' (default) enlarges the canvas so nothing is cut off,
    %                'same' keeps the input size and crops the corners.

    if nargin < 3, method = 'bilinear'; end
    if nargin < 4, mapping = 'reverse'; end
    if nargin < 5, outputView = 'full'; end

    [h, w, ~] = size(img);
    cx = (w + 1) / 2;
    cy = (h + 1) / 2;

    % Rows grow downwards, so a visually counter-clockwise turn uses -theta
    theta = -deg2rad(angleDeg);
    R = [cos(theta) -sin(theta) 0;
         sin(theta)  cos(theta) 0;
         0           0          1];
    toOrigin = [1 0 -cx; 0 1 -cy; 0 0 1];
    back = [1 0 cx; 0 1 cy; 0 0 1];

    output = warpImage(img, back * R * toOrigin, method, mapping, outputView);
end
