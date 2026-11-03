
function output = applyHistogramEqualization(img)
    % Apply histogram equalization to an image

    % Convert RGB image to grayscale
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Apply histogram equalization
    output = histeq(img);
end
