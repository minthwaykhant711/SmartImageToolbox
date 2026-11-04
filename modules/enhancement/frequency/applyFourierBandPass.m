
function output = applyFourierBandPass(img, lowCutoff, highCutoff)
    % Ideal Fourier band-pass filtering
    % Keep frequencies between two radii

    validateattributes(lowCutoff, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnegative'});

    validateattributes(highCutoff, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});

    if lowCutoff >= highCutoff
        error('lowCutoff must be smaller than highCutoff.');
    end

    img = im2double(img);
    [rows, cols, channels] = size(img);

    [X, Y] = meshgrid( ...
        -floor(cols/2):ceil(cols/2)-1, ...
        -floor(rows/2):ceil(rows/2)-1);

    D = sqrt(X.^2 + Y.^2);

    % Band-pass mask
    H = double(D >= lowCutoff & D <= highCutoff);

    output = zeros(size(img));

    for c = 1:channels
        F = fftshift(fft2(img(:,:,c)));
        G = F .* H;

        filtered = real(ifft2(ifftshift(G)));
        output(:,:,c) = mat2gray(filtered);
    end
end
