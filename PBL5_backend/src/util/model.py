import tensorflow as tf
import torch
import numpy as np
import cv2
from imutils import perspective
import numpy as np
import functools
from skimage.filters import threshold_local
import imutils
from keras.models import load_model
from tensorflow.keras.utils import img_to_array

best_path = "src/util/best.pt"
model_detect_frame = torch.hub.load('ultralytics/yolov5', 'custom',
                        path=best_path, force_reload=True)
model_detect_text = load_model("src/util/trained_model_6.h5", compile=False)

def getPlateTextFromImage(imgPath):
    image = cv2.imread(imgPath)
    results = model_detect_frame(image)
    df = results.pandas().xyxy[0]
    for obj in df.iloc:

        xmin = float(obj['xmin'])
        xmax = float(obj['xmax'])
        ymin = float(obj['ymin'])
        ymax = float(obj['ymax'])
        conf = float(obj['confidence'])
        class_name = obj['name']
    coord = np.array([[xmin, ymin], [xmax, ymin], [xmax, ymax], [xmin, ymax]])
    LpRegion = perspective.four_point_transform(image, coord)
    # cv2.imshow('a', LpRegion)
    # cv2.waitKey(0)

    image = LpRegion.copy()
    V = cv2.split(cv2.cvtColor(image, cv2.COLOR_BGR2HSV))[2]
    # adaptive threshold
    T = threshold_local(V, 35, offset=5, method="gaussian")
    thresh = (V > T).astype("uint8") * 255
    # Chuyen den thanh trang
    thresh = cv2.bitwise_not(thresh)
    thresh = imutils.resize(thresh, width=600)
    # cv2.imshow('a', thresh)
    # cv2.waitKey(0)
    _, labels = cv2.connectedComponents(thresh)
    mask = np.zeros(thresh.shape, dtype="uint8")
    total_pixels = thresh.shape[0] * thresh.shape[1]
    lower = total_pixels // 90
    upper = total_pixels // 20
    for label in np.unique(labels):
        if label == 0:
            continue
        labelMask = np.zeros(thresh.shape, dtype="uint8")
        labelMask[labels == label] = 255
        numPixels = cv2.countNonZero(labelMask)
        if numPixels > lower and numPixels < upper:
            mask = cv2.add(mask, labelMask)
    # cv2.imshow('a', mask)
    cv2.waitKey(0)

    cnts, _ = cv2.findContours(
        mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    boundingBoxes = [cv2.boundingRect(c) for c in cnts]
    arr = boundingBoxes.copy()
    arr = np.array(arr)
    mean_w = np.mean(arr[:, 2])
    mean_h = np.mean(arr[:, 3])

    # Tính ngưỡng dựa trên trung bình cộng của w và h
    threshold_w = mean_w * 1.5
    threshold_h = mean_h * 1.5

    # Tạo mảng mới chỉ chứa các phần tử có w và h nhỏ hơn ngưỡng
    new_arr = arr[(arr[:, 2] < threshold_w) & (arr[:, 3] < threshold_h)]


    def compare(rect1, rect2):
        if abs(rect1[1] - rect2[1]) > 10:
            return rect1[1] - rect2[1]
        else:
            return rect1[0] - rect2[0]


    # Sắp xếp từ trái sang phải, trên xuống dưới
    boundingBoxes = sorted(new_arr, key=functools.cmp_to_key(compare))

    img_with_boxes = imutils.resize(image.copy(), width=600)
    image = imutils.resize(image.copy(), width=600)
    for bbox in new_arr:
        x, y, w, h = bbox
        cv2.rectangle(img_with_boxes, (x, y), (x+w, y+h), (0, 0, 255), 2)

    # cv2.imshow('a', img_with_boxes)
    cv2.waitKey(0)
    # Character Recognition

    chars = [
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
        'H', 'K', 'L', 'M', 'N', 'P', 'S', 'T', 'U', 'V', 'X', 'Y', 'Z'
    ]
    vehicle_plate = ""

    # Mang chua cac chu da duoc cat ra
    characters = []

    # Cat tung chu ra va luu vao characters
    for rect in boundingBoxes:
        x, y, w, h = rect

        character = mask[y:y+h, x:x+w]
        character = cv2.bitwise_not(character)
        rows = character.shape[0]
        columns = character.shape[1]
        paddingY = (128 - rows) // 2 if rows < 128 else int(0.17 * rows)
        paddingX = (
            128 - columns) // 2 if columns < 128 else int(0.45 * columns)
        character = cv2.copyMakeBorder(character, paddingY, paddingY,
                                    paddingX, paddingX, cv2.BORDER_CONSTANT, None, 255)

        character = cv2.cvtColor(character, cv2.COLOR_GRAY2RGB)
        character = cv2.resize(character, (128, 128))
        # chuan hoa
        character = character.astype("float") / 255.0
        characters.append(character)

    # Nhan dang chu
    characters = np.array(characters)
    probs = model_detect_text.predict(characters)

    # Lay tung ki tu dua vao nhan
    for prob in probs:
        idx = np.argsort(prob)[-1]
        vehicle_plate += chars[idx]
    return vehicle_plate