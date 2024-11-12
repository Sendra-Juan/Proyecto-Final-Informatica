import processing.serial.*;
import java.util.Calendar;

Serial myPort;

void setup() {
  size(400, 200);
  String portName = Serial.list()[3]; // Ajusta al puerto adecuado
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  // Obtener la fecha y hora actual
  Calendar calendar = Calendar.getInstance();
  int year = calendar.get(Calendar.YEAR);
  int month = calendar.get(Calendar.MONTH) + 1; // Los meses empiezan desde 0
  int day = calendar.get(Calendar.DAY_OF_MONTH);
  int hour = calendar.get(Calendar.HOUR_OF_DAY);
  int minute = calendar.get(Calendar.MINUTE);
  int second = calendar.get(Calendar.SECOND);
  
  // Formatear la fecha y hora como un String
  String dateTime = nf(year, 4) + "-" + nf(month, 2) + "-" + nf(day, 2) + " " +
                    nf(hour, 2) + ":" + nf(minute, 2) + ":" + nf(second, 2);
  
  // Enviar la fecha y hora a Arduino
  myPort.write(dateTime);

  // Mostrar la fecha y hora en la ventana de Processing
  background(255);
  textSize(20);
  fill(0);
  text("Fecha y hora: " + dateTime, 20, height / 2);
  
  delay(1000); // Enviar cada segundo
}
