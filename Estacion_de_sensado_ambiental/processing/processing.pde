import processing.serial.*;  // Libreria para la comunicacion con arduino
import java.io.PrintWriter;  // Libreria para guardar datos en archivos
//import java.io.FileWriter;  // Libreria para editar archivo en modo append
import controlP5.*;  // Libreria para botones interactivos

Serial myPort; // Pueto serie
PrintWriter output; // Archivo de salida
String data; // Ultima linea leida del puerto serie
ArrayList<String> dataBuffer; // Almacena todos los datos recibidos
ArrayList<String> fileData; // Datos leidos del archivo

PrintWriter outputCSV;  // Archivo excel
String fileName = "registro.csv";  // Nombre del archivo a guardar

PrintWriter outputAlarma;  // Archivo de registro de la alarma
String fileNameAlarma = "registro_alarma.txt";  // Nombre del archivo de registro de la alarma
boolean alarmaActiva = false;  // Variable auxiliar para evitar registros multiles de la misma alarma

ControlP5 cp5; // Objeto de la bibilioteca ControlP5

float temperatura, humedad;
int anio, mes, dia, hora, minuto, segundo;
float tempMinima = 10, tempMaxima = 30, humMinima = 20, humMaxima = 80;
int auxAlarma = 0;

void setup() {
  size(1000, 1000);
  
  // Configuracion puerto serie
  myPort = new Serial(this, Serial.list()[3], 9600);
  myPort.bufferUntil('\n');  // Esperar hasta el fin de cadena
  
  // Creamos el archivo de salida
  output = createWriter("datos_sensores.txt");
  println("Esperando datos . . .");
  
  // Inicializamos las listas de datos
  dataBuffer = new ArrayList<String>();
  fileData = new ArrayList<String>();
  
  // Inicializar ControlP5 y crear botones
  cp5 = new ControlP5(this);
  
  cp5.addButton("Guardar")
     .setPosition(200, 320)
     .setSize(100, 40)
     .setColorBackground(color(0, 200, 0))
     .setLabel("Guardar");
     
  cp5.addButton("Leer")
     .setPosition(700, 320)
     .setSize(100, 40)
     .setColorBackground(color(0, 0, 200))
     .setLabel("Leer");
     
  cp5.addButton("Alarma")
     .setPosition(440, 870)
     .setSize(100, 40)
     .setColorBackground(color(200, 0, 0))
     .setLabel("Apagar alarma");
     
  textSize(25);
  outputCSV = createWriter(fileName); // Crear y abrir el archivo CSV (excel) para escribir
  outputCSV.println("Anio;Mes;Dia;Hora;Minuto;Temperatura;Humedad"); // Escribir encabezado de columnas
}

void draw() {
  background(240);
  
  textSize(25);
  fill(0);
  text("Tiempo actual", 180, 25);
  textSize(20);
  text("Humedad: " + humedad + " %", 180, 60);
  text("Temperatura: " + temperatura + " °C", 180, 90);
  text("Hora: " + nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2), 180, 120);
  
  textSize(25);
  text("Limites alarma", 650, 25);
  textSize(20);
  text("Rango de humedad: ", 520, 50);
  text("Min: " + humMinima + " %", 700, 50);
  text("Max: " + humMaxima + " %", 820, 50);
  
  text("Rango de temperatura: ", 520, 80);
  text("Min: " + tempMinima + " °C", 720, 80);
  text("Max: " + tempMaxima + " °C", 840, 80);
  
  // Instrucciones para ajustar los rangos con el teclado
  textSize(15);
  fill(100);
  text("Ajustes de humedad: ", 520, 110);
  text("Minima (Aumentar: 'y', Disminuir: 'h')", 660, 110);
  text("Maxima (Aumentar: 'u', Disminuir: 'j')", 660, 130);
  
  text("Ajustes de temperatura: ", 520, 160);
  text("Minima (Aumentar: 'i', Disminuir: 'k')", 680, 160);
  text("Maxima (Aumentar: 'o', Disminuir: 'l')", 680, 180);
  
  text("Guardar datos en el archivo: ", 520, 210);
  text("Presione: s o S", 700, 210);
  
  textSize(25);
  fill(0);
  text("Alarma: ", 450, 850);
  textSize(16);
  text("Presiona el boton para desactivar temporalmente la alarma", 300, 940);
  
  textSize(25);
  text("Seccion: Archivos", 400, 250);
  
  // Seccion izquierda (Guardar)
  fill(0);
  textSize(20);
  textAlign(CENTER);
  text("Seccion: Guardar", 250, 300);
  
  textAlign(LEFT);
  text("Ultimo dato leido: ", 50, 400);
  text((data != null ? data : "Ninguno"), 220, 400);
  text("Datos almacenado: " + dataBuffer.size(), 50, 450);
  
  
  // Seccion derecha (Leer)
  textAlign(CENTER);
  text("Seccion: Leer", 750, 300);
  
  // Mostrar datos leidos del archivo
  textAlign(LEFT);
  int y = 400;
  for(String line : fileData) {
    text(line, 600, y);
    y += 20; // Espacio entre lineas
  }
  
  verificarLimites();  // Verifica limites y escribe alarma si es adecuado
}

