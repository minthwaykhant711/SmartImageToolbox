
function output = adjustBrightness(img, adjustment)
    % Adjust image brightness
    %
    % img        : Input image
    % adjustment : Brightness adjustment (-1 to 1)
    %
    % Positive values increase brightness
    % Negative values decrease brightness

    imgDouble = im2double(img);

    output = imgDouble + adjustment;

    % Keep pixel intensities within valid range
    output = max(0, min(1, output));
end
