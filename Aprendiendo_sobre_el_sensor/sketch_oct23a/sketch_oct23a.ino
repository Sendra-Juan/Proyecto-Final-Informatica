#include <DHT.h>
#include <DHT_U.h>

#define Buzzer 10
#define Led 7
#define Type DHT11
int dhtPin = 3;
DHT HT(dhtPin, Type);
int humidity;
float tempC;
float tempF;
int dt = 200;

void setup()
{
  Serial.begin(9600);
  pinMode(Buzzer, OUTPUT);
  pinMode(Led, OUTPUT);
  HT.begin();
}

void loop() 
{
  humidity = HT.readHumidity();
  tempC = HT.readTemperature();
  tempF = HT.readTemperature(true);

  Serial.print("Humedad relativa: ");
  Serial.print(humidity);

  Serial.print("% Temperatura: ");
  Serial.print(tempC);
  Serial.print("°C / ");
  Serial.print(tempF);
  Serial.println("°F");
  delay(dt);


  /*digitalWrite(Buzzer, HIGH); 
  delay(1000);                   
  digitalWrite(Buzzer, LOW);   
  delay(1000); */

if(humidity >= 85 || humidity <= 15)
  {
    //digitalWrite(Buzzer, HIGH);
    digitalWrite(Led, HIGH);
  }
else
  {
    if(tempC >= 30 || tempC <= 10)
      {
        //digitalWrite(Buzzer, HIGH);
        digitalWrite(Led, HIGH);
      }
    else
      {
        //digitalWrite(Buzzer, LOW);
        digitalWrite(Led, LOW);
      }
  }



}