// Evento del puerto serie
void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('\n');  // Lee los datos del puerto serial
  if(data != null) {
    data = trim(data); // Limpia los datos
    dataBuffer.add(data); // Almacenar en el buffer
    println("Dato recibido: " + data);
    String[] parts = data.split(",");
    
    if(parts.length >= 8) {
      humedad = float(parts[0]);
      temperatura = float(parts[1]);
      anio = int(parts[2]);
      mes = int(parts[3]);
      dia = int(parts[4]);
      hora = int(parts[5]);
      minuto = int(parts[6]);
      segundo = int(parts[7]);
    }
    outputCSV.println(anio + ";" + mes + ";" + dia + ";" + hora + ";" + minuto + ";" + temperatura + ";" + humedad);
  }
}

void keyPressed() {
  if (key == 'y') humMinima += 1;
  if (key == 'h') humMinima -= 1;
  if (key == 'u') humMaxima += 1;
  if (key == 'j') humMaxima -= 1;
  if (key == 'i') tempMinima += 1;
  if (key == 'k') tempMinima -= 1;
  if (key == 'o') tempMaxima += 1;
  if (key == 'l') tempMaxima -= 1; 
  
  auxAlarma = 0;
  
  String config = "SET:" + humMinima + "," + humMaxima + "," + tempMinima + "," + tempMaxima + "," + auxAlarma + "\n";
  myPort.write(config);
  
  if(key == 's' || key == 'S') {  // Guarda y cierra el archivo se se presiona la tecla s
    outputCSV.flush();  // Asegura que los datos se guarden
    outputCSV.close();  // Cierra el archivo
  }
  
  if(myPort.available() > 0) {
    String response = myPort.readStringUntil('\n');
    if(!response.trim().equals("OK")) {
      println("Error al mandar los limites");
    }
  }
}

// Funcion asociada al boton guardar
public void Guardar() {
  if(!dataBuffer.isEmpty()) {
    for(String record : dataBuffer) {
      output.println(record);
    }
    output.flush(); // Asegura que los datos se escriban en el archivo
    dataBuffer.clear();  // Limpia el buffer despues de guardar
  } else {
    println("No hay dato para guardar");
  }
}

// Funcion asociada al boton leer
public void Leer() {
  fileData.clear(); // Limpiar datos previos
  String[] lines = loadStrings("datos_sensores.txt");
  if(lines != null) {
    for(String line : lines) {
      fileData.add(line); // Agregar cada linea al buffer de lectura
    }
    println(fileData);
  } else { 
  println("El archivo esta vacio o no existe");
  }
}

public void Alarma() {
  auxAlarma = 1;
  
  String config = "SET:" + humMinima + "," + humMaxima + "," + tempMinima + "," + tempMaxima + "," + auxAlarma + "\n";
  myPort.write(config);
  
  auxAlarma = 0;
}

void verificarLimites() {  // Funcion para verificar limiter y registrar alarma
  if(humedad < humMinima || humedad > humMaxima || temperatura < tempMinima || temperatura > tempMaxima) {
    if(!alarmaActiva) {  // Solo registra si la alarma aun no se ha activado
      //try {
        // Configura FileWriter en modo append (true)
        //FileWriter fileWriter = new FileWriter(fileNameAlarma, true);
        //PrintWriter outputAlarma = new PrintWriter(fileWriter);
        
        outputAlarma = createWriter(fileNameAlarma);  // Abrir archivo en modo escritura
        
        // Crear mensaje de registro
        String mensaje = "Alarma activada - Fecha: " + anio + "-" + nf(mes, 2) + "-" + nf(dia, 2) +
                        ", Hora: " + nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2) +
                        ", Temperatura: " + temperatura + " °C, Humedad: " + humedad + " %";
        
        // Escribir en el archivo
        outputAlarma.println(mensaje); 
        //println(mensaje);  // Mostrar en la consola
        
        // Cerrar el archivo
        outputAlarma.flush();  // Manda el mensaje al archivo
        outputAlarma.close();  // Cierra el archivo para evitar errores
        alarmaActiva = true;  // Marca que la alarma esta activa
      //} catch (Exception e) {
       // println("Error al escribir en el archivo: " + e.getMessage());
      //}
    //}
  } else {
    alarmaActiva = false;  // Restablece la alarma si los valores vuelven a la normalidad
  }
}
}
