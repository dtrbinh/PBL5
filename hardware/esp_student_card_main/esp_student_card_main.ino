#include "SPI.h"
#include "driver/rtc_io.h"
#include <FS.h>
#include <SPIFFS.h>

#include <WiFi.h>
#include <WiFiClient.h>
#include <WiFiClientSecure.h>

#include <ArduinoJson.h>
#include "HTTPClient.h"
#include <ESP32Ping.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include "esp_camera.h"

#include "string.h"
#include "stdio.h"


//remote
// String serverName = "example.com";  // OR REPLACE WITH YOUR DOMAIN NAME
// const int serverPort = 443;         //server port for HTTPS
// String serverPath = "/upload.php";
// WiFiClientSecure client;

// REPLACE WITH YOUR NETWORK CREDENTIALS

// IP Address: http://192.168.235.205
String thirdOctet = "";
const char* ssid = "ChanBeDu";
const char* password = "ChuBeDan";

#define FLASH_GPIO_NUM 4
#define BUILT_IN_LED 33
#define CAMERA_MODEL_AI_THINKER

#if defined(CAMERA_MODEL_AI_THINKER)
#define PWDN_GPIO_NUM 32
#define RESET_GPIO_NUM -1
#define XCLK_GPIO_NUM 0
#define SIOD_GPIO_NUM 26
#define SIOC_GPIO_NUM 27

#define Y9_GPIO_NUM 35
#define Y8_GPIO_NUM 34
#define Y7_GPIO_NUM 39
#define Y6_GPIO_NUM 36
#define Y5_GPIO_NUM 21
#define Y4_GPIO_NUM 19
#define Y3_GPIO_NUM 18
#define Y2_GPIO_NUM 5
#define VSYNC_GPIO_NUM 25
#define HREF_GPIO_NUM 23
#define PCLK_GPIO_NUM 22
#else
#error "Camera model not selected"
#endif

// Photo File Name to save in SPIFFS
#define FILE_PHOTO "/student_card.jpg"

//Global variables

bool isReady = false;
bool isTakingPicture = false;
unsigned long connectWifiTimer = 0;


#pragma region EXTENSION
String splitter(String data, char separator, int index) {
  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++) {
    if (data.charAt(i) == separator || i == maxIndex) {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }

  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}
#pragma endregion

#pragma region SYSTEM_CONFIG
//Config region
void software_serial_config() {
  Serial1.begin(115200, SERIAL_8N1, 12, 13);
}

void initSpiffs() {
  if (!SPIFFS.begin(true)) {
    Serial.println("An Error has occurred while mounting SPIFFS");
    isReady = false;
  } else {
    // delay(500);
    Serial.println("SPIFFS mounted successfully");
    isReady = true;
  }
}

void configCam() {
  //Config flash
  pinMode(FLASH_GPIO_NUM, OUTPUT);
  pinMode(BUILT_IN_LED, OUTPUT);
  //Config camera
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  // FRAMESIZE_QVGA (320 x 240)
  // FRAMESIZE_CIF (352 x 288)
  // FRAMESIZE_VGA (640 x 480)
  // FRAMESIZE_SVGA (800 x 600)
  // FRAMESIZE_XGA (1024 x 768)
  // FRAMESIZE_SXGA (1280 x 1024)
  // FRAMESIZE_UXGA (1600 x 1200)

  if (psramFound()) {
    Serial.println("Camera settings: 1");
    config.frame_size = FRAMESIZE_XGA;
    config.jpeg_quality = 10;
    config.fb_count = 1;
  } else {
    Serial.println("Camera settings: 2");
    config.frame_size = FRAMESIZE_SXGA;
    config.jpeg_quality = 10;
    config.fb_count = 1;
  }

  // Initialize camera
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    isReady = false;
    return;
  } else {
    Serial.println("Camera init success");
    isReady = true;
  }
}

void connectWifi() {
  // Connect to Wi-Fi
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  connectWifiTimer = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    if (millis() - connectWifiTimer >= 30000) {
      Serial.println("Connect wifi timeout! RESTART");
      ESP.restart();
    }
  }
  Serial.println();
  // Print ESP32 Local IP Address
  String localIP = WiFi.localIP().toString();
  Serial.println(localIP);
  thirdOctet = splitter(localIP, '.', 2);
  Serial.println("Third octet: " + thirdOctet);
  isReady = true;
}
#pragma endregion

