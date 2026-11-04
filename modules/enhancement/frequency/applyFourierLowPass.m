
function output = applyFourierLowPass(img, cutoff)
    % Ideal Fourier low-pass filtering
    % cutoff: Radius in frequency pixels (e.g., 30)

    validateattributes(cutoff, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});

    img = im2double(img);
    [rows, cols, channels] = size(img);

    % Frequency coordinates centered at zero
    [X, Y] = meshgrid( ...
        -floor(cols/2):ceil(cols/2)-1, ...
        -floor(rows/2):ceil(rows/2)-1);

    D = sqrt(X.^2 + Y.^2);

    % Ideal low-pass mask
    H = double(D <= cutoff);

    output = zeros(size(img));

    for c = 1:channels
        F = fftshift(fft2(img(:,:,c)));
        G = F .* H;

        filtered = real(ifft2(ifftshift(G)));
        output(:,:,c) = filtered;
    end

    output = max(0, min(1, output));
end
