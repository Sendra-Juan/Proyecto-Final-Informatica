#include <DHT.h>

// Nodo para la liste enlazada
struct Nodo {
    float humedad; // Valor del sensor
    float temperatura; 
    Nodo* siguiente;  // Puntero al sieguiente nodo
};

// Pines
#define DHTTYPE DHT11
#define DHTPIN 3

// Clase Reporte
class Reporte {
private:
    Nodo* cabeza; // Puntero a la cabeza de la lista
    int contador; // Contador de datos almacenados

public:
    // Constructor
    Reporte() : cabeza(nullptr), contador(0) {}

    // Metodo para agregar un nuevo dato
    void agregarDato(float nuevaTemperatura, float nuevaHumedad) {
        Nodo* nuevoNodo = new Nodo{nuevaTemperatura, nuevaHumedad, cabeza};  // Creamos un nuevo nodo
        cabeza = nuevoNodo; // Actualizamos la cabeza de la lista
        contador++; // Incrementamos el contador
        //Serial.println("Dato agregado con exito ");
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
        Serial.print("Humedad: "); Serial.println(actual -> humedad); // Imprime el dato actual
        Serial.print("Temperatura: "); Serial.println(actual -> temperatura);
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
      while(actual != nullptr) {
        sumaHum += actual -> humedad;
        sumaTemp +=  actual -> temperatura;

        actual = actual -> siguiente;
      }

      float promedioHum = sumaHum / contador;
      float promedioTemp = sumaTemp / contador;

      //Serial.println("Estadisticas de los datos:");
      Serial.print("Promedio humedad: ");
      Serial.print(promedioHum);
      Serial.print("; Promedio temperatura: ");
      Serial.println(promedioTemp);
    }

  // Destructor para liberar memoria
   ~Reporte() {
    Nodo* actual = cabeza;
    while(actual != nullptr) {
      Nodo* temp = actual;
      actual = actual -> siguiente;
      delete temp; // Libera la memoria del nodo
    }
   }
};

class Sensor {
  private: 
    float humedad;
    float temperatura;
    DHT dht;
  
  public: 
    Sensor() : dht(DHTPIN, DHTTYPE) {
      temperatura = 0;
      humedad = 0;
      dht.begin();
    }

    void generaMedicion() {
      temperatura = random(-10, 40); // Simula mediciones en el rango de -10 a 40
      humedad = random(0, 100);
    }

    float leerHumedad() {
      return humedad;
    }

    float leerTemperatura() {
      return temperatura;
    }
};

// Creamos objetos
Sensor sensor;  // Objeto del sensor virtual
Reporte reporte; // Objeto del reporte


void setup() 
{
  Serial.begin(9600);
  randomSeed(analogRead(0));  // Inicializamos la semilla para valores aleatorios
}

void loop() 
{
  sensor.generaMedicion();

  float humedad = sensor.leerHumedad();
  float temperatura = sensor.leerTemperatura();

  // Agregamos la medicion al reporte (lista)
  reporte.agregarDato(temperatura, humedad);

  // Mostramos todos los datos 
  //reporte.mostrarDatos();

  //Mostramos las estadisticas cada 5 lecturas
  static int lecturas = 0;
  lecturas++;
  if(lecturas % 5 == 0) {
    reporte.mostrarEstadisticas(); // Se muestran las estadisticas y se envian a processing
  }

  delay(1000);
}
