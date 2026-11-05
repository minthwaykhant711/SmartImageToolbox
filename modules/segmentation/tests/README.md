# Segmentation tests

Run the automated tests from the project root in MATLAB after running
`setupProject`:

```matlab
results = runtests('modules/segmentation/tests');
table(results)
```

The tests use a synthetic grayscale image and its RGB equivalent. They verify
the six new algorithms, existing Sobel processing, output dimensions and types,
empty-input errors, the global-threshold default, and the GUI operation list.

For a manual GUI test, open `SmartImageToolbox.mlapp`, run the app, choose its
Segmentation tab, and upload a PNG/JPEG/BMP image. Select each operation and
press **Apply**. The original image should stay in the left axes, while the
right axes updates with a binary image for edge/threshold operations or a
watershed label matrix for watershed segmentation. Test with both grayscale and
RGB images. Watershed labels use zero for ridge lines and positive integers for
regions; MATLAB displays the label matrix in the processed axes.
