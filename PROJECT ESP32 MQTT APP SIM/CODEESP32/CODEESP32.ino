#include <Arduino.h>

#include <WiFi.h>
#include <WebServer.h>
#include <DNSServer.h>
#include <WiFiManager.h>

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27, 16, 2);
#define I2C_SDA 21
#define I2C_SCL 22

#include <DHT.h>
#define DHTPIN 18
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

#include <Ticker.h>
Ticker ticker;

#define LED 2
/*
  tài khoản ngoinhaiot.com
  nguoidungmqtt6
  @Aa123456789
*/
#include <PubSubClient.h>
const char* mqtt_server = "ngoinhaiot.com"; //server
int mqtt_port = 1111; // port
const char* mqtt_user = "nguoidungmqtt6"; // user mqtt
const char* mqtt_pass = "182E8918A7AB4035"; // pass mqtt
String topicsub = "nguoidungmqtt6/A"; // topic nhận dữ liệu ESP
String topicpub = "nguoidungmqtt6/B"; // topic gửi dữ liệu
WiFiClient espClient;
PubSubClient client(espClient);
String DataMqttJson = "";
void DuytriMQTT(void);

void ConnectMqtt(void); // khai báo kết nối server mqtt
void callback(char* topic, byte* payload, unsigned int length); // hàm nhận dữ liệu từ server mqtt
void reconnect(void); // check kết nối server
void SendMQTT(void);
String DataM = "";



void configModeCallback (WiFiManager *myWiFiManager) {
  Serial.println("Entered config mode");
  Serial.println(WiFi.softAPIP());
  ticker.attach(0.2, tick);
  Serial.println(myWiFiManager->getConfigPortalSSID());
}
void tick()
{

  int state = digitalRead(LED);
  digitalWrite(LED, !state);
}



/*
  UART0 RX IO3 , TX IO1
  UART1 RX IO9 , TX IO10
  UART2 RX IO16 , TX IO17
*/
#include <HardwareSerial.h>
#include <ArduinoJson.h>
#define RXD2 16
#define TXD2 17
HardwareSerial mySerial(2);

//#define mySerial Serial2

#define Nut1 15
#define Nut2 4
#define Nut3 5
#define Nut4 19

#define RL1 13
#define RL2 12
#define RL3 14
#define RL4 27

#define Data_Nut1  digitalRead(Nut1)
#define Data_Nut2  digitalRead(Nut2)
#define Data_Nut3  digitalRead(Nut3)
#define Data_Nut4  digitalRead(Nut4)

#define RL1_ON digitalWrite(RL1,HIGH)
#define RL1_OFF digitalWrite(RL1,LOW)
int TT_RL1 = 0;

#define RL2_ON digitalWrite(RL2,HIGH)
#define RL2_OFF digitalWrite(RL2,LOW)
int TT_RL2 = 0;

#define RL3_ON digitalWrite(RL3,HIGH)
#define RL3_OFF digitalWrite(RL3,LOW)
int TT_RL3 = 0;

#define RL4_ON digitalWrite(RL4,HIGH)
#define RL4_OFF digitalWrite(RL4,LOW)
int TT_RL4 = 0;


unsigned long last = millis();
unsigned long  last1 = millis();

float ND = 0;
float DA = 0;

const char* ssid = "VIETTEL";
const char* pass = "24682468";
bool shouldSaveConfig = false;


String inputString = "";
boolean stringComplete = false;

int _timeout;
String _buffer;
String number = "+84774043189";
String ReadSMS = "";
String DataSendSim = "";



void setup()
{
  Serial.begin(115200);
  while (!Serial);
  mySerial.begin(9600, SERIAL_8N1, RXD2, TXD2);
  while (!mySerial);

  BeginOUTPUT();
  BeginINPUT();
  BeginDHT();
  BeginLCDi2C();
  ConfigWifi();
  //ConnectWifi();
  delay(5000);
  RecieveMessage();
  delay(1000);
  Read_Sim();
  delay(1000);
  SendMessage("Start");
  delay(2000);
  ConnectMqtt();
  Serial.println("Start ESP32!!!");
  last = millis();
  last1 = millis();


}

