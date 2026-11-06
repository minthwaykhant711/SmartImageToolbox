function out = interpolateImage(img, X, Y, method, fillValue)
    % Sample an image at real-valued (x, y) coordinates.
    %   img       - grayscale or RGB image (any numeric class)
    %   X, Y      - matrices of column (x) and row (y) coordinates, 1-based
    %   method    - 'nearest', 'bilinear' or 'bicubic'
    %   fillValue - value for samples outside the image (default 0)
    % Output has size(X) x channels and is of class double.

    if nargin < 4 || isempty(method)
        method = 'bilinear';
    end
    if nargin < 5
        fillValue = 0;
    end

    ImageWorkspace.validateImage(img);
    if ~isequal(size(X), size(Y))
        error('interpolateImage:coordinates', 'X and Y must have the same dimensions.');
    end
    img = double(img);
    [h, w, c] = size(img);
    outSize = size(X);
    X = X(:);
    Y = Y(:);
    out = zeros(numel(X), c);

    % Samples falling outside the image are filled, the rest are interpolated
    inside = X >= 0.5 & X <= w + 0.5 & Y >= 0.5 & Y <= h + 0.5;
    X(~inside) = 1;
    Y(~inside) = 1;

    switch lower(method)
        case 'nearest'
            xi = min(max(round(X), 1), w);
            yi = min(max(round(Y), 1), h);
            idx = sub2ind([h w], yi, xi);
            for k = 1:c
                channel = img(:, :, k);
                out(:, k) = channel(idx);
            end

        case 'bilinear'
            x0 = floor(X);
            y0 = floor(Y);
            dx = X - x0;
            dy = Y - y0;
            for k = 1:c
                channel = img(:, :, k);
                p00 = pixelAt(channel, x0,     y0);
                p10 = pixelAt(channel, x0 + 1, y0);
                p01 = pixelAt(channel, x0,     y0 + 1);
                p11 = pixelAt(channel, x0 + 1, y0 + 1);
                out(:, k) = (1 - dx) .* (1 - dy) .* p00 + dx .* (1 - dy) .* p10 + ...
                            (1 - dx) .* dy .* p01 + dx .* dy .* p11;
            end

        case 'bicubic'
            % Keys cubic convolution over a 4x4 neighbourhood
            x0 = floor(X);
            y0 = floor(Y);
            dx = X - x0;
            dy = Y - y0;
            for k = 1:c
                channel = img(:, :, k);
                acc = zeros(numel(X), 1);
                for m = -1:2
                    wy = cubicKernel(m - dy);
                    for n = -1:2
                        wx = cubicKernel(n - dx);
                        acc = acc + wx .* wy .* pixelAt(channel, x0 + n, y0 + m);
                    end
                end
                out(:, k) = acc;
            end

        otherwise
            error('interpolateImage:method', 'Unknown interpolation method "%s".', method);
    end

    out(~inside, :) = fillValue;
    out = reshape(out, [outSize c]);
end

function v = pixelAt(channel, x, y)
    % Read pixels with edge replication so neighbourhoods near the border are valid
    [h, w] = size(channel);
    x = min(max(x, 1), w);
    y = min(max(y, 1), h);
    v = channel(sub2ind([h w], y, x));
end

function wgt = cubicKernel(t)
    % Keys (1981) cubic convolution kernel with a = -0.5
    a = -0.5;
    t = abs(t);
    wgt = zeros(size(t));
    near = t <= 1;
    far = t > 1 & t < 2;
    wgt(near) = (a + 2) * t(near).^3 - (a + 3) * t(near).^2 + 1;
    wgt(far) = a * t(far).^3 - 5 * a * t(far).^2 + 8 * a * t(far) - 4 * a;
end
