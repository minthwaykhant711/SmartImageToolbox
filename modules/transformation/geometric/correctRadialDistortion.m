function output = correctRadialDistortion(img, k1, k2, method, mode)
    % Correct (or simulate) radial lens distortion with the polynomial model
    %   x_d = x_u * (1 + k1*r^2 + k2*r^4),   r = |x_u| (normalised)
    % where coordinates are measured from the image centre and normalised by the
    % half-diagonal, so r = 1 at the corners.
    %   k1, k2 - distortion coefficients of the lens. k1 < 0 is barrel
    %            distortion, k1 > 0 is pincushion distortion.
    %   method - 'nearest', 'bilinear' (default) or 'bicubic'
    %   mode   - 'correct' (default): undistort an image taken with that lens.
    %            'distort': apply the lens model to a clean image (useful for
    %            creating test images to correct).
    % Both modes use reverse mapping, so the output has no holes.

    if nargin < 3 || isempty(k2), k2 = 0; end
    if nargin < 4 || isempty(method), method = 'bilinear'; end
    if nargin < 5 || isempty(mode), mode = 'correct'; end

    [h, w, ~] = size(img);
    cx = (w + 1) / 2;
    cy = (h + 1) / 2;
    norm = hypot(w, h) / 2;

    [Xo, Yo] = meshgrid(1:w, 1:h);
    xn = (Xo - cx) / norm;
    yn = (Yo - cy) / norm;

    switch lower(mode)
        case 'correct'
            % Output pixel is undistorted; find where the lens imaged it
            r2 = xn.^2 + yn.^2;
            factor = 1 + k1 * r2 + k2 * r2.^2;
            xs = xn .* factor;
            ys = yn .* factor;

        case 'distort'
            % Output pixel is distorted; invert the model by fixed-point iteration
            xs = xn;
            ys = yn;
            for iter = 1:20
                r2 = xs.^2 + ys.^2;
                factor = 1 + k1 * r2 + k2 * r2.^2;
                factor(abs(factor) < 1e-6) = 1e-6;
                xs = xn ./ factor;
                ys = yn ./ factor;
            end
            % Strong barrel distortion folds back on itself near the corners, so
            % some output pixels have no source; leave those black
            r2 = xs.^2 + ys.^2;
            factor = 1 + k1 * r2 + k2 * r2.^2;
            unresolved = hypot(xs .* factor - xn, ys .* factor - yn) > 1e-4;
            xs(unresolved) = -Inf;
            ys(unresolved) = -Inf;

        otherwise
            error('correctRadialDistortion:mode', 'Unknown mode "%s".', mode);
    end

    Xs = xs * norm + cx;
    Ys = ys * norm + cy;
    output = castLike(interpolateImage(img, Xs, Ys, method), img);
end
