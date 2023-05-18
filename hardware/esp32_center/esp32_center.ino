#include <HardwareSerial.h>
#include "Arduino.h"
#include <LiquidCrystal_I2C.h>
#include "SPI.h"
#include "driver/rtc_io.h"
#include <FS.h>
#include <SPIFFS.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include "string.h"
#include "stdio.h"
#include "pitches.h"
#include "Wire.h"
#include <ArduinoJson.h>
#include "HTTPClient.h"

// App state global variables
bool isCheckInMode = true;

bool isCapturedStudentCard = false;

int step = 0;  //0 - start, 1 - captured student card, 2 - captured bks, 3 - reset
bool isBtnModePushing = false;
bool isBtnOKPushing = false;
bool isBtnCancelPushing = false;

unsigned long connectWifiTimer = 0;
unsigned long getDistanceTimer = 0;

String studentFaculty = "";
String studentClass = "";
String studentName = "";
String studentId = "";

String numplateId = "";
String numplate = "";
String status = "";

#pragma region EXTENSION

void tone(byte pin, int freq, int duration) {
  ledcSetup(0, 22000, 16);  // setup beeper
  ledcAttachPin(pin, 0);    // attach beeper
  ledcWriteTone(0, freq);   // play tone
}

void noTone(byte pin) {
  ledcWriteTone(0, 0);
}

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

#define ARRAY_SIZE(array) ((sizeof(array)) / (sizeof(array[0])))

#pragma endregion

#pragma region WIFI_INFO
// REPLACE WITH YOUR NETWORK CREDENTIALS
// IP: 192.168.223.198
const char* ssid = "ChanBeDu";
const char* password = "ChuBeDan";
#pragma endregion

#pragma region DEFINE_STATIC_VARIABLES
//rx - tx
HardwareSerial st_card(1);

const char* checkinIP = "192.168.235.145";  // địa chỉ IP của ESP32-CAM
const int checkinPort = 88;                 // cổng kết nối của ESP32-CAM
WiFiClient checkin;

const char* checkoutIP = "192.168.235.228";  // địa chỉ IP của ESP32-CAM
const int checkoutPort = 90;                 // cổng kết nối của ESP32-CAM
WiFiClient checkout;

LiquidCrystal_I2C lcd(
  0x27,  // Cài đặt địa chỉ I2C là 0x27.
  20,    // With 20 columns.
  4      // With 4 rows.
);

#define GREEN_LED 19
#define YELLOW_LED 20
#define RED_LED 21

#define MODE_BTN 12
#define OK_BTN 11
#define CANCEL_BTN 10

#define ECHO 33
#define TRIGGER 34

#define BUZZER 35

int startMelody[] = {
  NOTE_C5, NOTE_G4, NOTE_G4, NOTE_A4, NOTE_G4, 0, NOTE_B4, NOTE_C5
};

int startMelodyNoteDurations[] = {
  4, 8, 8, 4, 4, 4, 4, 4
};

int beepMelody[] = {
  NOTE_A6,
};

int beepMelodyDurations[] = {
  12,
};

int alertMelody[] = {
  NOTE_C6, NOTE_C6, NOTE_C6
};

int alertMelodyDurations[] = {
  4, 4, 4
};

int successMelody[] = {
  NOTE_G5, NOTE_B5, NOTE_D6, NOTE_G6
};

int successMelodyDurations[] = {
  4, 4, 4, 2
};

#pragma endregion

#pragma region SYSTEM_CONFIG
//Config region
void configHardwareSerial() {
  Serial.println("CONFIG HARDWARE SERIAL...");
  st_card.begin(115200, SERIAL_8N1, 17, 18);  // studentCard
  Serial.println("OK!");
}

void configStatusLed() {
  pinMode(GREEN_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);

  Serial.println("TEST LED...");
  turnOnAllLed();
  delay(1000);
  turnOffAllLed();
  Serial.println("OK!");
}

void configBuzzer() {
  pinMode(BUZZER, OUTPUT);
  Serial.println("TEST BUZZER...");
  playMelody(startMelody, startMelodyNoteDurations, ARRAY_SIZE(startMelodyNoteDurations));
  Serial.println("OK!");
}

void configLCD() {
  // Khởi động thư viện.
  // Start up the library.
  lcd.init();

  // Xóa màn hình, đảm bảo không còn nội dung cũ trước đó.
  // Clear the screen, making sure there is no old content left before.
  lcd.clear();

  // Bật đèn nền màn hình.
  // Turn on the screen backlight.
  lcd.backlight();

  updateScreenState();
}

