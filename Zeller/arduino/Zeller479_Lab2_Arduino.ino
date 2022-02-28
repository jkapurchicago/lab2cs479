
//A0 - EKG
//A1 - Force sensor

void setup() {
  // initialize the serial communication:
  Serial.begin(115200);
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -

}

void loop() {
    Serial.println(analogRead(A1));
//  if((digitalRead(10) == 1)||(digitalRead(11) == 1)){
////    Serial.println('!');
//  }
//  else{
//    // send the value of analog input 0:
//      Serial.println('!');
//      Serial.println('!');
//      Serial.println('!');
//      Serial.println(analogRead(A0));
//  }
  //Wait for a bit to keep serial data from saturating
  delay(10);
}
