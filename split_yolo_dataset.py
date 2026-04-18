import os
import random
import shutil

# Kaynak klasörler
IMG_DIR = "images"
LBL_DIR = "labels"

# Hedef klasör (oluşturulacak)
DST = "yolo_dataset"

# Hedef klasör yapısını oluştur
os.makedirs(f"{DST}/images/train", exist_ok=True)
os.makedirs(f"{DST}/images/val", exist_ok=True)
os.makedirs(f"{DST}/labels/train", exist_ok=True)
os.makedirs(f"{DST}/labels/val", exist_ok=True)

# Tüm jpg görüntüleri listele
images = [f for f in os.listdir(IMG_DIR) if f.lower().endswith(".jpg")]

random.shuffle(images)

# %10'unu val (doğrulama) olarak ayır
val_ratio = 0.10
val_count = int(len(images) * val_ratio)

val_set = images[:val_count]
train_set = images[val_count:]

def copy_items(image_list, subset):
    for img in image_list:
        lbl = os.path.splitext(img)[0] + ".txt"

        src_img = os.path.join(IMG_DIR, img)
        src_lbl = os.path.join(LBL_DIR, lbl)

        dst_img = os.path.join(DST, "images", subset, img)
        dst_lbl = os.path.join(DST, "labels", subset, lbl)

        # Görüntüyü kopyala
        shutil.copy(src_img, dst_img)

        # Etiket varsa kopyala
        if os.path.exists(src_lbl):
            shutil.copy(src_lbl, dst_lbl)
        else:
            print(f"⚠ Etiket bulunamadı, atlandı: {lbl}")

copy_items(train_set, "train")
copy_items(val_set, "val")

print("✔ Dataset başarıyla YOLO formatında ayrıldı!")
print(f"Train: {len(train_set)}   Val: {len(val_set)}")