void configButton() {
  Serial.println("CONFIG BUTTON...");
  pinMode(MODE_BTN, INPUT);
  pinMode(OK_BTN, INPUT);
  pinMode(CANCEL_BTN, INPUT);
  Serial.println("OK!");
}

void configUltrasonicSensor() {
  Serial.println("TEST ULTRASONIC SENSOR...");
  pinMode(TRIGGER, OUTPUT);
  pinMode(ECHO, INPUT);
  getDistanceTimer = millis();
  int distance = getDistance(true);
  Serial.println(String(distance));
}

void connectWifi() {
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi...");
  connectWifiTimer = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    if (millis() - connectWifiTimer >= 10000) {
      Serial.println("Connect wifi timeout! RESTART");
      ESP.restart();
    }
  }
  // Print ESP32 Local IP Address
  Serial.println(WiFi.localIP());
}
#pragma endregion

#pragma region LED_FUNCTIONS
// control led
void turnOnGreenLed() {
  digitalWrite(GREEN_LED, HIGH);
}
void turnOffGreenLed() {
  digitalWrite(GREEN_LED, LOW);
}

void turnOnYellowLed() {
  digitalWrite(YELLOW_LED, HIGH);
}
void turnOffYellowLed() {
  digitalWrite(YELLOW_LED, LOW);
}

void turnOnRedLed() {
  digitalWrite(RED_LED, HIGH);
}
void turnOffRedLed() {
  digitalWrite(RED_LED, LOW);
}

void turnOnAllLed() {
  turnOnGreenLed();
  turnOnYellowLed();
  turnOnRedLed();
}

void turnOffAllLed() {
  turnOffGreenLed();
  turnOffYellowLed();
  turnOffRedLed();
}
#pragma endregion

#pragma region BUZZER_FUNCTIONS

void playMelody(int melody[], int melodyDurations[], int melodySize) {
  for (int thisNote = 0; thisNote < melodySize; thisNote++) {
    int noteDuration = 1000 / melodyDurations[thisNote];
    tone(BUZZER, melody[thisNote], noteDuration);

    int pauseBetweenNotes = noteDuration * 1;
    delay(pauseBetweenNotes);
    noTone(BUZZER);
  }
}

void beepSound() {
  turnOnYellowLed();
  playMelody(beepMelody, beepMelodyDurations, ARRAY_SIZE(beepMelodyDurations));
  turnOffYellowLed();
}

void alertSound() {
  turnOnRedLed();
  playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
  turnOffRedLed();
}

void successSound() {
  turnOnGreenLed();
  playMelody(successMelody, successMelodyDurations, ARRAY_SIZE(successMelodyDurations));
  turnOffGreenLed();
}

#pragma endregion

#pragma region ULTRASONIC_FUNCTIONS
int getDistance(bool isForceGet) {
  // delay function
  if ((millis() - getDistanceTimer < 200) && !isForceGet) {
    return -1;
  }
  getDistanceTimer = millis();
  unsigned long duration;    // biến đo thời gian
  int distance;              // biến lưu khoảng cách
  digitalWrite(TRIGGER, 0);  // tắt chân trig
  delayMicroseconds(2);
  digitalWrite(TRIGGER, 1);  // phát xung từ chân trig
  delayMicroseconds(10);     // xung có độ dài 10 microSeconds
  digitalWrite(TRIGGER, 0);  // tắt chân trig
  duration = pulseIn(ECHO, HIGH);
  distance = int(duration * 0.034 / 2);

  // Serial.print("Time: ");
  // Serial.println(millis());
  Serial.print(String(distance));
  return distance;
}
#pragma endregion

#pragma region LCD_FUNCTION

void updateScreenState() {
  lcd.clear();
  lcdWriteMode();
  lcdWriteClassAndName();
  lcdWriteNumberPlate();
  lcdWriteStatus();
}

void lcdClearRow(int row) {
  lcd.setCursor(0, row);
  lcd.print("                    ");  //20 ' '
}

void lcdWriteMode() {
  lcdClearRow(0);
  lcd.setCursor(0, 0);
  if (isCheckInMode) {
    lcd.print("MODE: CHECKIN");
  } else {
    lcd.print("MODE: CHECKOUT");
  }
}

