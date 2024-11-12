#include <DHT.h>
#include <RtcDS1302.h>
#include <ThreeWire.h>
#include <Wire.h>

// Pines
#define LED_PIN 5       // Pin del Led
#define DHTPIN 6        // Pin del DHT11
#define BUZZER_PIN 7    // Pin del Buzzer
#define DHTTYPE DHT11   // Tipo de Sensor

// Configuración del RTC
#define PIN_RST 9
#define PIN_DAT 10
#define PIN_CLK 11
ThreeWire myWire(PIN_DAT, PIN_CLK, PIN_RST);
RtcDS1302<ThreeWire> rtc(myWire);

// Crear objetos
DHT dht(DHTPIN, DHTTYPE);

float tempMin, tempMax, humMin, humMax;

void setup() {
  Serial.begin(9600);
  dht.begin();
  rtc.Begin();

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);    //Apaga el led
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW); // Apaga el buzzer

  // Configuración inicial del RTC
  if (!rtc.IsDateTimeValid()) {
    rtc.SetDateTime(RtcDateTime(__DATE__, __TIME__));
  }
  rtc.SetIsWriteProtected(false);
  if (!rtc.GetIsRunning()) rtc.SetIsRunning(true);
}

void loop() {
  // Leer temperatura y humedad
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  RtcDateTime now = rtc.GetDateTime();

  // Enviar datos a Processing
  Serial.print("Humedad:"); Serial.print(h); Serial.print(",");
  Serial.print("Temperatura:"); Serial.print(t); Serial.print(",");
  Serial.print("Time:"); Serial.print(now.Hour()); Serial.print(":");
  Serial.print(now.Minute()); Serial.print(":"); Serial.println(now.Second());

  // Revisar límites y activar alarma si es necesario
  bool alarma = false;
  String motivo = "";

  if (h < humMin || h > humMax) {
    alarma = true;
    motivo += "Humedad fuera de rango; ";
  }
  if (t < tempMin || t > tempMax) {
    alarma = true;
    motivo += "Temperatura fuera de rango;";
  }

  Serial.print("Humedad minima: ");
  Serial.print(humMin);
  Serial.print("; Humedad maxima: ");
  Serial.print(humMax);
  Serial.print("; Temperatura minima: ");
  Serial.print(tempMin);
  Serial.print("; Temperatura maxima: ");
  Serial.println(tempMax);
  
  if (alarma) {
    digitalWrite(LED_PIN, HIGH);
    digitalWrite(BUZZER_PIN, HIGH);
    registrarAlarma(now, motivo);
  } else {
    digitalWrite(LED_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);
  }

  delay(2000);
}

void registrarAlarma(RtcDateTime now, String motivo) {
  Serial.print("ALARM: ");
  Serial.print(now.Year()); Serial.print("-");
  Serial.print(now.Month()); Serial.print("-");
  Serial.print(now.Day()); Serial.print(" ");
  Serial.print(now.Hour()); Serial.print(":");
  Serial.print(now.Minute()); Serial.print(":");
  Serial.print(now.Second());
  Serial.print(" - ");
  Serial.println(motivo);
}