#pragma region FLASH_FUNCTION
//Turn on - off flash
void turnOnFlash() {
  digitalWrite(FLASH_GPIO_NUM, HIGH);
}

void turnOffFlash() {
  digitalWrite(FLASH_GPIO_NUM, LOW);
}

void turnOnLed() {
  digitalWrite(BUILT_IN_LED, HIGH);
}

void turnOffLed() {
  digitalWrite(BUILT_IN_LED, LOW);
}
#pragma endregion

#pragma region CAMERA_FUNCTION
bool checkPhoto(fs::FS& fs) {
  File f_pic = fs.open(FILE_PHOTO);
  unsigned int pic_sz = f_pic.size();
  return (pic_sz > 100);
}
// Capture Photo and Save it to SPIFFS
// camera_fb_t* capturePhoto() {
//   if (isTakingPicture) return NULL;
//   camera_fb_t* fb = NULL;  // pointer
//   Serial.println("Taking a photo...");
//   turnOnFlash();
//   fb = esp_camera_fb_get();
//   delay(100);
//   turnOffFlash();
//   if (!fb) {
//     Serial.println("Camera capture failed");
//     return NULL;
//   } else {
//     Serial.print("Captured image. Image size: ");
//     Serial.print(fb->len);
//     Serial.println("bytes");
//     esp_camera_fb_return(fb);
//     return fb;
//   }
// }

void capturePhotoSaveSpiffs() {
  isTakingPicture = true;
  camera_fb_t* fb = NULL;  // pointer
  bool ok = 0;             // Boolean indicating if the picture has been taken correctly
  do {
    // Take a photo with the camera
    Serial.println("Taking a photo...");
    turnOnFlash();
    fb = esp_camera_fb_get();
    turnOffFlash();
    if (!fb) {
      Serial.println("Camera capture failed");
      isTakingPicture = false;
      return;
    }
    // Photo file name
    Serial.printf("Picture file name: %s\n", FILE_PHOTO);
    File file = SPIFFS.open(FILE_PHOTO, FILE_WRITE);
    // Insert the data in the photo file
    if (!file) {
      Serial.println("Failed to open file in writing mode");
    } else {
      file.write(fb->buf, fb->len);  // payload (image), payload length
      Serial.print("The picture has been saved in ");
      Serial.print(FILE_PHOTO);
      Serial.print(" - Size: ");
      Serial.print(file.size() / 1024);
      Serial.println(" kilobytes");
    }
    // Close the file
    file.close();
    esp_camera_fb_return(fb);

    // check if file has been correctly saved in SPIFFS
    ok = checkPhoto(SPIFFS);
  } while (!ok);
  isTakingPicture = false;
}

void readSpiffImage() {
  Serial.println("Read student card from spiffs...");
  bool fileexists = SPIFFS.exists(FILE_PHOTO);  //replace with the file datapath
  if (!fileexists) {
    Serial.println("File doens't exist");
  } else {
    File file = SPIFFS.open(FILE_PHOTO);
    if (!file) {
      Serial.println("Failed to open file for reading");
      return;
    }
    Serial.println("File Content:");
    Serial.print("[");
    while (file.available()) {
      Serial.print(file.read());
      Serial.print(", ");
    }
    Serial.print("]");
    file.close();
  }
}
#pragma endregion

#pragma region APP_FUNCTION
//Call api read student card
String postStudentCard() {

  if (isTakingPicture) return "";
  camera_fb_t* fb = NULL;  // pointer
  Serial.println("Taking a photo...");
  // turnOnFlash();
  // delay(100);
  fb = esp_camera_fb_get();
  // delay(100);
  // turnOffFlash();

  if (!fb) {
    Serial.println("Camera capture failed");
    isReady = false;
    return "";
  } else {
    Serial.print("Captured image. Image size: ");
    Serial.print(fb->len);
    Serial.println("bytes");

    //implement logic
    String response = postImageWithLocalHTTP(fb);
    esp_camera_fb_return(fb);
    return response;
  }
}

