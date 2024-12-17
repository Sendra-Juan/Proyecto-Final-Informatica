#include <DHT.h>
#include <RtcDS1302.h>    // Librería para el RTC DS1302
#include <ThreeWire.h>    // Librería para la comunicación de tres hilos
#include <Wire.h>

// Nodo para la liste enlazada
struct Nodo {
    float humedad; // Valor del sensor
    float temperatura; 
    Nodo* siguiente;  // Puntero al sieguiente nodo
};

// Pines
#define DHTTYPE DHT11 // Tipo de Sensor
#define DHTPIN 3  // Pin del DHT11
#define LED_PIN 5 // Pin del Led
#define BUTTON_PIN 7  // Pin del boton
#define BUZZER_PIN 8  // Pin del Buzzer

// Configuración del RTC
#define PIN_RST 9
#define PIN_DAT 10
#define PIN_CLK 11

// Definimos el estado del led y el tiempo de la alarma
bool ledApagado = false;  // Estado del led (apagado temporalmente)
unsigned long tiempoApagado = 0;  // Momento en que el led se apago
const unsigned long duracionApagado = 10000;  // Duracion del apagado (en milisegundos)

//Clase del SensorDHT11
class SensorDHT {
  private: 
    float temperatura;
    int humedad;
    DHT dht;

  public:
    SensorDHT() : dht(DHTPIN, DHTTYPE) {  //Contructor inicializamos los atributos
      temperatura = 0.0;
      humedad = 0;
      dht.begin(); //Establecemos la comunicacion entre arduino y el sensor
    }

  void leerSensor() {
    temperatura = dht.readTemperature();
    humedad = dht.readHumidity();
  }

  float leerTemperatura() {
    return temperatura;
  }

  int leerHumedad() {
    return humedad;
  }
};

// Crear un objeto ThreeWire con los pines definidos
ThreeWire myWire(PIN_DAT, PIN_CLK, PIN_RST); 
RtcDS1302<ThreeWire> rtc(myWire); // Crear objeto RTC usando el objeto ThreeWire

//Clase del reloj RTCDS1302
class RTCDS1302 {
  private: 
    RtcDS1302<ThreeWire> rtc; // Objeto RTC para manejar el reloj
    int anio, mes, dia, hora, minuto, segundo;

  public:
    RTCDS1302() : rtc(myWire) {
      rtc.Begin();  // Inicia el RTC
    }

  void setTiempoInicial() { // Método para configurar la hora del RTC (esto solo se debe hacer una vez)
    if(!rtc.IsDateTimeValid()) {    // Solo configura la hora si el RTC no está configurado (si su tiempo está en 0)
      //Serial.println("Configurando fecha y hora incial. . .");
      rtc.SetDateTime(RtcDateTime(__DATE__, __TIME__));   // Establece la fecha y hora de compilación
    }
    rtc.SetIsWriteProtected(false);
    if (!rtc.GetIsRunning()) rtc.SetIsRunning(true);
    }

  void actualizar() {
    RtcDateTime now = rtc.GetDateTime(); // Obtener la fecha y hora actual
    anio = now.Year();
    mes = now.Month();
    dia = now.Day();
    hora = now.Hour();
    minuto = now.Minute();
    segundo = now.Second();
  }
  
  String tiempoActual() {
    return (String(anio) + "," + String(mes) + "," + String(dia) + "," + String(hora) + "," + String(minuto) + "," + String(segundo) + ",");
  }
};

// Clase Reporte
class Reporte {
private:
    Nodo* cabeza; // Puntero a la cabeza de la lista
    Nodo* cola; // Puntero al ultimo nodo
    int cantidad; // Contador de datos almacenados
    const int MAX_ELEMENTOS; // Tamaño maximo de la lista

public:
    // Constructor
    Reporte(int maxElementos) : cabeza(nullptr), cola(nullptr), cantidad(0), MAX_ELEMENTOS(maxElementos) {}

    // Metodo para agregar un nuevo dato
    void agregarDato(float nuevaTemperatura, float nuevaHumedad) {
        Nodo* nuevoNodo = new Nodo{nuevaTemperatura, nuevaHumedad, nullptr};  // Creamos un nuevo nodo
        if(cantidad == 0) {
          cabeza = cola = nuevoNodo; // Lista vacia: el nuevo nodo es cabeza y cola
          cantidad++;
        } else {
          cola -> siguiente = nuevoNodo; // Añadir el nuevo nodo al final 
          cola = nuevoNodo; 

          if(cantidad >= MAX_ELEMENTOS) { // Si la lista supera el tamaño maximo, eliminamos el primer nodo
            Nodo* temp = cabeza;
            cabeza = cabeza -> siguiente; // Mover cabeza al siguiente nodo
            delete temp; // Liberar memoria del nodo elimiando
          } else {
            cantidad++;
          }
        }
        if(cantidad > MAX_ELEMENTOS) cantidad = MAX_ELEMENTOS;
    }

    // Metodo para mostrar los todos los datos
    void mostrarDatos() {
      if(cabeza == nullptr) {
        Serial.println("No hay datos registrados");
        return;
      }
      
      Serial.println("Datos registrados: ");
      Nodo* actual = cabeza;
      while(actual != nullptr) {
        Serial.print("Humedad: "); Serial.print(actual -> humedad); // Imprime el dato actual de humedad
        Serial.print("%; Temperatura: "); Serial.print(actual -> temperatura); Serial.print("°C"); // Imprime el dato actual de temperatura
        actual = actual -> siguiente; // Pasa al siguiente nodo
      }
    }

