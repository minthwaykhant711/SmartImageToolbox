function output = resizeImage(img, scale, method)
    % Resize an image using nearest-neighbor, bilinear or bicubic interpolation.
    %   scale  - scalar zoom factor (e.g. 2 or 0.5), or [rows cols] target size
    %   method - 'nearest', 'bilinear' (default) or 'bicubic'

    if nargin < 3
        method = 'bilinear';
    end

    [h, w, ~] = size(img);
    if isscalar(scale)
        newH = max(1, round(h * scale));
        newW = max(1, round(w * scale));
    else
        newH = scale(1);
        newW = scale(2);
    end

    % Pixel-centre alignment: output pixel centres map back into the source grid
    [Xo, Yo] = meshgrid(1:newW, 1:newH);
    X = (Xo - 0.5) * (w / newW) + 0.5;
    Y = (Yo - 0.5) * (h / newH) + 0.5;

    output = interpolateImage(img, X, Y, method);
    output = castLike(output, img);
end
