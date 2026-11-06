function [images, labels] = loadMNIST(datasetPath, split)
% LOADMNIST Read and validate uncompressed MNIST IDX image and label files.
    split = validatestring(split, {'train','test'});
    if strcmp(split, 'train'), prefix = 'train'; else, prefix = 't10k'; end
    [header, pixels] = readIDX(fullfile(datasetPath, [prefix '-images-idx3-ubyte']), 4, 2051);
    count = header(2); rows = header(3); columns = header(4);
    if rows ~= 28 || columns ~= 28 || count < 1 || numel(pixels) ~= count*rows*columns
        error('loadMNIST:Images', 'MNIST images must contain complete 28 x 28 records.');
    end
    images = permute(reshape(pixels, columns, rows, count), [2 1 3]);
    [labelHeader, values] = readIDX(fullfile(datasetPath, [prefix '-labels-idx1-ubyte']), 2, 2049);
    if labelHeader(2) ~= count || numel(values) ~= count || any(values > 9)
        error('loadMNIST:Labels', 'MNIST labels must match the image count and contain digits 0-9.');
    end
    labels = double(values);
end
function [header, values] = readIDX(filename, headerLength, magic)
    fid = fopen(filename, 'r', 'b');
    if fid == -1, error('loadMNIST:File', 'Cannot open %s. Provide uncompressed MNIST files.', filename); end
    cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
    header = fread(fid, headerLength, 'uint32=>double');
    if numel(header) ~= headerLength || header(1) ~= magic
        error('loadMNIST:Header', 'Invalid or incomplete IDX header: %s', filename);
    end
    values = fread(fid, Inf, 'uint8=>uint8');
end
