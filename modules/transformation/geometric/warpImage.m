function output = warpImage(img, T, method, mapping, outputView)
    % Warp an image with a 3x3 homogeneous transformation matrix.
    %   T          - 3x3 matrix mapping source to destination: [x'; y'; 1] = T * [x; y; 1]
    %                (x = column, y = row, 1-based pixel centres)
    %   method     - 'nearest', 'bilinear' (default) or 'bicubic'
    %   mapping    - 'reverse' (default): every output pixel is pulled from the
    %                source through inv(T) and interpolated, so there are no holes.
    %                'forward': every source pixel is pushed through T and splatted
    %                onto the output grid; magnification leaves visible holes.
    %                Forward mapping splats with 'nearest' (round) or bilinear
    %                weights ('bilinear' and 'bicubic').
    %   outputView - 'same' (default): output keeps the input size and frame.
    %                'full': output grows to contain the whole transformed image.

    if nargin < 3 || isempty(method)
        method = 'bilinear';
    end
    if nargin < 4 || isempty(mapping)
        mapping = 'reverse';
    end
    if nargin < 5 || isempty(outputView)
        outputView = 'same';
    end

    ImageWorkspace.validateImage(img);
    validateattributes(T, {'numeric'}, {'size', [3 3], 'real', 'finite'});
    if rcond(double(T)) < 1e-12
        error('warpImage:singular', 'The transformation matrix must be invertible.');
    end
    method = validatestring(method, {'nearest', 'bilinear', 'bicubic'});
    [h, w, c] = size(img);

    % Output frame: x0/y0 is the coordinate of output pixel (1,1)
    switch lower(outputView)
        case 'same'
            x0 = 1; y0 = 1;
            outW = w; outH = h;
        case 'full'
            corners = T * [0.5 w+0.5 w+0.5 0.5; 0.5 0.5 h+0.5 h+0.5; 1 1 1 1];
            corners = corners(1:2, :) ./ corners(3, :);
            xMin = min(corners(1, :)); xMax = max(corners(1, :));
            yMin = min(corners(2, :)); yMax = max(corners(2, :));
            outW = max(1, ceil(xMax - xMin - 1e-10));
            outH = max(1, ceil(yMax - yMin - 1e-10));
            x0 = xMin + 0.5; y0 = yMin + 0.5;
        otherwise
            error('warpImage:outputView', 'Unknown output view "%s".', outputView);
    end

    switch lower(mapping)
        case 'reverse'
            [Xo, Yo] = meshgrid(x0 + (0:outW-1), y0 + (0:outH-1));
            src = T \ [Xo(:)'; Yo(:)'; ones(1, numel(Xo))];
            Xs = reshape(src(1, :) ./ src(3, :), outH, outW);
            Ys = reshape(src(2, :) ./ src(3, :), outH, outW);
            output = interpolateImage(img, Xs, Ys, method);

        case 'forward'
            [Xs, Ys] = meshgrid(1:w, 1:h);
            dst = T * [Xs(:)'; Ys(:)'; ones(1, numel(Xs))];
            % Destination positions in output pixel indices
            xd = dst(1, :)' ./ dst(3, :)' - x0 + 1;
            yd = dst(2, :)' ./ dst(3, :)' - y0 + 1;
            output = forwardSplat(double(img), xd, yd, outH, outW, c, method);

        otherwise
            error('warpImage:mapping', 'Unknown mapping "%s".', mapping);
    end

    output = castLike(output, img);
end

function output = forwardSplat(img, xd, yd, outH, outW, c, method)
    % Push every source pixel into the output, accumulating weighted values
    if strcmpi(method, 'nearest')
        xs = round(xd); ys = round(yd);
        targets = {xs, ys, ones(size(xd))};
    else
        xf = floor(xd); yf = floor(yd);
        dx = xd - xf; dy = yd - yf;
        targets = {[xf; xf+1; xf; xf+1], [yf; yf; yf+1; yf+1], ...
                   [(1-dx).*(1-dy); dx.*(1-dy); (1-dx).*dy; dx.*dy]};
    end
    xt = targets{1}; yt = targets{2}; wt = targets{3};
    nTargets = numel(xt) / numel(xd);

    valid = xt >= 1 & xt <= outW & yt >= 1 & yt <= outH & wt > 0;
    idx = sub2ind([outH outW], yt(valid), xt(valid));
    weightSum = accumarray(idx, wt(valid), [outH * outW, 1]);

    output = zeros(outH, outW, c);
    for k = 1:c
        values = repmat(reshape(img(:, :, k), [], 1), nTargets, 1);
        acc = accumarray(idx, values(valid) .* wt(valid), [outH * outW, 1]);
        channel = zeros(outH * outW, 1);
        filled = weightSum > 0;
        channel(filled) = acc(filled) ./ weightSum(filled);
        output(:, :, k) = reshape(channel, outH, outW);
    end
end
