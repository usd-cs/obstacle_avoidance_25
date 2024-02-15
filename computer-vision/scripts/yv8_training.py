from ultralytics import YOLO
'''
Super Annoying but need python3.10 for this one thing.
coreml has nonstop updates, and we need version 7.1 to export trained models to coreml
'''
model = YOLO('computer-vision/models/yolov8n-oiv7.pt')

model.export(format='coreml')