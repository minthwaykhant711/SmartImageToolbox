classdef ImageWorkspace < handle
    % Shared image state for the four processing tabs.
    properties (SetAccess = private)
        OriginalImage = []
        CurrentImage = []
        RecognitionImage = []
        SourceName = 'No image loaded'
        CurrentSource = 'No image loaded'
        RecognitionSource = ''
    end
    events
        ImageChanged
        RecognitionRequested
    end
    methods
        function loadImage(obj, image, source)
            obj.validateImage(image);
            if nargin < 3, source = 'Uploaded image'; end
            obj.OriginalImage = image;
            obj.CurrentImage = image;
            obj.SourceName = char(source);
            obj.CurrentSource = char(source);
            obj.RecognitionImage = [];
            obj.RecognitionSource = '';
            notify(obj, 'ImageChanged');
        end
        function useResult(obj, image, source)
            obj.validateImage(image);
            if isempty(obj.OriginalImage)
                obj.loadImage(image, source);
                return;
            end
            obj.CurrentImage = image;
            obj.CurrentSource = char(source);
            notify(obj, 'ImageChanged');
        end
        function reset(obj)
            if isempty(obj.OriginalImage), return; end
            obj.CurrentImage = obj.OriginalImage;
            obj.CurrentSource = obj.SourceName;
            notify(obj, 'ImageChanged');
        end
        function sendToRecognition(obj, image, source)
            obj.validateImage(image);
            obj.RecognitionImage = image;
            obj.RecognitionSource = char(source);
            notify(obj, 'RecognitionRequested');
        end
    end
    methods (Static)
        function validateImage(image)
            if isempty(image) || ~(isnumeric(image) || islogical(image)) || ...
                    ~isreal(image) || issparse(image) || any(~isfinite(image(:))) || ...
                    ndims(image) > 3 || ~ismember(size(image, 3), [1 3])
                error('ImageWorkspace:InvalidImage', ...
                    'Choose a nonempty grayscale or RGB image with finite pixel values.');
            end
        end
    end
end
