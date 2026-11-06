function [registered, T, info] = registerImages(fixed, moving, method)
    % Align a moving image to a fixed image.
    %   method - 'features' (default): Harris corners + patch matching + RANSAC,
    %            estimating a full affine transform.
    %            'mutualinfo': rigid + scale transform found by maximising mutual
    %            information, which also works across different modalities or
    %            brightness levels.
    % Returns the moving image warped into the fixed image's frame, the 3x3
    % matrix T mapping moving coordinates to fixed coordinates, and an info
    % struct with method-specific details.

    if nargin < 3 || isempty(method)
        method = 'features';
    end

    fixedGray = toGrayDouble(fixed);
    movingGray = toGrayDouble(moving);

    switch lower(method)
        case 'features'
            [T, info] = registerByFeatures(fixedGray, movingGray);
        case 'mutualinfo'
            [T, info] = registerByMutualInformation(fixedGray, movingGray);
        otherwise
            error('registerImages:method', 'Unknown registration method "%s".', method);
    end

    registered = warpToFrame(moving, T, size(fixed, 1), size(fixed, 2));
    info.overlapMask = warpToFrame(true(size(moving, 1), size(moving, 2)), ...
        T, size(fixed, 1), size(fixed, 2));
end

function gray = toGrayDouble(img)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    gray = im2double(img);
end

function output = warpToFrame(img, T, outH, outW)
    % Reverse-map the moving image onto the fixed image's pixel grid
    [Xo, Yo] = meshgrid(1:outW, 1:outH);
    src = T \ [Xo(:)'; Yo(:)'; ones(1, numel(Xo))];
    Xs = reshape(src(1, :), outH, outW);
    Ys = reshape(src(2, :), outH, outW);
    output = castLike(interpolateImage(img, Xs, Ys, 'bilinear'), img);
end

%% Feature-based registration

function [T, info] = registerByFeatures(fixedGray, movingGray)
    [ptsF, descF] = harrisFeatures(fixedGray);
    [ptsM, descM] = harrisFeatures(movingGray);
    if size(ptsF, 1) < 3 || size(ptsM, 1) < 3
        error('registerImages:features', 'Not enough corners found to register the images.');
    end

    % Normalised cross-correlation between all descriptor pairs
    scores = descM * descF';
    [best, bestF] = max(scores, [], 2);
    [~, bestM] = max(scores, [], 1);

    % Keep mutual best matches with a clear margin over the second best
    sorted = sort(scores, 2, 'descend');
    secondBest = sorted(:, min(2, size(sorted, 2)));
    mutual = bestM(bestF)' == (1:size(ptsM, 1))';
    keep = mutual & best > 0.7 & (1 - best) < 0.8 * (1 - secondBest);
    matchedM = ptsM(keep, :);
    matchedF = ptsF(bestF(keep), :);

    if size(matchedM, 1) < 3
        error('registerImages:features', ...
              'Only %d reliable matches found; need at least 3.', size(matchedM, 1));
    end

    [T, inliers] = ransacAffine(matchedM, matchedF, 3, 2000);

    info.method = 'features';
    info.fixedPoints = matchedF;
    info.movingPoints = matchedM;
    info.inliers = inliers;
    info.summary = sprintf('%d corners / %d corners, %d matches, %d RANSAC inliers', ...
        size(ptsF, 1), size(ptsM, 1), size(matchedM, 1), nnz(inliers));
end

