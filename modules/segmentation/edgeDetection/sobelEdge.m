function output = sobelEdge(inputImage)
    % SOBELEDGE Detect edges using the Sobel operator.
    %
    % Input:
    %   inputImage - RGB or grayscale image
    %
    % Output:
    %   output - Binary image containing detected edges

    % Step 1: Convert RGB image to grayscale
    if size(inputImage, 3) == 3
        grayImage = rgb2gray(inputImage);
    else
        grayImage = inputImage;
    end

    % Step 2: Apply Sobel edge detection
    output = edge(grayImage, 'sobel');

end