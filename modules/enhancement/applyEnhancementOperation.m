function result = applyEnhancementOperation(image, operation, parameters, reference)
% APPLYENHANCEMENTOPERATION Shared implementation for UI and automated tests.
    ImageWorkspace.validateImage(image);
    settings = enhancementSettings(operation);
    if nargin < 3 || isempty(parameters), parameters = settings.Values; end
    if nargin < 4, reference = []; end
    if numel(parameters) ~= numel(settings.Values) || any(~isfinite(parameters))
        error('applyEnhancementOperation:Parameters', 'Provide the parameters required by this operation.');
    end
    if any(parameters(:) < settings.Limits(:, 1)) || any(parameters(:) > settings.Limits(:, 2))
        error('applyEnhancementOperation:Range', 'A parameter is outside its allowed range.');
    end
    switch operation
        case 'Histogram Equalization', result = applyHistogramEqualization(image);
        case 'Histogram Matching'
            if isempty(reference), error('applyEnhancementOperation:Reference', 'Load a reference image first.'); end
            result = applyHistogramMatching(image, reference);
        case 'Brightness Adjustment', result = adjustBrightness(image, parameters(1));
        case 'Contrast Adjustment', result = adjustContrast(image, parameters(1));
        case {'Mean Filter', 'Median Filter'}
            kernel = parameters(1);
            if kernel ~= round(kernel) || mod(kernel, 2) ~= 1
                error('applyEnhancementOperation:Kernel', 'Kernel size must be a positive odd integer.');
            end
            if strcmp(operation, 'Mean Filter'), result = applyMeanFilter(image, kernel);
            else, result = applyMedianFilter(image, kernel); end
        case 'Laplacian Sharpening', result = applyLaplacianSharpening(image, parameters(1));
        case 'High-Pass Sharpening', result = applyHighPassSharpening(image, parameters(1));
        case 'Fourier Low-Pass', result = applyFourierLowPass(image, parameters(1));
        case 'Fourier High-Pass', result = applyFourierHighPass(image, parameters(1));
        case 'Fourier Band-Pass', result = applyFourierBandPass(image, parameters(1), parameters(2));
    end
end