function [pts, desc] = harrisFeatures(img)
    % Harris corner detector with non-maximum suppression and normalised
    % patch descriptors (Gaussian-smoothed, zero mean, unit norm)
    maxCorners = 400;
    halfPatch = 7;

    gx = imfilter(img, [-1 0 1], 'replicate');
    gy = imfilter(img, [-1; 0; 1], 'replicate');
    g = fspecial('gaussian', 9, 1.5);
    Ixx = imfilter(gx.^2, g, 'replicate');
    Iyy = imfilter(gy.^2, g, 'replicate');
    Ixy = imfilter(gx .* gy, g, 'replicate');
    response = Ixx .* Iyy - Ixy.^2 - 0.04 * (Ixx + Iyy).^2;

    % Local maxima above a relative threshold, far enough from the border for
    % a rotated patch to fit
    border = ceil(halfPatch * sqrt(2)) + 2;
    isPeak = response == imdilate(response, strel('square', 7)) & ...
             response > 0.01 * max(response(:));
    isPeak([1:border, end-border+1:end], :) = false;
    isPeak(:, [1:border, end-border+1:end]) = false;

    [rows, cols] = find(isPeak);
    strength = response(isPeak);
    [~, order] = sort(strength, 'descend');
    order = order(1:min(maxCorners, numel(order)));
    rows = rows(order);
    cols = cols(order);
    pts = [cols rows];

    % Rotation invariance: sample each circular patch in a frame aligned with
    % the corner's dominant gradient orientation
    smooth = imfilter(img, fspecial('gaussian', 5, 1), 'replicate');
    angles = dominantOrientation(smooth, rows, cols, halfPatch);
    [dc, dr] = meshgrid(-halfPatch:halfPatch);
    inCircle = hypot(dc(:), dr(:)) <= halfPatch;
    dc = dc(inCircle)';
    dr = dr(inCircle)';
    ca = cos(angles);
    sa = sin(angles);
    X = cols + ca .* dc - sa .* dr;
    Y = rows + sa .* dc + ca .* dr;
    desc = interpolateImage(smooth, X, Y, 'bilinear');
    desc = desc - mean(desc, 2);
    desc = desc ./ max(vecnorm(desc, 2, 2), eps);
end

function angles = dominantOrientation(img, rows, cols, radius)
    % Peak of a magnitude-weighted, Gaussian-windowed gradient orientation histogram
    bins = 36;
    gx = imfilter(img, [-1 0 1], 'replicate');
    gy = imfilter(img, [-1; 0; 1], 'replicate');
    magnitude = hypot(gx, gy);
    direction = atan2(gy, gx);

    [dc, dr] = meshgrid(-radius:radius);
    inCircle = hypot(dc(:), dr(:)) <= radius;
    dc = dc(inCircle)';
    dr = dr(inCircle)';
    window = exp(-(dc.^2 + dr.^2) / (2 * (radius / 2)^2));

    idx = sub2ind(size(img), rows + dr, cols + dc);
    weights = magnitude(idx) .* window;
    binOf = mod(floor((direction(idx) + pi) / (2 * pi) * bins), bins) + 1;

    angles = zeros(numel(rows), 1);
    for i = 1:numel(rows)
        hist = accumarray(binOf(i, :)', weights(i, :)', [bins 1]);
        hist = conv([hist(end); hist; hist(1)], [1; 2; 1] / 4, 'valid');   % circular smoothing
        [~, peak] = max(hist);
        angles(i) = (peak - 0.5) / bins * 2 * pi - pi;
    end
end

