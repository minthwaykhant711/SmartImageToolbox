# Smart Image Processing Toolbox for Handwritten Digit Recognition

## Scope and team

Assigned topic: **15 — Handwritten Recognizer Using MATLAB (Digit Recognition Using ANN and KNN)**. The project combines the required general image-processing toolbox with a practical single-digit recognition workflow.

Fill in the actual group members and contributions before submission:

| Responsibility | Group member | Evidence to explain |
|---|---|---|
| Enhancement and spatial/frequency filtering | Student 1 | Implementations, comparisons, parameter choices |
| Segmentation, edges, morphology | Student 2 | Foreground extraction, comparisons, color/shape operations |
| Transformation, interpolation, integration/testing | Student 3 | Warping, responsive GUI, shared workflow, validation |

## System design

The App Designer startup calls `initializeToolboxApp`. Enhancement, segmentation, and recognition use a common `ImageProcessingPanel` with a controls sidebar and two/four-panel canvas. Transformation retains its existing operations and comparison views with the same theme and shared state. The layout expands with the window.

`ImageWorkspace` stores the original image, current shared input, and an explicit recognition target. Processing first produces a preview. A user can commit it as the shared input, send it to recognition, save it, or reset to the original. Every technique remains independently selectable; only appropriate processing steps are used for digit recognition.

## Module 1: enhancement

Histogram equalization redistributes grayscale intensities; histogram matching uses a selected reference distribution. Brightness adds an offset and contrast scales intensities about 0.5. Both clip to the valid display range. Mean and median filters reduce noise; the Laplacian sharpener subtracts a scaled discrete Laplacian, while high-pass sharpening adds the image minus a Gaussian-smoothed version.

Frequency filtering centers the 2-D Fourier spectrum and applies circular ideal low-, high-, or band-pass masks. Band-pass uses separate lower and upper radii. Ideal filters can introduce ringing, and aggressive high-pass processing can remove information useful for digit recognition. Original/result image and histogram views support comparison.

Implementation: `modules/enhancement`. Operation settings supply appropriate labels, default values, and parameter validation.

## Module 2: segmentation and morphology

Sobel and Prewitt approximate intensity derivatives; Canny combines smoothing, edge localization, and threshold-based linking. A comparison view shows the three results for one input. Global thresholding, Otsu's between-class variance threshold, and locally adaptive thresholding separate intensity-based foreground. Automatic border-based polarity can be overridden for bright or dark foreground.

Marker-controlled watershed operates on the gradient magnitude with shallow minima suppressed. Its output is a region-label matrix, visualized with distinct colors rather than normalized grayscale. A comparison view shows Otsu, adaptive, and watershed outputs.

Dilation expands foreground, erosion contracts it, opening removes small protrusions/noise, and closing bridges small gaps. The structuring element is a disk with a configurable radius. Shape-based processing selects connected regions using area and eccentricity. RGB/HSV segmentation selects channel ranges; wrapped hue ranges support colors spanning the red boundary.

Implementation: `modules/segmentation`. Label matrices are saved separately from their color visualization and are not automatically treated as digit intensities.

## Module 3: transformation and interpolation

Homogeneous 3 × 3 matrices represent translation, scaling, rotation, shear, and affine composition. Reverse mapping computes a source location for every destination pixel; forward mapping splats source pixels into the destination and can leave holes. Mapping comparisons measure holes from geometric coverage rather than black pixel intensity.

Nearest interpolation chooses one sample, bilinear interpolation combines four neighbors, and bicubic interpolation uses a 4 × 4 Keys convolution kernel with parameter -0.5. Output bounds use a full-canvas enclosure when requested. Small-image crops are limited to the available dimensions. Radial distortion uses the polynomial factor 1 + k1*r^2 + k2*r^4.

Optional registration uses Harris/patch matching with RANSAC for affine alignment, or coarse-to-fine mutual information for rotation, scale, and translation. Alignment quality uses geometric overlap, including genuine black image pixels.

Implementation: `modules/transformation`.

## Topic 15: recognition

Uploaded images are normalized to single precision in [0,1], converted to grayscale when needed, and oriented to a light digit on a dark background. Low-contrast blanks are rejected. Small artifacts are removed, substantial separated objects are rejected, and nearby significant components are retained. The digit is resized with preserved aspect ratio to fit a 20 × 20 region, placed on a 28 × 28 canvas, and centered using its intensity mass. Already-centered, dark-background 28 × 28 inputs with MNIST-like extent preserve their existing layout to avoid unnecessary resampling. Stroke thickening is optional and disabled by default. The same column-major 784-feature vector is supplied to both classifiers.

KNN uses Euclidean distances and neighbor voting. The provided ANN training function defines fully connected layers 784 → 128 → 64 → 10, ReLU hidden activations, softmax scores, Adam optimization, and cross-entropy loss. The retraining runner uses a seeded training/validation split and selects K on validation data. It saves class order and configuration with each model and backs up replaced model files.

The bundled legacy models are retained. Their original files do not record complete training provenance; the new configuration must not be presented as a verified history of those existing weights. Newly trained models include metadata. The GUI caches model loading and invalidates that cache if model files change.

## Experiments and results

`evaluateDigitModels` selects the same seeded held-out MNIST images for both classifiers. It reports two input conditions: original MNIST normalization and the actual upload-preprocessing path. This reveals preprocessing/domain effects rather than reporting only an ideal-input accuracy. Rejected inputs count as errors and appear in a separate confusion-matrix column.

Measured results and the sample indices are saved in `results/model-comparison.csv`, `results/evaluation.mat`, and the four confusion-matrix CSVs. The table below is populated from the executed benchmark when available. Timing excludes model loading, uses a warm-up call, and is hardware-dependent. A 1,000-image sample does not establish performance on all real handwritten images.

| Model | Input condition | Test images | Accuracy | Prediction ms/image | Rejected |
|---|---|---:|---:|---:|---:|
| KNN | Original MNIST | 1000 | 94.0% | 1.369 | 0 |
| KNN | Upload preprocessing | 1000 | 94.0% | 1.268 | 0 |
| ANN | Original MNIST | 1000 | 93.9% | 0.189 | 0 |
| ANN | Upload preprocessing | 1000 | 94.0% | 0.211 | 0 |


## Testing and limitations

Automated checks verify polarity/noise handling, blank/multiple-object rejection, normalized dimensions and centering, morphological behavior, RGB/HSV selection, shape filtering, transform identities and boundaries, model inference, and cross-tab transfer/reset behavior. Existing visual demonstrations are retained separately.

The recognizer assumes one digit. Touching digits, textured backgrounds, uneven lighting, unusual writing styles, and aggressive filtering can still cause errors. Model scores are not calibrated certainty. Photographs differ from MNIST and require a separate labeled real-image evaluation before making claims about real-world accuracy. The report should include genuine success/failure examples and actual screenshots from the completed app.

## Submission preparation

Replace the member placeholders, add annotated screenshots, discuss the observed confusion matrices, and explain the actual challenges and contributions. Use `PRESENTATION_OUTLINE.md` to prepare the required 5–10 minute group demonstration.