void lcdWriteClassAndName() {
  lcdClearRow(1);
  lcd.setCursor(0, 1);
  // 4 rows - 20 cols
  String clss = studentClass.substring(0, 7);
  clss.trim();
  String name = studentName.substring(0, 20 - 1 - clss.length() - 1);
  lcd.print(clss + "-" + name);
}

void lcdWriteNumberPlate() {
  lcdClearRow(2);
  lcd.setCursor(0, 2);
  lcd.print("BKS: " + numplate);
}

void lcdWriteStatus() {
  lcdClearRow(3);
  lcd.setCursor(0, 3);
  lcd.print("Status: " + status);
}

#pragma endregion

#pragma region BUTTON_FUNCTION

void handleBtnModePush() {
  int btnMode = digitalRead(MODE_BTN);
  if (btnMode == HIGH && !isBtnModePushing) {
    isBtnModePushing = true;
    changeSystemMode();
    lcdWriteMode();
  } else if (btnMode == LOW) {
    isBtnModePushing = false;
  } else {
  }
}

void handleBtnOKPush() {
  int btnOK = digitalRead(OK_BTN);
  if (btnOK == HIGH && !isBtnOKPushing) {
    isBtnOKPushing = true;
    okBtnPush();
  } else if (btnOK == LOW) {
    isBtnOKPushing = false;
  } else {
  }
}

void handleBtnCancelPush() {
  delay(300);
  int btnCancel = digitalRead(CANCEL_BTN);
  if (btnCancel == HIGH && !isBtnCancelPushing) {
    isBtnCancelPushing = true;
    cancelBtnPush();
  } else if (btnCancel == LOW) {
    isBtnCancelPushing = false;
  } else {
  }
}

void changeSystemMode() {
  isCheckInMode = !isCheckInMode;
}

void cancelBtnPush() {
  switch (step) {
    case 0:
      resetSystemMode();
      break;
    case 1:
      resetStudentCardStep();
      step = 0;
      break;
    case 2:
      resetNumberPlateStep();
      step = 1;
      break;
    case 3:
      // flow done
      break;
  }
}

void okBtnPush() {
  switch (step) {
    case 0:
      alertSound();
      break;
    case 1:
      if (isCheckInMode) {
        Serial.println("SEND MESSAGE CHECKIN");
        captureCheckin();
      } else {
        Serial.println("SEND MESSAGE CHECKOUT");
        captureCheckout();
      }
      break;
    case 2:
      // check full data and call api checkin / checkout
      if (isCheckInMode) {
        Serial.print("CALL API TO SERVER FOR CHECKIN: ");
        Serial.print(studentId + "-");
        Serial.print(studentFaculty + "-");
        Serial.print(studentClass + "-");
        Serial.print(studentName + "-");

        Serial.print(numplateId + "-");
        Serial.println(numplate + "-");

        //implement call api
        sendRequestCheckin();
      } else {
        Serial.print("CALL API TO SERVER CHECKOUT");
        Serial.print(studentId + "-");
        Serial.print(studentFaculty + "-");
        Serial.print(studentClass + "-");
        Serial.print(studentName + "-");

        Serial.print(numplateId + "-");
        Serial.println(numplate + "-");

        //implement call api
        status = "Waiting...";
        lcdWriteStatus();
        sendRequestCheckout();
      }

      // set status and write status to lcd
      // if success set step to 3 else step still 2
      break;
    case 3:
      // all step is done, step back to 0
      // just clean all data + re-clean lcd
      cleanAllScreen();
      step = 0;
      break;
  }
}

#pragma endregion

#pragma region CONTROL_CAMERA_FUNCTIONS

void captureStudentCard() {
  unsigned long timeoutChecker = millis();
  int threshold = 10000;  //10.000ms = 10s
  Serial.println("CAPTURING STUDENT CARD");
  st_card.println("CAPTURE");
  beepSound();
  Serial.println("Waiting student card module response...");
  while (!st_card.available()) {
    Serial.print(".");
    if (millis() - timeoutChecker >= threshold) {
      Serial.println("RESPONSE TIMEOUT !!!");
      alertSound();
      return;
    }
  }
  handleStCardResponse();
}

void captureCheckin() {
  beepSound();
  Serial.println("CAPTURING VEHICLE CHECKIN");
  bool connectState = connectAndSendToCheckin("CAPTURE");
  if (!connectState) {
    Serial.print("CANT CONNECT TO CHECKIN CAMERA!!!");
    alertSound();
    return;
  } else {
  }
}

