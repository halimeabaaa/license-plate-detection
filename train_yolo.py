from ultralytics import YOLO

# YOLOv8s modeli kullanıyoruz (orta seviye, hızlı ve doğru)
model = YOLO("yolov8s.pt")

model.train(
    data="data.yaml",
    epochs=50,
    imgsz=640,
    batch=8,
    name="plate_detector"
)
