# Presentation outline — 7 to 8 minutes

Replace Student 1/2/3 with actual group members. Use screenshots and measured results generated from this project, and rehearse the transitions.

1. **Problem and objective — 40 seconds.** Introduce topic 15: one handwritten digit, MATLAB, KNN and ANN. Explain why noise, background, scale, and position affect recognition.
2. **Enhancement — Student 1, 70 seconds.** Show a noisy/low-contrast digit, compare original and filtered images, and demonstrate the spatial/frequency controls. Explain that stronger processing is not always better.
3. **Segmentation — Student 2, 80 seconds.** Compare Sobel/Prewitt/Canny, isolate foreground with Otsu, and show opening/closing plus shape filtering. Briefly show HSV color selection on a color image to demonstrate the required general toolbox feature.
4. **Transformation and integration — Student 3, 75 seconds.** Compare interpolation methods and forward/reverse mapping. Send a processed result to recognition without exporting and uploading it again.
5. **KNN and ANN — 75 seconds.** Show the exact 28 × 28 input and both predictions. Explain KNN's neighbor vote and the ANN's 784-128-64-10 network. State that scores are model preferences, not guaranteed correctness.
6. **Evaluation — 60 seconds.** Show the actual CSV accuracy table, sample count, seeded test selection, and a confusion matrix. Explain the distinction between original MNIST evaluation and upload preprocessing. Report both successes and errors.
7. **Roles, limitations, and next steps — 45 seconds.** State actual contributions and challenges. Discuss single-digit scope, clutter/lighting/domain differences, and validation-based parameter choices. Registration is optional advanced functionality.

## Demo preparation

- Open `runToolbox` and verify both model files are present.
- Use Sample Digit if live-upload lighting is unreliable; clearly identify it as MNIST.
- Prepare one successful real handwritten example and one challenging example.
- Avoid retraining during the presentation. Show saved evaluation evidence instead.
- Keep the original image visible and explain each processing choice.
