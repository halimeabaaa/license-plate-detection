# License Plate Detection and Recognition System

This project is a hybrid **license plate detection and recognition system** built with **Python, YOLOv8, and MATLAB**.  
The system detects the license plate region from a vehicle image, segments the plate characters, and recognizes them using a trained CNN model.

## Project Overview

The project combines deep learning-based object detection with image processing and character recognition techniques:

- **YOLOv8** is used to detect the license plate area
- **MATLAB image processing** is used to segment characters from the detected plate
- A **CNN model** is used to classify the extracted characters
- A MATLAB-based interface is used to run the system in a practical way

## Features

- License plate detection from vehicle images
- Character segmentation from plate region
- Character recognition with CNN
- MATLAB-based application workflow
- Support for training and dataset preparation scripts

## Technologies Used

- **Python**
- **YOLOv8**
- **MATLAB**
- **CNN**
- **Computer Vision**
- **Image Processing**

## Project Structure

```bash
.
├── PlakaTanimaSistemi.m        # Main MATLAB application / interface
├── detect_plate.py             # Plate detection script using YOLO
├── train_yolo.py               # YOLO training script
├── split_yolo_dataset.py       # Dataset preparation for YOLO
├── crop_all_plates.m           # Crops plate regions
├── segment_chars.m             # Character segmentation
├── character_cnn_train.m       # CNN training script for character recognition
├── character_labeller.m        # Character labeling tool
├── create_char_dataset.m       # Creates character dataset
├── create_char_folders.m       # Creates folder structure for character dataset
├── split_dataset.m             # Splits dataset for training/testing
├── data.yaml                   # YOLO dataset configuration
├── best.pt                     # Trained YOLO model weights
├── yolov8s.pt                  # Base YOLOv8 model weights
├── character_cnn.mat           # Trained CNN model
└── .gitignore
