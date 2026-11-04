
function [images, labels] = loadMNIST(datasetPath, split)
% LOADMNIST Load handwritten digit images and labels.
%
% images: 28 x 28 x N array of grayscale images
% labels: N x 1 numeric array containing digits 0-9

    if strcmpi(split, 'train')
        imageFile = 'train-images-idx3-ubyte';
        labelFile = 'train-labels-idx1-ubyte';
    elseif strcmpi(split, 'test')
        imageFile = 't10k-images-idx3-ubyte';
        labelFile = 't10k-labels-idx1-ubyte';
    else
        error('Split must be train or test.');
    end

    % Read images
    fid = fopen(fullfile(datasetPath, imageFile), 'r', 'b');
    if fid == -1
        error('Cannot open MNIST image file.');
    end

    imageMagic = fread(fid, 1, 'int32');
    numImages = fread(fid, 1, 'int32');
    numRows = fread(fid, 1, 'int32');
    numCols = fread(fid, 1, 'int32');

    if imageMagic ~= 2051
        fclose(fid);
        error('Invalid MNIST image file.');
    end

    rawImages = fread(fid, numRows*numCols*numImages, 'uint8=>uint8');
    fclose(fid);

    if numel(rawImages) ~= numRows*numCols*numImages
        error('MNIST image file is incomplete.');
    end

    images = reshape(rawImages, numCols, numRows, numImages);
    images = permute(images, [2 1 3]);

    % Read labels
    fid = fopen(fullfile(datasetPath, labelFile), 'r', 'b');
    if fid == -1
        error('Cannot open MNIST label file.');
    end

    labelMagic = fread(fid, 1, 'int32');
    numLabels = fread(fid, 1, 'int32');

    if labelMagic ~= 2049
        fclose(fid);
        error('Invalid MNIST label file.');
    end

    labels = fread(fid, numLabels, 'uint8=>double');
    fclose(fid);

    if numel(labels) ~= numImages
        error('Number of images and labels does not match.');
    end
end
