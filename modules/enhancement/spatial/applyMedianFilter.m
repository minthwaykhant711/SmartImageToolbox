
function output = applyMedianFilter(img, kernelSize)
    % Apply median filtering for noise reduction
    %
    % img        : Input grayscale or RGB image
    % kernelSize : Neighborhood size (e.g., 3, 5, 7)

    if size(img, 3) == 3
        % Apply median filtering to each RGB channel
        output = zeros(size(img), 'like', img);

        for channel = 1:3
            output(:,:,channel) = medfilt2( ...
                img(:,:,channel), ...
                [kernelSize kernelSize], ...
                'symmetric');
        end
    else
        output = medfilt2(img, ...
            [kernelSize kernelSize], ...
            'symmetric');
    end
end