    // Metodo para calcular y mostrar estadisticas
    void mostrarEstadisticas() {
      if(cabeza == nullptr) {
        Serial.println("No hay datos para analizar");
        return;
      }

      float sumaHum = 0;
      float sumaTemp = 0;

      Nodo* actual = cabeza;
      int elementos = 0;
      while(actual != nullptr) {
        sumaHum += actual -> humedad;
        sumaTemp += actual -> temperatura;
        elementos++;
        actual = actual -> siguiente;
      }

      float promedioHum = sumaHum / elementos;
      float promedioTemp = sumaTemp / elementos;

      //Serial.println("Estadisticas de los datos: ");
      Serial.print("Promedio humedad: "); 
      Serial.print(promedioHum); //Serial.print(",");
      Serial.print("; Promedio temperatura: ");
      Serial.print(promedioTemp); //Serial.print(",");
      Serial.print("; ");
    }

  // Destructor para liberar memoria
   ~Reporte() {
    while(cabeza != nullptr) {
      Nodo* temp = cabeza;
      cabeza = cabeza -> siguiente;
      delete temp; // Libera la memoria del nodo
    }
   }
};

// Creamos objetos
SensorDHT sensor; // Objeto de la clase sensor
RTCDS1302 reloj;  // Objeto de la clase reloj
Reporte reporte(10);  // Objeto del reporte, maximo 10 elementos

float tempMin = 10, tempMax = 30, humMin = 20, humMax = 40;

void setup() {
  Serial.begin(9600);

  pinMode(LED_PIN, OUTPUT); // Configura el led como salida
  digitalWrite(LED_PIN, HIGH); //Enciende el led inicialmente
  pinMode(BUZZER_PIN, OUTPUT);  // Configura el parlante como salida
  digitalWrite(BUZZER_PIN, LOW); // Apaga el buzzer inicialmente
  pinMode(BUTTON_PIN, INPUT_PULLUP);  // Configura el boton como entrada con resistencia pull-up

  reloj.setTiempoInicial();
}

void loop() {
  sensor.leerSensor();
  reloj.actualizar();

  int auxAlarma = 0;

  float humedad = sensor.leerHumedad();
  float temperatura = sensor.leerTemperatura();
  String tiempo = reloj.tiempoActual();

  // Agregamos la medicion al reporte (lista)
  reporte.agregarDato(temperatura, humedad);

  // Mostramos todos los datos 
  Serial.print(humedad); Serial.print(",");
  Serial.print(temperatura); Serial.print(",");
  Serial.println(tiempo);

  if (Serial.available() > 0) {
    String data = Serial.readStringUntil('\n');
       
    if (data.startsWith("SET:")) {
      String rawValues = data.substring(4); // Extraer valores después de "SET:"
      String values[5]; // Arreglo para almacenar los valores separados
      splitString(rawValues, ',', values, 5); // Dividir la cadena en 4 partes

      if(values[0].length() > 0 && values[1].length() > 0 
         && values[2].length() > 0 && values[3].length() > 0
         && values[4].length() > 0) {
            humMin = values[0].toFloat();
            humMax = values[1].toFloat();
            tempMin = values[2].toFloat();
            tempMax = values[3].toFloat();
            auxAlarma = values[4].toFloat();
            Serial.println("OK");
         } else {
          Serial.println("ERROR");
         }
      }
    
    // Mostrar los límites recibidos para depuración
    /*Serial.print("Límites recibidos - HumMin: ");
    Serial.print(humMin);
    Serial.print(" HumMax: ");
    Serial.print(humMax);
    Serial.print(" TempMin: ");
    Serial.print(tempMin);
    Serial.print(" TempMax: ");
    Serial.print(tempMax);
    Serial.print(" axuAlarma: ");
    Serial.println(auxAlarma);*/
  }

  if(digitalRead(BUTTON_PIN) == LOW) auxAlarma = 1;

  bool alarma = false;

  if(humedad < humMin || humedad > humMax
    || temperatura < tempMin || temperatura > tempMax) { // Verificamos que la temperatura y la humedad este dentro de los limites
    alarma = true;
  } else {
    digitalWrite(LED_PIN, LOW);
  }

  if(auxAlarma == 1) { // Si se presiona el boton (en arduino o precessing) se apaga el led temporalmente (10 segundo)
    ledApagado = true;
    tiempoApagado = millis(); // Guarda el tiempo actual
    digitalWrite(LED_PIN, LOW); // Apaga el led
    //Serial.println("Boton presionado, led apagado temporalmente ");
  }

  if(ledApagado && (millis() - tiempoApagado >= duracionApagado)) { // Si pasaron los 10 segudnos y la alarma continua, se enciende de neuvo el led
    ledApagado = false; // Reactiva el led
  }

  if(alarma && !ledApagado) { // Se prende el led automaticamente cuando la alarma esta fuera de lo establecido
    digitalWrite(LED_PIN, HIGH);
    digitalWrite(BUZZER_PIN, HIGH);
  } else {
    if(!alarma) {
      digitalWrite(LED_PIN, LOW);
      digitalWrite(BUZZER_PIN, LOW);
    }
  }

  delay(1000);
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
