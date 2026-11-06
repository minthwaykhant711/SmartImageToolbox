# Segmentation tests

From the project root, run `setupProject`, then `runProjectTests` for the full automated suite. To run only the original algorithm tests:

```matlab
results = runtests('modules/segmentation/tests');
table(results)
```

The expanded tests in `tests/testRequiredSegmentation.m` cover morphology, shape filtering, RGB/HSV selection (including wrapped hue), dark foreground, and region palettes larger than 256 labels. `tests/testIntegratedWorkflow.m` checks the GUI and transfer to recognition.

For a visual check, run the app and use the Segmentation tab. Upload a grayscale or RGB image, choose an operation, and press Apply. Comparison buttons show the edge detectors or segmentation alternatives together. Watershed labels are displayed with stable colors; save MAT to retain the identifiers or PNG to retain the visualization. Label images are not sent directly to recognition. Choose a binary mask operation for that workflow.
