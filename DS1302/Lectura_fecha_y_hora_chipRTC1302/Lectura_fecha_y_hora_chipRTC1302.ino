#include <RtcDS1302.h>
#include <Wire.h>
#include <ThreeWire.h>  // Incluye esta biblioteca para manejar la comunicación

// Configuración de los pines del DS1302
#define PIN_RST 4
#define PIN_DAT 3
#define PIN_CLK 2

// Crear el objeto ThreeWire y el objeto RtcDS1302
ThreeWire myWire(PIN_DAT, PIN_CLK, PIN_RST); // (DAT, CLK, RST)
RtcDS1302<ThreeWire> rtc(myWire);

void setup() {
  Serial.begin(9600);
  
  // Iniciar el RTC
  rtc.Begin();

  // Verificar si el RTC tiene la hora correcta o necesita configuración
  if (!rtc.IsDateTimeValid()) {
    Serial.println("El RTC tiene un valor inválido de tiempo, estableciendo fecha y hora.");
    
    // Establecer fecha y hora actual (usa la hora de compilación)
    rtc.SetDateTime(RtcDateTime(__DATE__, __TIME__));
  }

  // Deshabilitar la protección de escritura para permitir cambios en la fecha/hora si es necesario
  rtc.SetIsWriteProtected(false);

  // Verificar si el RTC se detuvo y reiniciarlo
  if (rtc.GetIsRunning() == false) {
    rtc.SetIsRunning(true);
  }
}

void loop() {
  // Leer fecha y hora
  RtcDateTime now = rtc.GetDateTime();

  // Imprimir fecha en formato AAAA-MM-DD
  Serial.print("Fecha: ");
  Serial.print(now.Year(), DEC);
  Serial.print("-");
  Serial.print(now.Month(), DEC);
  Serial.print("-");
  Serial.print(now.Day(), DEC);

  // Imprimir hora en formato HH:MM:SS
  Serial.print(" Hora: ");
  Serial.print(now.Hour(), DEC);
  Serial.print(":");
  Serial.print(now.Minute(), DEC);
  Serial.print(":");
  Serial.println(now.Second(), DEC);

  delay(1000); // Actualizar cada segundo
}
