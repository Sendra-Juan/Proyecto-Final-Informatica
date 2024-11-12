String dateTime = ""; // Variable para almacenar la fecha y hora

void setup() {
  Serial.begin(9600);
}

void loop() {
  // Leer datos desde Processing
  if (Serial.available() > 0) {
    dateTime = Serial.readStringUntil('\n'); // Leer hasta el carácter de nueva línea
    Serial.print("Fecha y hora recibida: ");
    Serial.println(dateTime);                // Imprimir la fecha y hora en el monitor serial
  }

  // Aquí puedes hacer algo con la fecha y hora recibida, como almacenar o procesarla.
}
