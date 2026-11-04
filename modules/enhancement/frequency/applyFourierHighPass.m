
function output = applyFourierHighPass(img, cutoff)
    % Ideal Fourier high-pass filtering
    % cutoff: Radius in frequency pixels

    validateattributes(cutoff, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});

    img = im2double(img);
    [rows, cols, channels] = size(img);

    [X, Y] = meshgrid( ...
        -floor(cols/2):ceil(cols/2)-1, ...
        -floor(rows/2):ceil(rows/2)-1);

    D = sqrt(X.^2 + Y.^2);

    % Ideal high-pass mask
    H = double(D > cutoff);

    output = zeros(size(img));

    for c = 1:channels
        F = fftshift(fft2(img(:,:,c)));
        G = F .* H;

        filtered = real(ifft2(ifftshift(G)));

        % High-pass results can contain negative values.
        % Normalize for visualization.
        output(:,:,c) = mat2gray(filtered);
    end
end