String postImageWithLocalHTTP(camera_fb_t* fb) {
  String serverName = "192.168." + thirdOctet + ".13";
  const int serverPort = 80;
  const char* serverPath = "/students/scan-card";

  Serial.printf("Post image with size %zu\n", fb->len);

  String head = "--PBL5DUT\r\nContent-Disposition: form-data; name=\"student_card_img\"; filename=\"esp32-cam-student-card.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n";
  String tail = "\r\n--PBL5DUT--\r\n";

  HTTPClient http;
  http.begin(String("http://") + serverName + String(serverPath));

  http.addHeader("Content-Type", "multipart/form-data; boundary=PBL5DUT");

  uint32_t imageLen = fb->len;
  uint32_t extraLen = head.length() + tail.length();
  uint32_t totalLen = imageLen + extraLen;

  http.addHeader("Content-Length", String(totalLen));

  // Tạo chuỗi form data
  String formData = head;
  formData += String((char*)fb->buf, fb->len);
  formData += "\r\n--PBL5DUT\r\nContent-Disposition: form-data; name=\"arduino\"\r\n\r\n1";
  formData += tail;

  esp_camera_fb_return(fb);
  int httpResponseCode = http.POST(formData);

  String result;
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println(response);
    result = response;

    // Khai báo bộ đệm đối tượng JSON
    DynamicJsonDocument doc(1024);

    // Phân tích cú pháp JSON
    DeserializationError error = deserializeJson(doc, response);

    // Kiểm tra lỗi phân tích cú pháp JSON
    if (error) {
      Serial.print("deserializeJson() failed: ");
      Serial.println(error.c_str());
      return "";
    }

    // Lấy giá trị các trường dữ liệu
    const char* class_name = doc["data"]["class_name"];
    const char* faculty = doc["data"]["faculty"];
    const char* name = doc["data"]["name"];
    const char* student_id = doc["data"]["student_id"];
    const char* message = doc["message"];
    int status = doc["status"];

    // In giá trị các trường dữ liệu
    Serial.print("class_name: ");
    Serial.println(class_name);
    Serial.print("faculty: ");
    Serial.println(faculty);
    Serial.print("name: ");
    Serial.println(name);
    Serial.print("student_id: ");
    Serial.println(student_id);
    Serial.print("message: ");
    Serial.println(message);
    Serial.print("status: ");
    Serial.println(status);
    // "102200010$DoTranBinh$20T1$KhoaCNTT";
    if (status == 0) {
      result = "";
    } else {
      result = String(student_id) + "$" + String(name) + "$" + String(class_name) + "$" + String(faculty);
    }
  } else {
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
    result = "";
  }

  http.end();
  return result;
}

String fakePostStudentCard() {
  if (isTakingPicture) return "";
  camera_fb_t* fb = NULL;  // pointer
  Serial.println("Taking a photo...");
  turnOnFlash();
  fb = esp_camera_fb_get();
  delay(100);
  turnOffFlash();

  if (!fb) {
    Serial.println("Camera capture failed");
    isReady = false;
    return "";
  } else {
    esp_camera_fb_return(fb);
    // free(fb);
    return "102200010$DoTranBinh$20T1$KhoaCNTT";
  }
}

void checkCameraState() {
  if (isReady) {
    Serial1.println("READY");
  } else {
    Serial1.println("NOT_READY");
  }
}

void testCall() {
  if (Serial.available()) {
    String message = Serial.readString();
    Serial.print("Debug message: ");
    Serial.println(message);
    if (message == "ping\n") {
      Serial.print("IP Address: http://");
      Serial.println(WiFi.localIP());
    } else if (message == "testcall\n") {
      postStudentCard();
    } else if (message == "testcap\n") {
      fakePostStudentCard();
    } else {
      Serial.println("Undefined debug command");
    }
  }
}
#pragma endregion

// Main func
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);  //disable brownout detector
  Serial.begin(115200);
  Serial.println("DEBUG SERIAL PORT READY!");
  isReady = true;

  software_serial_config();
  initSpiffs();
  configCam();
  connectWifi();

  checkCameraState();
  Serial.println("----------SYSTEM READY---------");
}

void loop() {
  testCall();
  if (!isReady) {
    checkCameraState();
    ESP.restart();
  }
  if (Serial1.available()) {
    Serial.println("-----MESSAGE FROM CENTER-----");
    String msg = Serial1.readString();
    msg.trim();
    Serial.println("Message: " + msg);

    if (msg == "CAPTURE") {
      String result = postStudentCard();
      if (result != "") {
        Serial1.println(result);
      } else {
        Serial1.println("CANT_DETECT");
      }
    } else if (msg == "TEST") {
      fakePostStudentCard();
    } else if (msg == "RESTART") {
      ESP.restart();
    } else {
      Serial.println("UNDEFINED COMMAND");
    }
    Serial.println("------------------------");
  }
}