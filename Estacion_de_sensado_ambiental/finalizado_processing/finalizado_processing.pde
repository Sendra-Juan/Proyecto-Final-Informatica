import processing.serial.*;  // Libreria para la comunicacion con arduino
import java.io.PrintWriter;  // Libreria para guardar datos en archivos
import java.io.FileWriter;  // Libreria para editar archivo en modo append
import controlP5.*;  // Libreria para botones interactivos

Serial myPort; // Pueto serie
PrintWriter output; // Archivo de salida
String data; // Ultima linea leida del puerto serie
ArrayList<String> dataBuffer; // Almacena todos los datos recibidos
ArrayList<String> fileData; // Datos leidos del archivo

PrintWriter outputCSV;  // Archivo excel
String fileName = "registro.csv";  // Nombre del archivo a guardar

//PrintWriter outputAlarma;  // Archivo de registro de la alarma
String fileNameAlarma = "registro_alarma.txt";  // Nombre del archivo de registro de la alarma
boolean alarmaActiva = false;  // Variable auxiliar para evitar registros multiles de la misma alarma

ControlP5 cp5; // Objeto de la bibilioteca ControlP5

float temperatura, humedad;
int anio, mes, dia, hora, minuto, segundo;
float tempMinima = 10, tempMaxima = 30, humMinima = 20, humMaxima = 80;
int auxAlarma = 0;

color fondoGeneral = color(240, 248, 255);
color fondoPanel = color(220);
color textoGeneral = color(50);


void setup() {
  size(1000, 1000);
  
  println(Serial.list()[2]);
  
  // Configuracion puerto serie
  myPort = new Serial(this, Serial.list()[2], 9600);
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
     .setPosition(200, 400)
     .setSize(100, 40)
     .setColorBackground(color(0, 200, 5))  // Verde suave
     .setColorForeground(color(0, 150, 0))  //Efecto al pasar el mouse
     .setColorLabel(color(255))  // Tecto blanco
     .setLabel("Guardar");
     
  cp5.addButton("Leer")
     .setPosition(700, 250)
     .setSize(100, 40)
     .setColorBackground(color(0, 0, 200))
     .setColorForeground(color(0, 0, 150))
     .setColorLabel(color(255))
     .setLabel("Leer");
     
  cp5.addButton("Alarma")
     .setPosition(200, 530)
     .setSize(100, 40)
     .setColorBackground(color(200, 0, 0))
     .setColorForeground(color(150, 0, 0))
     .setLabel("Apagar alarma");
     
  cp5.addButton("Apagar")
     .setPosition(700, 930)
     .setSize(100, 40)
     .setColorBackground(color(200, 0, 0))
     .setColorForeground(color(150, 0, 0))
     .setLabel("Apagar programa");
     
  textSize(25);
  outputCSV = createWriter(fileName); // Crear y abrir el archivo CSV (excel) para escribir
  outputCSV.println("Anio;Mes;Dia;Hora;Minuto;Temperatura;Humedad"); // Escribir encabezado de columnas
  
  // Dibuja paneles de fondo
  fill(220);  // Color claro
  stroke(0);  // Borde negro
  rect(20, 20, 960, 150, 10);  // Panel "Tiempo actual" (redondeado)

}