void captureCheckout() {
  beepSound();
  Serial.println("CAPTURING VEHICLE CHECKOUT");
  bool connectState = connectAndSendToCheckout("CAPTURE");
  if (!connectState) {
    Serial.print("CANT CONNECT TO CHECKOUT CAMERA!!!");
    alertSound();
    return;
  } else {
  }
}

void handleStCardResponse() {
  if (st_card.available()) {
    String msg = st_card.readString();
    msg.trim();
    Serial.println("RECEIVED FROM STUDENT CARD CAMERA: ");
    Serial.println(msg);

    //Example: 102200010$DoTranBinh$20T1$KhoaCNTT

    if (msg == "CANT_DETECT") {
      Serial.println("CAPTURE STUDENT CARD ERROR!!!");
      alertSound();
    } else {
      studentId = splitter(msg, '$', 0);
      studentName = splitter(msg, '$', 1);
      studentClass = splitter(msg, '$', 2);
      studentFaculty = splitter(msg, '$', 3);
      step = 1;
      lcdWriteClassAndName();
      successSound();
    }
  }
}

void handleCheckInResponse() {
  unsigned long timeoutChecker = millis();
  int threshold = 10000;  //10.000ms = 10s

  Serial.println("OPEN CONNECT TO CHECKIN");
  while (!checkin.available()) {
    Serial.print(".");
    if (millis() - timeoutChecker >= threshold) {
      Serial.println("RESPONSE TIMEOUT !!!");
      Serial.println("CLOSE CONNECT TO CHECKIN");
      alertSound();
      return;
    }
  }
  if (checkin.available()) {
    String msg = checkin.readStringUntil('\r');
    msg.trim();
    Serial.println("RESPONSE FROM CHECKIN CAMERA: " + msg);

    //Example : 22$53R4 - 3628
    numplateId = splitter(msg, '$', 0);
    numplate = splitter(msg, '$', 1);
    if (numplateId == "-1" || numplate == "undefined") {
      Serial.println("CAPTURE CHECKIN ERROR!!!");
      resetNumberPlateStep();
      alertSound();
    } else {
      step = 2;
      lcdWriteNumberPlate();
      successSound();
    }
  }
}

void handleCheckOutResponse() {
  unsigned long timeoutChecker = millis();
  int threshold = 10000;  //10.000ms = 10s

  Serial.println("OPEN CONNECT TO CHECKOUT");
  while (!checkout.available()) {
    Serial.print(".");
    if (millis() - timeoutChecker >= threshold) {
      Serial.println("RESPONSE TIMEOUT !!!");
      Serial.println("CLOSE CONNECT TO CHECKOUT");
      alertSound();
      return;
    }
  }
  if (checkout.available()) {
    String msg = checkout.readStringUntil('\r');
    msg.trim();
    Serial.println("RESPONSE FROM CHECKIN CAMERA: " + msg);

    //Example : 22$53R4 - 3628
    numplateId = splitter(msg, '$', 0);
    numplate = splitter(msg, '$', 1);
    if (numplateId == "-1" || numplate == "undefined") {
      Serial.println("CAPTURE CHECKOUT ERROR!!!");
      resetNumberPlateStep();
      alertSound();
    } else {
      step = 2;
      lcdWriteNumberPlate();
      successSound();
    }
  }
}

#pragma endregion

#pragma region MESSSENGER

bool connectAndSendToCheckin(String message) {
  if (checkin.connect(checkinIP, checkinPort)) {

    checkin.write(message.c_str(), message.length());
    Serial.println("Waiting check in camera response...");
    handleCheckInResponse();

    checkin.stop();
    return true;
  } else {
    Serial.println("Checkint connection failed");
    return false;
  }
}

bool connectAndSendToCheckout(String message) {
  if (checkout.connect(checkoutIP, checkoutPort)) {

    checkout.write(message.c_str(), message.length());
    Serial.println("Waiting checkout camera response...");
    handleCheckOutResponse();

    checkout.stop();
    return true;
  } else {
    Serial.println("Checkout connection failed");
    return false;
  }
}

void sendRequestCheckin() {
  beepSound();
  checkInWithLocalHTTP(studentId, numplate, numplateId);
}

void sendRequestCheckout() {
  beepSound();
  checkOutWithLocalHTTP(studentId, numplate, numplateId);
}

