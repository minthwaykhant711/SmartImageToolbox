
function output = adjustContrast(img, factor)
    % Adjust image contrast
    %
    % img    : Input grayscale or RGB image
    % factor : Contrast multiplier
    %          1 = unchanged
    %          >1 = higher contrast
    %          0 to 1 = lower contrast

    % Convert image to double precision [0,1]
    imgDouble = im2double(img);

    % Adjust contrast around midpoint intensity
    output = (imgDouble - 0.5) * factor + 0.5;

    % Clip values to valid image intensity range
    output = max(0, min(1, output));
end