void draw() {
  background(fondoGeneral);  // Fondo general
  textFont(createFont("Arial", 20));
  
  // Panel tiempo actual
  fill(fondoPanel);
  rect(20, 20, 960, 150, 10);
  fill(textoGeneral);
  textAlign(CENTER);
  textSize(25);
  text("Tiempo Actual", width / 2, 50);
  
  textAlign(LEFT);
  text("Humedad: " + humedad + " %", 40, 90);
  text("Temperatrua: " + temperatura + " °C", 40, 120);
  text("Hora: " + nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2), 40, 150);
  
  //text("Limites alarma", 650, 25);
  textSize(22);
  text("Rango de humedad: ", 490, 100);
  text("Min: " + humMinima + " %", 720, 100);
  text("Max: " + humMaxima + " %", 850, 100);
  
  text("Rango de temperatura: ", 490, 140);
  text("Min: " + tempMinima + " °C", 720, 140);
  text("Max: " + tempMaxima + " °C", 850, 140);
  
  // Panel Guardar
  fill(fondoPanel);
  rect(20, 190, 480, 280, 10);
  fill(textoGeneral);
  text("Guardar Datos", 190, 230);
  textAlign(LEFT);
  text("Ultimo dato leido: ", 50, 270);
  text((data != null ? data : "Ninguno"), 50, 300);
  text("Datos almacenado: " + dataBuffer.size(), 50, 350);
  
  // Panel Leer 
  fill(fondoPanel);
  rect(520, 190, 460, 670, 10);
  fill(textoGeneral);
  text("Leer Datos", 700, 230);
  
  // Panel Alarma
  fill(fondoPanel);
  rect(20, 490, 480, 140, 10);
  fill(textoGeneral);
  text("Desactivar Alarma", 170, 520);
  textSize(20);
  text("Presiona para desactivar temporalmente la alarma", 40,600);
  
  // Instrucciones para ajustar los rangos con el teclado
  fill(fondoPanel);
  rect(20, 650, 480, 330, 10);
  fill(textoGeneral);
  textSize(25);
  text("Instruciones operador", 130, 690);
  textSize(20);
  text("Ajustes de humedad: ", 40, 750);
  text("Minima (Aumentar: 'y', Disminuir: 'h')", 170, 780);
  text("Maxima (Aumentar: 'u', Disminuir: 'j')", 170, 800);
  
  text("Ajustes de temperatura: ", 40, 840);
  text("Minima (Aumentar: 'i', Disminuir: 'k')", 170, 870);
  text("Maxima (Aumentar: 'o', Disminuir: 'l')", 170, 890);
  
  text("Guardar datos en el archivo: ", 40, 930);
  text("Presione: s o S", 170, 960);
  
  // Panel apagar
  fill(fondoPanel);
  rect(520, 880, 460, 100, 10);
  fill(textoGeneral);
  text("Presione para terminar la ejecucion", 590, 910);
  
  // Mostrar datos leidos del archivo
  textAlign(LEFT);
  int y = 350;
  for(String line : fileData) {
    text(line, 600, y);
    y += 20; // Espacio entre lineas
    if(y >= 840) {
      return; // Solo muetra las primeras 21 lineas del archivo
    }
  }
  
  verificarLimites();  // Verifica limites y escribe alarma si es adecuado
  //println("Ruta del archivo: " + sketchPath(fileNameAlarma));
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
}

// Funcion asociada al boton guardar
public void Guardar() {
  if(!dataBuffer.isEmpty()) {
    for(String record : dataBuffer) {
      if(!esCadenaProhibida(record)) {  // Verifica si la cadena no esta prohibida
        output.println(record);
      }
    }
    output.flush();  // Asegura que los datos se escriban en el archivo
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

public void Apagar() {
  exit();
}

// Funcion auxiliar para compronar si una cadena esta prohibida
private boolean esCadenaProhibida(String cadena) {
  String[] cadenaProhibida = {"OK", "ERROR", "DEBUG"}; // Lista de cadenas no permitidas
  for(String prohibida : cadenaProhibida) {
    if(cadena.contains(prohibida)) {  // Verifica si la cadena contiene alguna prohibida
      return true; // Es una cadena prohibida
    }
  }
  return false; // La cadena es valida
}

void verificarLimites() {  // Funcion para verificar limiter y registrar alarma
  if(humedad < humMinima || humedad > humMaxima || temperatura < tempMinima || temperatura > tempMaxima) {
    if(!alarmaActiva) {  // Solo registra si la alarma aun no se ha activado
      try {
        // Crear mensaje de registro
        String mensaje = "Alarma activada - Fecha: " + anio + "-" + nf(mes, 2) + "-" + nf(dia, 2) +
                        ", Hora: " + nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2) +
                        ", Temperatura: " + temperatura + " C, Humedad: " + humedad + " %";
        
        String rutaCompleta = "C:/utn/2024/Informatica_ll/Proyecto_final/Estacion_de_sensado_ambiental/finalizado_processing/registro_alarma.txt";
        
        // Escribir en el archivo
        FileWriter fileAlarma = new FileWriter(rutaCompleta, true); 
        
        fileAlarma.write(mensaje + System.lineSeparator());  // Escribe el mensaje en el archivo con un salto de linea
        println(mensaje);  // Mostrar en la consola
        
        // Cerrar el archivo
        fileAlarma.flush();  // Manda el mensaje al archivo
        fileAlarma.close();  // Cierra el archivo para evitar errores
        
        alarmaActiva = true;  // Marca que la alarma esta activa
      } catch (IOException e) {
        println("Error al escribir en el archivo: " + e.getMessage());
      }
    } 
  } else {
    alarmaActiva = false;  // Restablece la alarma si los valores vuelven a la normalidad
  }
}
