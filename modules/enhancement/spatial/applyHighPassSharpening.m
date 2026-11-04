
function output = applyHighPassSharpening(img, strength)
    % High-pass sharpening using unsharp masking
    % strength: 0 = unchanged, 1 = normal sharpening

    if nargin < 2
        strength = 1;
    end

    validateattributes(strength, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnegative'});

    imgDouble = im2double(img);

    % Low-pass component
    blurred = imgaussfilt(imgDouble, 1);

    % High-frequency component
    highPass = imgDouble - blurred;

    % Add high-frequency details back
    output = imgDouble + strength * highPass;

    output = max(0, min(1, output));
end
