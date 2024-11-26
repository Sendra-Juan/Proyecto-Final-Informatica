#include <DHT.h>
#include <RtcDS1302.h>    // Librería para el RTC DS1302
#include <ThreeWire.h>    // Librería para la comunicación de tres hilos
#include <Wire.h>

// Pines
#define DHTTYPE DHT11   // Tipo de Sensor
#define DHTPIN 2        // Pin del DHT11
#define LED_PIN 5       // Pin del Led
#define BUZZER_PIN 7    // Pin del Buzzer

// Configuración del RTC
#define PIN_RST 9
#define PIN_DAT 10
#define PIN_CLK 11


//Clase del SensorDHT11
class SensorDHT {
  private: 
    float temperature;
    int humidity;
    DHT dht;

  public:
    SensorDHT() : dht(DHTPIN, DHTTYPE) {  //Contructor inicializamos los atributos
      temperature = 0.0;
      humidity = 0;
      dht.begin(); //Establecemos la comunicacion entre arduino y el sensor
    }

  void readSensor() {
    temperature = dht.readTemperature();
    humidity = dht.readHumidity();
  }

  float obtainTemperature() {
    return temperature;
  }

  int obtainHumidity() {
    return humidity;
  }
};

// Crear un objeto ThreeWire con los pines definidos
ThreeWire myWire(PIN_DAT, PIN_CLK, PIN_RST); 
RtcDS1302<ThreeWire> rtc(myWire); // Crear objeto RTC usando el objeto ThreeWire

//Clase del reloj RTCDS1302
class RTCDS1302 {
  private: 
    RtcDS1302<ThreeWire> rtc; // Objeto RTC para manejar el reloj
    int year, month, day, hour, minute, second;

  public:
    RTCDS1302() : rtc(myWire) {
      rtc.Begin();  // Inicia el RTC
    }

  void setInitialTime() { // Método para configurar la hora del RTC (esto solo se debe hacer una vez)
    if(!rtc.IsDateTimeValid()) {    // Solo configura la hora si el RTC no está configurado (si su tiempo está en 0)
      Serial.println("Configurando fecha y hora incial. . .");
      rtc.SetDateTime(RtcDateTime(__DATE__, __TIME__));   // Establece la fecha y hora de compilación
    }
    rtc.SetIsWriteProtected(false);
    if (!rtc.GetIsRunning()) rtc.SetIsRunning(true);
    }

  void update() {
    RtcDateTime now = rtc.GetDateTime(); // Obtener la fecha y hora actual
    year = now.Year();
    month = now.Month();
    day = now.Day();
    hour = now.Hour();
    minute = now.Minute();
    second = now.Second();
  }
  
  String gettime() {
    return (String(year) + "," + String(month) + "," + String(day) + "," + String(hour) + "," + String(minute) + "," + String(second) + ",");
  }
};


//Creamos objetos
SensorDHT sensor; //Objeto de la clase sensor
RTCDS1302 clock; //Objeto de la clase reloj


float tempMin, tempMax, humMin, humMax;

void setup() {
  Serial.begin(9600);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);    //Apaga el led
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW); // Apaga el buzzer

  clock.setInitialTime(); 
}

void loop() {
  sensor.readSensor();
  clock.update();


  float t = sensor.obtainTemperature();
  int h = sensor.obtainHumidity();
  String time = clock.gettime();

  // Enviar datos a Processing
  Serial.print(h); Serial.print(","); // Envia humedad actual
  Serial.print(t); Serial.print(","); // Envia temperatura actual
  Serial.println(time);               // Envia fecha y hora actualizados


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


  if (Serial.available() > 0) 
  {
    String data = Serial.readStringUntil('\n');
       
    if (data.startsWith("SET:")) 
    {
      String rawValues = data.substring(4); // Extraer valores después de "SET:"
      String values[4];  // Arreglo para almacenar los valores separados
      splitString(rawValues, ',', values, 4); // Dividir la cadena en 4 partes

      if(values[0].length() > 0 && values[1].length() > 0 
         && values[2].length() > 0 && values[3].length() > 0) 
         {
            humMin = values[0].toFloat();
            humMax = values[1].toFloat();
            tempMin = values[2].toFloat();
            tempMax = values[3].toFloat();
            Serial.println("OK");
         } else {
          Serial.println("ERROR");
         }
      }
      // Mostrar los límites recibidos para depuración
      Serial.print("Límites recibidos - HumMin: ");
      Serial.print(humMin);
      Serial.print(" HumMax: ");
      Serial.print(humMax);
      Serial.print(" TempMin: ");
      Serial.print(tempMin);
      Serial.print(" TempMax: ");
      Serial.println(tempMax);
    }


  if (alarma) {
    digitalWrite(LED_PIN, HIGH);
    digitalWrite(BUZZER_PIN, HIGH);
  }
  else {
    digitalWrite(LED_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);
  }

  delay(1000); // Probar si se actualizan los datos mas rapido cuando saco el delay
}



// Función para dividir una cadena en partes con base en un delimitador
void splitString(String input, char delimiter, String parts[], int maxParts) {
  int currentIndex = 0;
  int startIndex = 0;
  int endIndex = input.indexOf(delimiter);

  while (endIndex != -1 && currentIndex < maxParts - 1) {
    parts[currentIndex++] = input.substring(startIndex, endIndex);
    startIndex = endIndex + 1;
    endIndex = input.indexOf(delimiter, startIndex);
  }

  // Agregar el último fragmento
  if (currentIndex < maxParts) {
    parts[currentIndex] = input.substring(startIndex);
  }
}

