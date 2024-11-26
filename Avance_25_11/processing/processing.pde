import processing.serial.*;  // Libreria para la comunicacion serial con arduino
import java.io.PrintWriter;  // Libreria para guardar datos en archivos
import controlP5.*;          // Libreria para botones interactivos

Serial myPort;
PrintWriter output;
ControlP5 cp5;

float temp, hum;
int year, month, day, hour, minute, second;
float tempMin = 10, tempMax = 30, humMin = 20, humMax = 80;

String fileName = "datos_arduino.csv"; // Nombre del archivo a guardar
String[] fileContent;  // Contenido del archivo
String filePath = "lectura.txt"; // Nombre del archivo a leer
boolean showFileContent = false; // Controla si se muestra el contenido

void setup() {
  size(750, 500);
  String portName = Serial.list()[2];
  myPort = new Serial(this, portName, 9600); // Elijo el puerto que uso con el arduino

  cp5 = new ControlP5(this);
  
  cp5.addButton("cargarArchivo") // Crear boton para leer el archivo
     .setPosition(470, 50)
     .setSize(120, 40)
     .setLabel("Leer Archivo");

  myPort.clear();
  myPort.bufferUntil('\n');   // Espera a recibir una línea completa
  
  textSize(25);
  // Crear y abrir el archivo CSV (Excel) para escribir
  output = createWriter(fileName);
  // Escribir encabezados de columnas (ajusta según los datos que recibas)
  output.println("Year;Month;Day;Hour;Minute;Temperature;Humidity");
}

void draw() {
  background(255);

  textSize(25);
  fill(0);
  text("Tiempo actual", 85, 20);
  textSize(20);
  text("Humedad: " + hum + " %", 20, 60);
  text("Temperatura: " + temp + " °C", 20, 90);
  text("Hora: " + nf(hour, 2) + ":" + nf(minute, 2) + ":" + nf(second, 2), 20, 120);

  textSize(25);
  text("Limites alarma", 85, 150);
  textSize(20);
  text("Rango de Humedad:", 20, 180);
  text("Min: " + humMin + " %", 20, 210);
  text("Max: " + humMax + " %", 200, 210);

  text("Rango de Temperatura:", 20, 250);
  text("Min: " + tempMin + " °C", 20, 280);
  text("Max: " + tempMax + " °C", 200, 280);

  // Instrucciones para ajustar los rangos con el teclado
  textSize(15);
  fill(100);
  text("Ajustes de Humedad:", 20, 310);
  text("Min (Aumentar: 'y', Disminuir: 'h')", 20, 330);
  text("Max (Aumentar: 'u', Disminuir: 'j')", 20, 350);

  text("Ajustes de Temperatura:", 20, 380);
  text("Min (Aumentar: 'i', Disminuir: 'k')", 20, 400);
  text("Max (Aumentar: 'o', Disminuir: 'l')", 20, 420);
  
  text("Guardar datos en el archivo:", 20, 450);
  text("Presione: s o S", 20, 470);
  
  // Linea vertical
  stroke(100); // Color gris
  strokeWeight(3);
  line(320, 0, 320, height); // Linea vertical en x = 320
  
  textSize(25);
  fill(0);
  text("Lectura del archivo", 425, 20);
  fill(0);
  textSize(16);
  text("Presiona el boton para leer los datos", 410, 120);
  
  // Mostrar contenido del archivo si esta disponible 
  if (showFileContent && fileContent != null) {
    int y = 160;
    println("Adentro");
    for(String line : fileContent) {
      text(line, 335, y);
      y = y + 20; // Espacio entre lineas
    }
  }
}

void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null) {
    println("Datos recibidos: " + data); // Imprimir para verificar recepción

    // Dividir la cadena y actualizar variables
    String[] parts = data.split(",");
   
   
    if(parts.length >= 8) {
      hum = float(parts[0]);
      temp = float(parts[1]);
    
    
      year = int(parts[2]);
      month = int(parts[3]);
      day = int(parts[4]);
    
      hour = int(parts[5]);
      minute = int(parts[6]);
      second = int(parts[7]);
    }
 
    output.println(year + ";" + month + ";" + day + ";" + hour + ";" + minute + ";" + temp + ";" + hum);
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

  String config = "SET:" + humMin + "," + humMax + "," + tempMin + "," + tempMax + "\n";
  myPort.write(config);
  
  println("humMin = " + humMin);
  println("humMax = " + humMax);
  println("tempMin = " + tempMin);
  println("tempMax = " + tempMax);
  
  if (key == 's' || key == 'S') {
    // Guardar y cerrar el archivo si se presiona la tecla 'S'
    output.flush(); // Asegurar que los datos se guarden
    output.close(); // Cerrar el archivo
    println("Archivo guardado.");
  }
  
  if(myPort.available() > 0) {
    String response = myPort.readStringUntil('\n');
    if(!response.trim().equals("OK")) {
      println("Error updating limits.");
    }
  }
}

// Función asociada al botón
void cargarArchivo() {
  try {
    fileContent = loadStrings(filePath); // Cargar contenido del archivo
    showFileContent = true;              // Mostrar contenido en pantalla
    println("Archivo cargado con éxito:");
    for (String line : fileContent) {
      println(line); // Imprimir cada línea en la consola
    }
  } catch (Exception e) {
    println("Error al cargar el archivo: " + e.getMessage());
  }
}
