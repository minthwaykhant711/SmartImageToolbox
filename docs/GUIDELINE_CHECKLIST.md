# Guideline coverage: topic 15

| Requirement | Implementation / evidence |
|---|---|
| MATLAB handwritten digits using ANN and KNN | `modules/digitRecognition`, saved models, comparison UI |
| Histogram equalization and matching | `modules/enhancement/histogram` |
| Brightness and contrast | `modules/enhancement/spatial`; operation-specific controls |
| Mean, median, Laplacian, high-pass sharpening | `modules/enhancement/spatial` |
| Fourier low-, high-, and band-pass | `modules/enhancement/frequency`; independent band limits |
| Original/enhanced comparisons | Enhancement two-panel view and histogram comparison |
| Sobel, Prewitt, Canny and comparison | Segmentation four-panel comparison |
| Otsu thresholding | `otsuThreshold`, auto/manual foreground polarity |
| Region-based segmentation | Marker-controlled watershed; region growing is an example in the brief |
| Color segmentation in RGB/HSV | `segmentByColor`, channel-range controls |
| Dilation, erosion, opening, closing | `applyMorphology`, adjustable disk radius |
| Shape-based processing | `shapeBasedSegmentation`, area and eccentricity filters |
| Segmentation comparisons | Otsu/adaptive/watershed comparison view |
| Translation, scale, rotation, affine | `modules/transformation/geometric` |
| Forward and reverse mapping | `warpImage` and mapping comparison |
| Radial distortion correction | `correctRadialDistortion` |
| Nearest, bilinear, bicubic | `interpolateImage`, `resizeImage`, comparison UI |
| Registration (optional) | Harris/patch/RANSAC and mutual information |
| Integrated upload/processing/result GUI | Shared `ImageWorkspace`, responsive four-tab application |
| Practical application to topic 15 | Explicit result transfer to recognition and common feature input |
| Accuracy evidence | `evaluateDigitModels`, CSV confusion matrices and measured results |
| Integration/testing | `runProjectTests` and automated workflow checks |
| Report and presentation | Drafts in this directory; add group names, screenshots, and actual presentation roles |

The brief requires the operations to be available in an integrated toolbox. The recognition workflow uses the relevant subset; applying every enhancement or edge detector to every digit is unnecessary. The final academic report and presentation should explain the group's choices and measured limitations.
