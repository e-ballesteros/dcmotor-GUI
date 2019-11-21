const int IN1=9, IN2=10, EN=5;        // Arduino GPIO pins connected to the L293D driver inputs
char dir = 'F';                 // direction of rotation of the dc motor (F/R)
int spd = 0, dutyc = 200;           // speed level = 1 (min) <-> 5 (max);

int last_dutyc;             // Stores the last value before switching off

//char analogPin = 3;

char Param;
bool flag_direction = true;

bool flag_reading = false;      // True when we are reading the speed characters
char input_speed[] = "";             // Value of speed initially empty, received from processing

int digit = 0;

void setup(){
  Serial.begin(9600);           // Start serial communication at 9600 bit/s (baud rate)
  pinMode(IN1,OUTPUT);          // configuration of high level GPIO pin for one rotation direction
  pinMode(IN2,OUTPUT);          // configuration of high level GPIO pin for the opposite direction
  pinMode(EN,OUTPUT);           // GPIO pin connected to the ENABLE pin of the driver
}

void loop(){
  //spd = analogRead(analogPin);
  //dutyc = map(spd,0,1023,170,255);             // mapping of digital voltage into PWM duty-cycle (0255)
  analogWrite(EN,dutyc);                      // activation of PWM output on the ENABLE input to set speed
  Serial.print(spd);
  Serial.print('\n');

  if(flag_direction){
    digitalWrite(IN1, HIGH);      // 5V
    digitalWrite(IN2, LOW);       // Gnd
    flag_direction = false;
  }
  
  if (Serial.available()){                    // check for available data from the apps
    Param = Serial.read();                    // when data is present, read 1 byte (1 character)
    switch (Param){                           // check the value of the received character
      case 'F': digitalWrite(IN1, HIGH);      // 5V
                digitalWrite(IN2, LOW);       // Gnd
                break;
      case 'R': digitalWrite(IN2, HIGH);      // 5V
                digitalWrite(IN1, LOW);       // Gnd
                break;
      case 'B': flag_reading = true;
                break;
      case 'E': flag_reading = false;
                dutyc = atoi(input_speed);
                digit = 0;
                input_speed[0] = '\0';             // We need input_speed to be empty for next time
                break;
      case 'Y': 
                dutyc = last_dutyc;
                break;
      case 'N': 
                last_dutyc = dutyc;
                dutyc = 0;
                break;
      case '0':
                digit++;
                input_speed[digit] = '0';
                break;
      case '1':
                digit++;
                input_speed[digit] = '1';
                break;
      case '2':
                digit++;
                input_speed[digit] = '2';
                break;
      case '3':
                digit++;
                input_speed[digit] = '3';
                break;
      case '4':
                digit++;
                input_speed[digit] = '4';
                break;
      case '5':
                digit++;
                input_speed[digit] = '5';
                break;
      case '6':
                digit++;
                input_speed[digit] = '6';
                break;
      case '7':
                digit++;
                input_speed[digit] = '7';
                break;
      case '8':
                digit++;
                input_speed[digit] = '8';
                break;
      case '9':
                digit++;
                input_speed[digit] = '9';
                break;
                           
    }
  }
  delay (500);
}
