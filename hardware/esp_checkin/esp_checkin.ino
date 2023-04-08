#include "esp_camera.h"
#include "SPI.h"
#include "driver/rtc_io.h"
#include <FS.h>
#include <SPIFFS.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

//local
// String serverName = "192.168.1.XXX";   // REPLACE WITH YOUR local PC ADDRESS
// const int serverPort = 80;
// String serverPath = "/upload.php";
// WiFiClient client;

//remote
String serverName = "example.com";   // OR REPLACE WITH YOUR DOMAIN NAME
const int serverPort = 443; //server port for HTTPS
String serverPath = "/upload.php";
WiFiClientSecure client;

// REPLACE WITH YOUR NETWORK CREDENTIALS
const char* ssid = "Wakumo-GUEST";
const char* password = "waku1235";

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

//Config
void software_serial_config(){
  Serial1.begin(115200, SERIAL_8N1, 15, 14); // main: 14rx 15tx - checkin: 15rx - 14tx
}

void connectWifi() {
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  // Print ESP32 Local IP Address
  Serial.print("IP Address: http://");
  Serial.println(WiFi.localIP());
}

void initSpiffs() {
  if (!SPIFFS.begin(true)) {
    Serial.println("An Error has occurred while mounting SPIFFS");
    ESP.restart();
  } else {
    delay(500);
    Serial.println("SPIFFS mounted successfully");
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
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 5;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 10;
    config.fb_count = 1;
  }

  // Initialize camera
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  } else{
    Serial.println("Camera init success");
  }
}

//Function
// Check if photo capture was successful
bool checkPhoto(fs::FS& fs) {
  File f_pic = fs.open(FILE_PHOTO);
  unsigned int pic_sz = f_pic.size();
  return (pic_sz > 100);
}

//Turn on - off flash
void turnOnFlash() {
  digitalWrite(FLASH_GPIO_NUM, HIGH);
}

void turnOffFlash() {
  digitalWrite(FLASH_GPIO_NUM, LOW);
}

void turnOnLed(){
  digitalWrite(BUILT_IN_LED, HIGH);
}

void turnOffLed(){
  digitalWrite(BUILT_IN_LED, LOW);
}

// Capture Photo and Save it to SPIFFS
camera_fb_t* capturePhoto() {
  camera_fb_t* fb = NULL;  // pointer

  Serial.println("Taking a photo...");
    turnOnFlash();
    fb = esp_camera_fb_get();
    delay(100);
    turnOffFlash();
    if (!fb) {
      Serial.println("Camera capture failed");
      return NULL;
    } else{
      Serial.print("Captured image. Image size: ");
      Serial.print(fb->len);
      Serial.println( "bytes");
      esp_camera_fb_return(fb);
      return fb;
    }
}

void capturePhotoSaveSpiffs() {
  camera_fb_t* fb = NULL;  // pointer
  bool ok = 0;             // Boolean indicating if the picture has been taken correctly

  do {
    // Take a photo with the camera
    Serial.println("Taking a photo...");
    turnOnFlash();
    fb = esp_camera_fb_get();
    delay(100);
    turnOffFlash();
    if (!fb) {
      Serial.println("Camera capture failed");
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

// Main func
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);  //disable brownout detector
  Serial.begin(115200);
  Serial.println("DEBUG SERIAL PORT READY!");
  software_serial_config();

  initSpiffs();
  configCam();
  Serial.println("");

}

void loop() {
  if(Serial1.available()){
    String msg = Serial1.readString();
    msg.trim();
    if (msg = "CAPTURE"){
      Serial.println("Received message: " + msg);
      capturePhoto();
    } else{
      Serial.print("Message: " + msg);
    }
  }
}