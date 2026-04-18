import sys
import json
from ultralytics import YOLO

def main():
    if len(sys.argv) < 3:
        print("ERROR")
        return

    model_path = sys.argv[1]
    image_path = sys.argv[2]

    model = YOLO(model_path)
    results = model.predict(source=image_path, save=False, verbose=False, conf=0.25)

    if len(results) == 0 or results[0].boxes is None or len(results[0].boxes) == 0:
        print("NO_DETECTION")
        return

    boxes = results[0].boxes.xyxy.cpu().numpy()
    confs = results[0].boxes.conf.cpu().numpy()

    best_idx = confs.argmax()
    best_box = boxes[best_idx].tolist()
    best_conf = float(confs[best_idx])

    out = {
        "bbox": best_box,
        "conf": best_conf
    }

    print(json.dumps(out))

if __name__ == "__main__":
    main()