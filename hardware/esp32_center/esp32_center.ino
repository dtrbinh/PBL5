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

// App state global variables
bool isCheckInMode = true;

bool isCapturedStudentCard = false;

int step = 0;  //0 - start, 1 - captured student card, 2 - captured bks, 3 - reset
bool isBtnModePushing = false;
bool isBtnOKPushing = false;
bool isBtnCancelPushing = false;

unsigned long connectWifiTimer = 0;
unsigned long getDistanceTimer = 0;

String studentFaculty = "Faculty";
String studentClass = "Class";
String studentName = "Name";
String studentId = "102200000";

String numplateId = "";
String numplate = "0R00 - 0000";
String status = "Status";

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

#pragma region SERVER_INFO
//local
// String serverName = "192.168.1.XXX";   // REPLACE WITH YOUR local PC ADDRESS
// const int serverPort = 80;
// String serverPath = "/upload.php";
// WiFiClient client;

//remote
String serverName = "example.com";  // OR REPLACE WITH YOUR DOMAIN NAME
const int serverPort = 443;         //server port for HTTPS
String serverPath = "/upload.php";
WiFiClientSecure client;
#pragma endregion

#pragma region WIFI_INFO
// REPLACE WITH YOUR NETWORK CREDENTIALS
// const char* ssid = "freewifi";
// const char* password = "123512356";
const char* ssid = "NHANNT";
const char* password = "0906551010";
#pragma endregion

#pragma region DEFINE_STATIC_VARIABLES
//rx - tx
HardwareSerial st_card(1);

const char* checkinIP = "192.168.1.21";  // địa chỉ IP của ESP32-CAM
const int checkinPort = 88;                 // cổng kết nối của ESP32-CAM
WiFiClient checkin;

const char* checkoutIP = "192.168.1.22";  // địa chỉ IP của ESP32-CAM
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

#pragma endregion

#pragma region SYSTEM_CONFIG
//Config region
void configHardwareSerial() {
  computerLog("CONFIG HARDWARE SERIAL...");
  st_card.begin(115200, SERIAL_8N1, 17, 18);  // studentCard
  computerLog("OK!");
}

void configStatusLed() {
  pinMode(GREEN_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);

  computerLog("TEST LED...");
  turnOnAllLed();
  delay(1000);
  turnOffAllLed();
  computerLog("OK!");
}

void configBuzzer() {
  pinMode(BUZZER, OUTPUT);
  computerLog("TEST BUZZER...");
  playMelody(startMelody, startMelodyNoteDurations, ARRAY_SIZE(startMelodyNoteDurations));
  computerLog("OK!");
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
  computerLog("CONFIG BUTTON...");
  pinMode(MODE_BTN, INPUT);
  pinMode(OK_BTN, INPUT);
  pinMode(CANCEL_BTN, INPUT);
  computerLog("OK!");
}

void configUltrasonicSensor() {
  computerLog("TEST ULTRASONIC SENSOR...");
  pinMode(TRIGGER, OUTPUT);
  pinMode(ECHO, INPUT);
  getDistanceTimer = millis();
  int distance = getDistance(true);
  computerLog(String(distance));
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
  computerLog(String(distance));
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

      break;
  }
}