void loop()
{
  Read_Sim();
  DuytriMQTT();
  Button();
  SendMQTT();
}
void Read_Sim()
{
  while (mySerial.available())
  {
    last = millis();
    last1 = millis();
    yield();
    char inChar = (char)mySerial.read();
    inputString += inChar;
    if (inChar == '\n')
    {
      stringComplete = true;
    }
    if (stringComplete)
    {
      
      Serial.println("Data Sim");
      Serial.println(inputString);
      if (inputString.indexOf("On1") >= 0)
      {
        RL1_ON;
        TT_RL1 =  1;
      }
      else if (inputString.indexOf("Off1") >= 0)
      {
        RL1_OFF;
        TT_RL1 =  0;
      }
      else if (inputString.indexOf("On2") >= 0)
      {
        RL2_ON;
        TT_RL2 =  1;
      }
      else if (inputString.indexOf("Off2") >= 0)
      {
        RL2_OFF;
        TT_RL2 =  0;
      }
      else if (inputString.indexOf("On3") >= 0)
      {
        RL3_ON;
        TT_RL3 =  1;
      }
      else if (inputString.indexOf("Off3") >= 0)
      {
        RL3_OFF;
        TT_RL3 =  0;
      }
      else if (inputString.indexOf("On4") >= 0)
      {
        RL4_ON;
        TT_RL4 =  1;
      }
      else if (inputString.indexOf("Off4") >= 0)
      {
        RL4_OFF;
        TT_RL4 =  0;
      }
      else if (inputString.indexOf("Sensor") >= 0)
      {
        DataSendSim = "";
        DataSendSim = "NhietDo:";
        DataSendSim += String(ND);
        DataSendSim += " DoAm:";
        DataSendSim += String(DA);
        SendMessage(DataSendSim);
        
      }
      last = millis();
      last1 = millis();
      inputString = "";
      stringComplete = false;
      yield();
    }
  }
}
void RecieveMessage()
{
  delay(1000);
  mySerial.println("AT+CNMI=2,2,0,0,0"); // AT Command to receive a live SMS
  delay(1000);
}
String _readSerial()
{
  _timeout = 0;
  while  (!mySerial.available() && _timeout < 12000  )
  {
    delay(13);
    _timeout++;
  }
  if (mySerial.available())
  {
    return mySerial.readString();
  }
}
void callNumber()
{
  mySerial.print (F("ATD"));
  mySerial.print (number);
  mySerial.print (F(";\r\n"));
  _buffer = _readSerial();
}
void SendMessage(String Mess)
{
  yield();
  mySerial.println("AT+CMGF=1");
  delay(1000);
  yield();
  mySerial.println("AT+CMGS=\"" + number + "\"\r");
  delay(1000);
  yield();
  String SMS = "";
  SMS = Mess;
  mySerial.println(SMS);
  delay(100);
  mySerial.println((char)26);// ASCII code of CTRL+Z
  delay(1000);
  yield();
  _buffer = _readSerial();
  yield();
}
//==============================================
void ConnectWifi()
{
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  //=============================================================
  Serial.println();
  Serial.println("Connect WiFi");
  Serial.print("Address IP esp: ");
  Serial.println(WiFi.localIP());
}
void Button()
{
  Button1();
  Button2();
  Button3();
  Button4();
}
void  Button1()
{
  if (Data_Nut1 == 0)
  {
    delay(100);
    while (1)
    {
      DuytriMQTT();
      if (Data_Nut1 == 1)
      {
        DieuKhienRL1();
        delay(100);
        last = millis();
        last1 = millis();
        break;
      }
    }
  }
}
void  Button2()
{
  if (Data_Nut2 == 0)
  {
    delay(100);
    while (1)
    {
      DuytriMQTT();
      if (Data_Nut2 == 1)
      {
        DieuKhienRL2();
        delay(100);
        last = millis();
        last1 = millis();
        break;
      }
    }
  }
}
void  Button3()
{
  if (Data_Nut3 == 0)
  {
    delay(100);
    while (1)
    {
      DuytriMQTT();
      if (Data_Nut3 == 1)
      {
        DieuKhienRL3();
        delay(100);
        last = millis();
        last1 = millis();
        break;
      }
    }
  }
}
void  Button4()
{
  if (Data_Nut4 == 0)
  {
    delay(100);
    while (1)
    {
      DuytriMQTT();
      if (Data_Nut4 == 1)
      {
        DieuKhienRL4();
        delay(100);
        last = millis();
        last1 = millis();
        break;
      }
    }
  }
}
void DieuKhienRL1()
{
  if (TT_RL1 == 0)
  {
    RL1_ON;
    TT_RL1 = 1;
  }
  else if (TT_RL1 == 1)
  {
    RL1_OFF;
    TT_RL1 = 0;
  }
}
void DieuKhienRL2()
{
  if (TT_RL2 == 0)
  {
    RL2_ON;
    TT_RL2 = 1;
  }
  else if (TT_RL2 == 1)
  {
    RL2_OFF;
    TT_RL2 = 0;
  }
}
void DieuKhienRL3()
{
  if (TT_RL3 == 0)
  {
    RL3_ON;
    TT_RL3 = 1;
  }
  else if (TT_RL3 == 1)
  {
    RL3_OFF;
    TT_RL3 = 0;
  }
}
void DieuKhienRL4()
{
  if (TT_RL4 == 0)
  {
    RL4_ON;
    TT_RL4 = 1;
  }
  else if (TT_RL4 == 1)
  {
    RL4_OFF;
    TT_RL4 = 0;
  }
}
void chuongtrinhcambien()
{
  if (millis() - last >= 1000)
  {
    Read_DHT11();
    last = millis();
  }
}
void Read_DHT11(void)
{

  DA = dht.readHumidity();
  ND = dht.readTemperature(); // or dht.readTemperature(true) for Fahrenheit

  if (isnan(DA) || isnan(ND))
  {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  //DA++;
  //ND = ND + 2;
  Serial.print("Nhiệt độ:");
  Serial.println(ND);
  Serial.print("Độ Ẩm:");
  Serial.println(DA);
}
void BeginDHT()
{
  dht.begin();
  delay(100);
}
void BeginOUTPUT()
{
  pinMode(LED, OUTPUT);
  pinMode(RL1, OUTPUT); pinMode(RL2, OUTPUT); pinMode(RL3, OUTPUT); pinMode(RL4, OUTPUT);
  RL1_OFF; RL2_OFF; RL3_OFF; RL4_OFF;
}
void BeginINPUT()
{
  pinMode(Nut1, INPUT_PULLUP); pinMode(Nut2, INPUT_PULLUP); pinMode(Nut3, INPUT_PULLUP); pinMode(Nut4, INPUT_PULLUP);
}
void BeginLCDi2C()
{

  Wire.begin(I2C_SDA , I2C_SCL);
  delay(100);
  lcd.begin(16, 2);
  lcd.init();
  lcd.backlight();
  lcd.display();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("MQTT");
  lcd.setCursor(0, 1);
  lcd.print("ESP32");
  Serial.println("LCD OK!!!");
}
void HienThiLCD(void)
{
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("DO AN");
  lcd.setCursor(0, 1);
  lcd.print("ND:");
  lcd.print(ND);
  lcd.print(" DA:");
  lcd.print(DA);

}
void ConfigWifi()
{

  delay(1000);
  ticker.attach(0.3, tick);
  WiFiManager wifiManager;
  wifiManager.setAPCallback(configModeCallback);
  wifiManager.autoConnect("ESPWIFICONFIG", "12345678");
  ticker.detach();

}
void saveConfigCallback () {
  Serial.println("Should save config");
  shouldSaveConfig = true;
}
//===============
void DataJson( String ND,  String DA ,  String TT_RL1 , String TT_RL2 , String TT_RL3  , String TT_RL4)
{
  DataMqttJson = "";
  DataMqttJson = "{\"ND\":\"" + String(ND) + "\"," +
                 "\"DA\":\"" + String(DA) + "\"," +
                 "\"TB1\":\"" + String(TT_RL1) + "\"," +
                 "\"TB2\":\"" + String(TT_RL2) + "\"," +
                 "\"TB3\":\"" + String(TT_RL3) + "\"," +
                 "\"TB4\":\"" + String(TT_RL4) + "\"}";
}
void SendMQTT(void)
{
  if (millis() - last1 >= 2000)
  {
    if (WiFi.status() == WL_CONNECTED)
    {
      if (client.connected())
      {
        Read_DHT11();
        HienThiLCD();
        DataJson(String(ND),  String(DA) ,  String(TT_RL1) , String(TT_RL2) , String(TT_RL3) , String(TT_RL4) );
        Serial.println();
        Serial.print("DataMqttJson: ");
        Serial.println(DataMqttJson);
        client.publish(topicpub.c_str(), DataMqttJson.c_str());
        tick();
        yield();
      }

    }

    last1 = millis();
  }

}
void reconnect()
{

  while (!client.connected())
  {
    String clientId = String(random(0xffff), HEX); // các id client esp không trung nhau => không bị reset server
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass))
    {
      Serial.println("Connected MQTT");
      last = millis();
      last1 = millis();
      client.subscribe(topicsub.c_str());

    }
    else
    {
      Serial.println("Disconnected MQTT");
      delay(5000);
    }
  }
}
void  ConnectMqtt()
{
  client.setServer(mqtt_server, mqtt_port); // sét esp client kết nối MQTT broker
  delay(10);
  client.setCallback(callback); // => đọc dữ liệu mqtt broker mà esp subscribe
  delay(10);
}
void DuytriMQTT()
{
  if (!client.connected())
  {
    reconnect();
  }
  client.loop();
}
void callback(char* topic, byte* payload, unsigned int length)
{
  Serial.print("Message topic: ");
  Serial.println(topic);
  for (int i = 0; i < length; i++)
  {
    DataM += (char)payload[i];
  }
  Serial.print("Data nhận MQTT: ");
  Serial.println(DataM);
  ParseJson(String(DataM));
  last = millis();
  last1 = millis();

  DataM = "";
}


void ParseJson(String Data)
{
  const size_t capacity = JSON_OBJECT_SIZE(2) + 256;
  DynamicJsonDocument JSON(capacity);
  DeserializationError error = deserializeJson(JSON, Data);
  if (error)
  {
    Serial.println("Data JSON Error!!!");
    return;
  }
  else
  {
    Serial.println();
    Serial.println("Data JSON MQTT: ");
    serializeJsonPretty(JSON, Serial);

    if (JSON.containsKey("TB1"))
    {
      DieuKhienRL1();

    }
    if (JSON.containsKey("TB2"))
    {

      DieuKhienRL2();
    }

    if (JSON.containsKey("TB3"))
    {

      DieuKhienRL3();
    }

    if (JSON.containsKey("TB4"))
    {

      DieuKhienRL4();

    }

    JSON.clear();

  }
}
