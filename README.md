After completing the project, we transformed raw EEG recordings into time-frequency spectrograms and treated each spectrogram as an image input for convolutional neural networks. We experimented with several state-of-the-art CNN architectures—fine-tuning layers, adjusting learning rates, and applying data-augmentation techniques—to classify harmful brain activities into six categories (Seizure, GPD, LRDA, GRDA, LPD, and Other). This approach yielded a modest accuracy improvement over our initial model, demonstrating the value of image-based feature extraction for EEG signals.

Key achievements:

- Spectrogram conversion:** Automated pipeline converting continuous EEG segments into standardized grayscale images.
- Model development:** Trained and compared multiple CNN variants, selecting the best-performing architecture based on validation accuracy and F1-score.
- Performance gains:** Improved overall classification accuracy by several percentage points on held-out data, with robust detection across all six classes.
- Scalability and reproducibility: Experiments run in Google Colab and on high-end GPUs (RTX 3090/4090), with code and hyperparameters version-controlled for easy replication.

Next steps:

- Fine-tune hyperparameters and integrate attention mechanisms to focus on critical frequency bands.
- Evaluate generalization on external EEG datasets to push accuracy beyond current benchmarks.

We’ve successfully deployed the core system, but development continues—both refining this project and launching new AI-driven initiatives.