void okBtnPush() {
  switch (step) {
    case 0:
      playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
      break;
    case 1:
      if (isCheckInMode) {
        computerLog("SEND MESSAGE CHECKIN");
        captureCheckin();
      } else {
        computerLog("SEND MESSAGE CHECKOUT");
        captureCheckout();
      }
      break;
    case 2:
      // check full data and call api checkin / checkout
      if (isCheckInMode) {
        computerLog("CALL API TO SERVER FOR CHECKIN: ");
        computerLog(studentId + "-");
        computerLog(studentFaculty + "-");
        computerLog(studentClass + "-");
        computerLog(studentName + "-");

        computerLog(numplateId + "-");
        computerLog(numplate + "-");

        //implement call api
      } else {
        computerLog("CALL API TO SERVER CHECKOUT");
        computerLog(studentId + "-");
        computerLog(studentFaculty + "-");
        computerLog(studentClass + "-");
        computerLog(studentName + "-");

        computerLog(numplateId + "-");
        computerLog(numplate + "-");

        //implement call api
      }
      step = 3;
      // set status and write status to lcd
      // if success set step to 3 else step still 2
      break;
    case 3:
      // all step is done
      // just clean all data + re-clean lcd
      // step = 0
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
  playMelody(beepMelody, beepMelodyDurations, ARRAY_SIZE(beepMelodyDurations));
  Serial.println("Waiting student card module response...");
  while (!st_card.available()) {
    Serial.print(".");
    if (millis() - timeoutChecker >= threshold) {
      Serial.println("RESPONSE TIMEOUT !!!");
      playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
      return;
    }
  }
  handleStCardResponse();
}

void captureCheckin() {
  Serial.println("CAPTURING VEHICLE CHECKIN");
  bool connectState = connectAndSendToCheckin("CAPTURE");
  if (!connectState) {
    Serial.print("CANT CONNECT TO CHECKIN CAMERA!!!");
    playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
    return;
  } else {
    playMelody(beepMelody, beepMelodyDurations, ARRAY_SIZE(beepMelodyDurations));
  }
}

void captureCheckout() {
  Serial.println("CAPTURING VEHICLE CHECKOUT");
  bool connectState = connectAndSendToCheckout("CAPTURE");
  if (!connectState) {
    Serial.print("CANT CONNECT TO CHECKOUT CAMERA!!!");
    playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
    return;
  } else {
    playMelody(beepMelody, beepMelodyDurations, ARRAY_SIZE(beepMelodyDurations));
  }
}

void handleStCardResponse() {
  if (st_card.available()) {
    String msg = st_card.readString();
    msg.trim();
    computerLog("RECEIVED FROM STUDENT CARD CAMERA: ");
    computerLog(msg);

    //Example: 102200010$DoTranBinh$20T1$KhoaCNTT

    if (msg == "CANT_DETECT") {
      computerLog("CAPTURE STUDENT CARD ERROR!!!");
    } else {
      studentId = splitter(msg, '$', 0);
      studentName = splitter(msg, '$', 1);
      studentClass = splitter(msg, '$', 2);
      studentFaculty = splitter(msg, '$', 3);

      step = 1;
      lcdWriteClassAndName();
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
      playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
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
      computerLog("CAPTURE CHECKIN ERROR!!!");
      resetNumberPlateStep();
    } else {
      step = 2;
      lcdWriteNumberPlate();
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
      playMelody(alertMelody, alertMelodyDurations, ARRAY_SIZE(alertMelodyDurations));
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
      computerLog("CAPTURE CHECKOUT ERROR!!!");
      resetNumberPlateStep();
    } else {
      step = 2;
      lcdWriteNumberPlate();
    }
  }
}

#pragma endregion

#pragma region MESSSENGER

void computerLog(String message) {
  Serial.println(message);
}

bool connectAndSendToCheckin(String message) {
  if (checkin.connect(checkinIP, checkinPort)) {

    checkin.write(message.c_str(), message.length());
    Serial.println("Waiting check in camera response...");
    handleCheckInResponse();

    checkin.stop();
    return true;
  } else {
    computerLog("Checkint connection failed");
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

#pragma endregion

#pragma region CLEANER

void resetSystemMode() {
  isCheckInMode = true;
  lcdWriteMode();
}

void resetStudentCardStep() {
  studentFaculty = "Faculty";
  studentClass = "Class";
  studentName = "Name";
  studentId = "102200000";

  lcdWriteClassAndName();
}

void resetNumberPlateStep() {
  numplateId = "";
  numplate = "0R00 - 0000";
  lcdWriteNumberPlate();
}

void cleanAllScreen() {
  isCheckInMode = true;
  studentFaculty = "Faculty";
  studentClass = "Class";
  studentName = "Name";
  studentId = "102200000";
  numplateId = "";
  numplate = "0R00 - 0000";
  updateScreenState();
}

#pragma endregion

// Main func
void setup() {
  Serial.begin(9600);
  computerLog("DEBUG SERIAL PORT READY!");

  configHardwareSerial();
  configStatusLed();
  configBuzzer();
  configLCD();
  configButton();

  configUltrasonicSensor();

  connectWifi();
  computerLog("============SYSTEM READY============");
}

void loop() {
  int distance = getDistance(false);
  if (distance <= 20 && distance >= 10) {
    if (!isCapturedStudentCard) {
      computerLog("DISABLE CAMERA. PLEASE LEAVE SCAN ZONE AND RE SCAN TO CONTINUE CAPTURE");
      isCapturedStudentCard = true;
      //deplay for stable
      delay(1000);
      captureStudentCard();
    }

  } else if (distance > 20) {
    computerLog("SCAN CARD CAMERA ENABLED.");
    isCapturedStudentCard = false;
  } else {
  }

  handleBtnModePush();
  handleBtnCancelPush();
  handleBtnOKPush();
}