bool checkInWithLocalHTTP(String student_id, String number_plate, String img_check_in_url) {
  bool requestResult = false;

  const char* serverName = "192.168.235.13";
  String endpoint = "/check-ins";
  const int serverPort = 80;
  HTTPClient http;
  http.begin(String("http://") + serverName + endpoint);

  http.addHeader("Content-Type", "application/json");
  // Khởi tạo đối tượng JSON để chứa dữ liệu
  StaticJsonDocument<200> doc;
  doc["student_id"] = student_id;
  doc["number_plate"] = number_plate;
  doc["img_check_in"] = img_check_in_url;
  // Chuyển đổi đối tượng JSON thành chuỗi JSON
  String data;
  serializeJson(doc, data);

  int httpResponseCode = http.POST(data);

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
      // handle failed
      status = "Failed";
      lcdWriteStatus();
      alertSound();
      requestResult = false;
    }

    // Lấy giá trị các trường dữ liệu

    // In giá trị các trường dữ liệu

    // handle success
    step = 3;
    status = "Success";
    lcdWriteStatus();
    successSound();
    requestResult = true;
  } else {
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
    result = "";

    // handle failed
    status = "Failed";
    lcdWriteStatus();
    alertSound();
    requestResult = false;
  }
  http.end();
  return requestResult;
}

bool checkOutWithLocalHTTP(String student_id, String number_plate, String img_check_out_url) {
  bool requestResult = false;

  const char* serverName = "192.168.235.13";
  String endpoint = "/logs";
  const int serverPort = 80;
  HTTPClient http;
  http.begin(String("http://") + serverName + endpoint);

  http.addHeader("Content-Type", "application/json");
  // Khởi tạo đối tượng JSON để chứa dữ liệu
  StaticJsonDocument<200> doc;
  doc["student_id"] = student_id;
  doc["number_plate"] = number_plate;
  doc["img_check_out"] = img_check_out_url;
  // Chuyển đổi đối tượng JSON thành chuỗi JSON
  String data;
  serializeJson(doc, data);

  int httpResponseCode = http.POST(data);

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
      // handle failed
      status = "Failed";
      lcdWriteStatus();
      alertSound();
      requestResult = false;
    }

    // Lấy giá trị các trường dữ liệu

    // In giá trị các trường dữ liệu

    // handle success
    step = 3;
    status = "Success";
    lcdWriteStatus();
    successSound();
    requestResult = true;
  } else {
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
    result = "";

    // handle failed
    status = "Failed";
    lcdWriteStatus();
    alertSound();
    requestResult = false;
  }
  http.end();
  return requestResult;
}


#pragma endregion

#pragma region CLEANER

void resetSystemMode() {
  isCheckInMode = true;
  lcdWriteMode();
}

void resetStudentCardStep() {
  studentFaculty = "";
  studentClass = "Class";
  studentName = "Name";
  studentId = "";

  lcdWriteClassAndName();
}

void resetNumberPlateStep() {
  numplateId = "";
  numplate = "=====";
  lcdWriteNumberPlate();
}

void cleanAllScreen() {
  isCheckInMode = true;
  studentFaculty = "";
  studentClass = "Class";
  studentName = "Name";
  studentId = "";
  numplateId = "";
  numplate = "=====";
  status = "";
  updateScreenState();
}

#pragma endregion

// Main func
void setup() {
  Serial.begin(9600);
  Serial.println("DEBUG SERIAL PORT READY!");

  configHardwareSerial();
  configStatusLed();
  configBuzzer();
  configLCD();
  configButton();

  configUltrasonicSensor();

  connectWifi();
  Serial.println("============SYSTEM READY============");
}

void loop() {
  if (step == 0) {
    int distance = getDistance(false);
    if (distance <= 20 && distance >= 10) {
      if (!isCapturedStudentCard) {
        Serial.println("DISABLE CAMERA. PLEASE LEAVE SCAN ZONE AND RE SCAN TO CONTINUE CAPTURE");
        isCapturedStudentCard = true;
        //deplay for stable
        delay(1000);
        captureStudentCard();
      }

    } else if (distance > 20) {
      Serial.println("SCAN CARD CAMERA ENABLED.");
      isCapturedStudentCard = false;
    } else {
    }
  }
  handleBtnModePush();
  handleBtnCancelPush();
  handleBtnOKPush();
}