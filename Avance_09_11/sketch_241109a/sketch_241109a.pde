import processing.serial.*;
Serial myPort;

float temp, hum;
int hour, minute, second;
float tempMin = 10, tempMax = 30, humMin = 20, humMax = 80;

void setup() {
  size(400, 450);
  myPort = new Serial(this, "COM7", 9600); // Elijo el puerto que uso con el arduino

  myPort.clear();
  myPort.bufferUntil('\n');
}

void draw() {
  background(255);

  textSize(16);
  fill(0);
  text("Humedad: " + hum + " %", 20, 50);
  text("Temperatura: " + temp + " °C", 20, 80);
  text("Hora: " + nf(hour, 2) + ":" + nf(minute, 2) + ":" + nf(second, 2), 20, 110);

  text("Rango de Humedad:", 20, 150);
  text("Min: " + humMin + " %", 20, 180);
  text("Max: " + humMax + " %", 200, 180);

  text("Rango de Temperatura:", 20, 220);
  text("Min: " + tempMin + " °C", 20, 250);
  text("Max: " + tempMax + " °C", 200, 250);

  // Instrucciones para ajustar los rangos con el teclado
  textSize(12);
  fill(100);
  text("Ajustes de Humedad:", 20, 300);
  text("Min (Aumentar: 'y', Disminuir: 'h')", 20, 320);
  text("Max (Aumentar: 'u', Disminuir: 'j')", 20, 340);

  text("Ajustes de Temperatura:", 20, 370);
  text("Min (Aumentar: 'i', Disminuir: 'k')", 20, 390);
  text("Max (Aumentar: 'o', Disminuir: 'l')", 20, 410);
}

void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null) {
    String[] parts = data.trim().split(",");

    if (parts[0].startsWith("H:")) hum = float(parts[0].substring(2));
    if (parts[1].startsWith("T:")) temp = float(parts[1].substring(2));

    String[] timeParts = parts[2].substring(5).split(":");
    hour = int(timeParts[0]);
    minute = int(timeParts[1]);
    second = int(timeParts[2]);
  }
}

void keyPressed() {
  if (key == 'y') humMin += 1;
  if (key == 'h') humMin -= 1;
  if (key == 'u') humMax += 1;
  if (key == 'j') humMax -= 1;
  if (key == 'i') tempMin += 1;
  if (key == 'k') tempMin -= 1;
  if (key == 'o') tempMax += 1;
  if (key == 'l') tempMax -= 1;

  String config = "SET:" + humMin + "," + humMax + "," + tempMin + "," + tempMax;
  myPort.write(config);
}
