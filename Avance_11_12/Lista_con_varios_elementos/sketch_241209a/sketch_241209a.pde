import processing.serial.*;
import controlP5.*;

Serial myPort; // Pueto serie
PrintWriter output; // Archivo de salida
String data; // Ultima linea leida del puerto serie
ArrayList<String> dataBuffer; // Almacena todos los datos recibidos
ArrayList<String> fileData; // Datos leidos del archivo

ControlP5 cp5; // Objeto de la bibilioteca ControlP5

void setup() {
  size(900, 400);
  
  // Configuracion puerto serie
  myPort = new Serial(this, Serial.list()[3], 9600);
  myPort.bufferUntil('\n');
  
  // Creamos el archivo de salida
  output = createWriter("datos_sensores.txt");
  println("Esperando datos . . .");
  
  // Inicializamos las listas de datos
  dataBuffer = new ArrayList<String>();
  fileData = new ArrayList<String>();
  
  // Inicializar ControlP5 y crear botones
  cp5 = new ControlP5(this);
  
  cp5.addButton("Guardar")
     .setPosition(160, 280)
     .setSize(100, 40)
     .setColorBackground(color(0, 200, 0))
     .setLabel("Guardar");
     
  cp5.addButton("Leer")
     .setPosition(635, 280)
     .setSize(100, 40)
     .setColorBackground(color(0, 0, 200))
     .setLabel("Leer");
}

void draw() {
  background(240);
  
  // Dividir la pantalla en dos mitades
  stroke(0);
  line(width / 2, 0, width / 2, height);
  
  // Seccion izquierda (Guardar)
  fill(0);
  textSize(16);
  textAlign(CENTER);
  text("Seccion: Guardar", width / 4, 50);
  
  textAlign(LEFT);
  text("Ultimo dato leido: ", 30, 100);
  text((data != null ? data : "Ninguno"), 30, 120);
  text("Datos almacenado: " + dataBuffer.size(), 30, 150);
  
  
  // Seccion derecha (Leer)
  textAlign(CENTER);
  text("Seccion: Leer", 3 * width / 4, 50);
  
  // Mostrar datos leidos del archivo
  textAlign(LEFT);
  int y = 100;
  for(String line : fileData) {
    text(line, width / 2 + 20, y);
    y += 20; // Espacio entre lineas
  }
}

// Evento del puerto serie
void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('\n');  // Lee los datos del puerto serial
  if(data != null) {
    data = trim(data); // Limpia los datos
    dataBuffer.add(data); // Almacenar en el buffer
    println("Dato recibido: " + data);
    //println(data);
    
    // Guarda en el archivo
    //output.println(data);
    //output.flush();
  }
}

// Funcion asociada al boton guardar
public void Guardar() {
  if(!dataBuffer.isEmpty()) {
    for(String record : dataBuffer) {
      output.println(record);
    }
    //output.println(data);
    output.flush(); // Asegura que los datos se escriban en el archivo
    println("Dato guardado en el archivo");
  } else {
    println("No hay dato para guardar");
  }
}

// Funcion asociada al boton leer
public void Leer() {
  //savedData = "";
  fileData.clear(); // Limpiar datos previos
  String[] lines = loadStrings("datos_sensores.txt");
  if(lines != null) {
    for(String line : lines) {
      fileData.add(line); // Agregar cada linea al buffer de lectura
    }
    println("Datos leidos del archivo: ");
    println(fileData);
    //for(String line : lines) {
      //savedData += line + " ";
    //  println(line);
    //}
  } else { 
  //println("Datos leidos del archivo: " + savedData);
  println("El archivo esta vacio o no existe");
  }
}

// Cerrar el archivo al terminar
void keyPressed() {
  // Cerrar el archivo al presionar cualquier tecla
  output.close();
  exit();
}
