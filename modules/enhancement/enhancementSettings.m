function settings = enhancementSettings(operation)
% ENHANCEMENTSETTINGS Operation-specific defaults, ranges, and labels.
    settings = struct('Names', {{}}, 'Values', [], 'Limits', zeros(0, 2), ...
        'Help', 'Compare the input image with the processed result.');
    switch operation
        case 'Histogram Equalization'
            settings.Help = 'Redistribute grayscale intensities to improve contrast.';
        case 'Histogram Matching'
            settings.Help = 'Load a reference image, then match its grayscale histogram.';
        case 'Brightness Adjustment'
            settings.Names = {'Brightness offset'}; settings.Values = 0.15;
            settings.Limits = [-1 1]; settings.Help = 'Add an offset in [-1, 1]. Zero preserves brightness.';
        case 'Contrast Adjustment'
            settings.Names = {'Contrast factor'}; settings.Values = 1.3;
            settings.Limits = [0 10]; settings.Help = 'One preserves contrast; larger values increase it.';
        case {'Mean Filter', 'Median Filter'}
            settings.Names = {'Kernel size (px)'}; settings.Values = 3;
            settings.Limits = [1 51]; settings.Help = 'Use an odd neighborhood size, such as 3, 5, or 7.';
        case {'Laplacian Sharpening', 'High-Pass Sharpening'}
            settings.Names = {'Sharpening strength'}; settings.Values = 1;
            settings.Limits = [0 10]; settings.Help = 'Zero preserves the image. Start with a strength of one.';
        case {'Fourier Low-Pass', 'Fourier High-Pass'}
            settings.Names = {'Cutoff radius (px)'}; settings.Values = 30;
            settings.Limits = [eps Inf]; settings.Help = 'The cutoff is a radius in the centered frequency spectrum.';
        case 'Fourier Band-Pass'
            settings.Names = {'Low cutoff (px)', 'High cutoff (px)'};
            settings.Values = [15 60]; settings.Limits = [0 Inf; eps Inf];
            settings.Help = 'Keep frequencies between these radii. High cutoff must exceed low cutoff.';
        otherwise, error('enhancementSettings:Operation', 'Unknown enhancement operation.');
    end
end