function [T, inliers] = ransacAffine(src, dst, threshold, iterations)
    % Robustly fit dst = A * src (affine) with RANSAC, then refine on inliers
    n = size(src, 1);
    bestInliers = false(n, 1);
    srcH = [src ones(n, 1)];

    for iter = 1:iterations
        sample = randperm(n, 3);
        if abs(det(srcH(sample, :))) < 1e-6
            continue;   % collinear sample
        end
        M = srcH(sample, :) \ dst(sample, :);
        residual = sqrt(sum((srcH * M - dst).^2, 2));
        current = residual < threshold;
        if nnz(current) > nnz(bestInliers)
            bestInliers = current;
        end
    end

    if nnz(bestInliers) < 6
        error('registerImages:ransac', ['RANSAC found only %d consistent matches. Feature ' ...
            'matching handles rotation and moderate scaling (about 0.8x - 1.25x); try ' ...
            'mutual information or a milder transformation.'], nnz(bestInliers));
    end

    M = srcH(bestInliers, :) \ dst(bestInliers, :);
    T = [M'; 0 0 1];
    inliers = bestInliers;
end

%% Mutual-information registration

function [T, info] = registerByMutualInformation(fixedGray, movingGray)
    % Parameters p = [tx ty angleDeg logScale] about the moving image centre,
    % optimised coarse-to-fine on an image pyramid
    levels = [4 2 1];
    p = [0 0 0 0];
    opts = optimset('Display', 'off', 'MaxIter', 200, 'TolX', 1e-3, 'TolFun', 1e-5);

    for level = levels
        f = imresize(fixedGray, 1 / level);
        m = imresize(movingGray, 1 / level);
        cost = @(q) -mutualInformation(f, m, paramsToMatrix(q, size(m), level));

        if level == levels(1)
            % Coarse grid search over rotation and translation to avoid local optima
            bestCost = inf;
            shifts = -0.2:0.05:0.2;
            for angle = -45:5:45
                for sx = shifts * size(movingGray, 2)
                    for sy = shifts * size(movingGray, 1)
                        c = cost([sx sy angle 0]);
                        if c < bestCost
                            bestCost = c;
                            p = [sx sy angle 0];
                        end
                    end
                end
            end
        end

        % fminsearch starts with 5% steps around q = 1, so optimise a rescaled
        % offset to give every parameter a sensible initial step at this level
        step = [2 * level, 2 * level, 2, 0.02] / 0.05;
        base = p;
        toParams = @(q) base + step .* (q - 1);
        q = fminsearch(@(q) cost(toParams(q)), ones(1, 4), opts);
        p = toParams(q);
    end

    T = paramsToMatrix(p, size(movingGray), 1);
    info.method = 'mutualinfo';
    info.parameters = p;
    info.mutualInformation = mutualInformation(fixedGray, movingGray, T);
    info.summary = sprintf('tx = %.1f px, ty = %.1f px, rotation = %.2f deg, scale = %.3f, MI = %.3f', ...
        p(1), p(2), p(3), exp(p(4)), info.mutualInformation);
end

function T = paramsToMatrix(p, movingSize, level)
    % Translation is stored in full-resolution pixels and scaled per level
    cx = (movingSize(2) + 1) / 2;
    cy = (movingSize(1) + 1) / 2;
    theta = -deg2rad(p(3));
    s = exp(p(4));
    R = [s*cos(theta) -s*sin(theta) 0; s*sin(theta) s*cos(theta) 0; 0 0 1];
    T = [1 0 cx + p(1)/level; 0 1 cy + p(2)/level; 0 0 1] * R * [1 0 -cx; 0 1 -cy; 0 0 1];
end

function mi = mutualInformation(fixedGray, movingGray, T)
    % Mutual information over the region where the warped moving image overlaps
    bins = 32;
    [h, w] = size(fixedGray);
    [Xo, Yo] = meshgrid(1:w, 1:h);
    src = T \ [Xo(:)'; Yo(:)'; ones(1, numel(Xo))];
    Xs = reshape(src(1, :), h, w);
    Ys = reshape(src(2, :), h, w);

    [mh, mw] = size(movingGray);
    overlap = Xs >= 1 & Xs <= mw & Ys >= 1 & Ys <= mh;
    if nnz(overlap) < 0.1 * numel(overlap)
        mi = 0;   % too little overlap to be meaningful
        return;
    end

    warped = interpolateImage(movingGray, Xs, Ys, 'bilinear');
    a = binIndex(fixedGray(overlap), bins);
    b = binIndex(warped(overlap), bins);

    joint = accumarray([a b], 1, [bins bins]) / nnz(overlap);
    pa = sum(joint, 2);
    pb = sum(joint, 1);
    nz = joint > 0;
    outer = pa * pb;
    mi = sum(joint(nz) .* log(joint(nz) ./ outer(nz)));
end

function idx = binIndex(values, bins)
    % Intensities may overshoot [0, 1] after resampling, so clamp the bins
    idx = min(max(floor(values * bins), 0), bins - 1) + 1;
end
