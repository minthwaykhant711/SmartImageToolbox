# Smart Image Toolbox — handwritten digit recognition

A MATLAB toolbox with four connected tabs: Enhancement, Segmentation, Transformation, and Digit Recognition. The interface uses a common light theme, a controls sidebar, and image comparison panels.

## Start

Open this project folder in MATLAB, then run:

```matlab
setupProject
runToolbox
```

You can also open `app/SmartImageToolbox.mlapp` and press Run. Its startup builds the interface from the panel functions, so UI changes belong in those MATLAB files. The original App Designer file and callbacks are retained.

Requires MATLAB R2026a (the version verified on this computer), Image Processing Toolbox, Statistics and Machine Learning Toolbox, and Deep Learning Toolbox. The provided models are loaded only when recognition is requested. Training never starts automatically.

## Image workflow

1. Upload an image in any tab. It becomes the shared input.
2. Choose an enhancement, segmentation, or transformation and apply it.
3. **Use Result as Input** makes that result available in every processing tab.
4. **Send to Digit Recognition** previews that result as a centered 28 × 28 digit and opens the recognition tab.
5. Choose KNN, ANN, or Compare Both, then recognize.
6. **Reset to Original** restores the original uploaded image.

Processing results are previews until you explicitly use them. Watershed results contain region identifiers: they are displayed in color and can be saved as MAT labels or a PNG visualization. Select a binary segmentation operation to send a foreground mask to recognition.

Digit recognition accepts one digit at a time. Already-centered MNIST-format inputs retain their original pixel layout. The default preserves stroke width; optional thickening is available for experimentation. Blank images and multiple separated substantial objects are rejected. Very faint, touching, or cluttered digits still require an appropriate crop and preprocessing choices.

## Modules

- Enhancement: histogram equalization/matching, brightness/contrast, mean/median filtering, Laplacian/unsharp sharpening, ideal Fourier low/high/band-pass, and histogram comparisons.
- Segmentation: Sobel/Prewitt/Canny comparison, global/Otsu/adaptive thresholds, watershed regions, dilation/erosion/opening/closing, component filtering by area/eccentricity, and RGB/HSV ranges including hue wrapping.
- Transformation: translation, scale, rotation, affine composition, forward/reverse mapping, radial distortion, three interpolation methods, and optional feature/mutual-information registration.
- Recognition: cleaned foreground, aspect-preserving resize, mass centering, cached KNN/ANN models, saved class order, score plots, and prediction timings.

## MNIST and reproducible evaluation

The app includes ten small demonstration digits and the existing saved models. A full MNIST dataset is optional for the GUI and is not committed. Supply the four uncompressed IDX files in one folder. Either pass that folder to the functions below or set:

```matlab
setenv('SMART_IMAGE_DATASET', '/absolute/path/to/mnist')
```

`getProjectPaths` also checks `datasets/mnist` and `data/mnist` under the project root. No developer-specific dataset path is hardcoded.

Evaluate the supplied models on the same 1,000 seeded held-out test images:

```matlab
report = evaluateDigitModels('/absolute/path/to/mnist');
```

This reports original MNIST inputs and the GUI upload-preprocessing path separately. CSV results, confusion matrices, sampled test indices, and a MAT report are written to `results/`. Timings exclude model loading and include a warm-up prediction. A 1,000-image benchmark is not a claim of full-test-set accuracy. To evaluate every test image, use `MaxTestSamples=Inf`.

Retrain explicitly, select K using validation data, and evaluate:

```matlab
report = trainAndEvaluate('/absolute/path/to/mnist', ...
    TrainingSamples=10000, KNNSamples=5000, MaxEpochs=10);
```

Training uses a seeded 85/15 split of the sampled training set, saves class order and configuration, and backs up existing model files before replacing them. The test set is used for final evaluation only. Change `OutputRoot` to write a separate experiment. Model scores are not calibrated confidence estimates.

## Verification

```matlab
results = runProjectTests;
```

The automated checks cover foreground/polarity/noise handling, morphological behavior, RGB/HSV selection, shape filtering, transform identity/boundaries, model inference, and the integrated image workflow. The original `tests/testBrightness.m` and similar scripts remain manual visual demonstrations.

For hidden GUI tests set `SMART_IMAGE_TOOLBOX_VISIBLE` to `off`; leave it unset for normal use. See `docs/` for the guideline mapping and report/presentation drafts.
