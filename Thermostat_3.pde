 /*
    * Socket App
    *
    * A simple socket application example using the WiShield 1.0
    */

    #include <WiShield.h>
    #include <OneWire.h>
	#include <DallasTemperature.h>
    //#include <MsTimer2.h>
    //#include <SHT1x.h>
    //jonoxer SHT15 lib
    //http://github.com/practicalarduino/SHT1x/

    //-------------------------------------------------------------------------------------------------
    //
    // WiShield data
    //
    //-------------------------------------------------------------------------------------------------
    //Wireless configuration defines ----------------------------------------
    #define WIRELESS_MODE_INFRA   1
    #define WIRELESS_MODE_ADHOC   2
    //Wireless configuration parameters ----------------------------------------
    unsigned char local_ip[]       = {XXX,XXX,XXX,XXX};  // IP address of WiShield
    unsigned char gateway_ip[]     = {XXX,XXX,XXX,XXX};     // router or gateway IP address
    unsigned char subnet_mask[]    = {XXX,XXX,XXX,XXX}; // subnet mask for the local network
    const prog_char ssid[] PROGMEM = {"XXXXXXXXXX"};        // max 32 bytes
    unsigned char security_type    = 2;               // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2
    // WPA/WPA2 passphrase
    const prog_char security_passphrase[] PROGMEM = {"XXXXXXXXXX"};   // max 64 characters
    // WEP 128-bit keys
    prog_uchar wep_keys[] PROGMEM = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // Key 0
                                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // Key 1
                                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // Key 2
                                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}; // Key 3
    // setup the wireless mode
    // infrastructure - connect to AP
    // adhoc - connect to another WiFi device
    unsigned char wireless_mode = WIRELESS_MODE_INFRA;
    unsigned char ssid_len;
    unsigned char security_passphrase_len;
    //---------------------------------------------------------------------------


    //-------------------------------------------------------------------------------------------------
    //
    //define(s), declaration(s) and global state data
    //
    //-------------------------------------------------------------------------------------------------
    
    //timer interrupt flag
    volatile boolean intTimer;
    //global temp (F) and humidity data
    extern char buffer[5];
    
    float g_temperature;
    int furnace_stage = 0;  
    int furnace_state = 0;  
    int g_humidity;
    int i = 0;
    
    char g_temperature_str[6];
    char response[5];
    
    char outBuffer[20], valor1;
int valor;

    

void clearInBuffer(){
memset(buffer, 0, sizeof(buffer)); // clears IN buffer

}

void clearOutBuffer(){
memset(outBuffer, 0, sizeof(outBuffer)); //clear OUT buffer
}

// Sensor
// pin connected to sensor
int tempPin = 8;
// define the onewire obj needed for connecting to onewire components
OneWire oneWire(tempPin);
// define dallas obj, makes it easier to read temp
DallasTemperature tempSens(&oneWire);

   
void setup()
    {
      // Setup pins to control relays.
      pinMode(5, OUTPUT);
      pinMode(7, OUTPUT);
      // Setup pins to control LEDs
      pinMode(3, OUTPUT);
      pinMode(4, OUTPUT);
      pinMode(6, OUTPUT);      
      
    //#ifdef DEBUGPRINT
       //setup output for debugging...
       Serial.begin(57600);
    //#endif //DEBUGPRINT

       //set up global state data
       intTimer = false;
       //g_temperature = 0;
       //g_humidity = 0;

       //init the WiShield
       Serial.println("Start Wifi Initialization");
       WiFi.init();

       
 Serial.println("Start Temperature Sensor initialization");

    tempSens.begin(); 
    Serial.println("Start loop");

//Test outputs

//         digitalWrite(3, HIGH);
//         digitalWrite(4, HIGH);
//         digitalWrite(6, HIGH);
//         delay(1000);
//         digitalWrite(3, LOW);
//         digitalWrite(4, LOW);
//         digitalWrite(6, LOW);
//         digitalWrite(5,HIGH);
//         digitalWrite(7,HIGH);
//
//         delay(1000);
//         digitalWrite(5, LOW);
//         digitalWrite(7, LOW);
    }
    //-------------------------------------------------------------------------------------------------
    //
    // Arduino loop() code
    //
    //-------------------------------------------------------------------------------------------------
void loop()
{

   i++;

   WiFi.run();
   //clearOutBuffer(); 

   if (i==10000){i = 0;} 
   // Occassoal event

     
   //test = "12345";
   digitalWrite(6, LOW);
     
 
   if(strncmp(buffer,"TC",2) == 0)
     {
     // Temperature call
     digitalWrite(6, HIGH);
     tempSens.requestTemperatures();
     // get the temperature in fahrenheit
     // index 0 as multiple temp sensors can be connected on same bus
     g_temperature = tempSens.getTempCByIndex(0);
     //clearOutBuffer();         
     //dtostrf(g_temperature,6,2,g_temperature_str); 
     dtostrf(g_temperature,10,2,outBuffer); 
     }
   if(strncmp(buffer,"TF",2) == 0)
     {
     // Temperature call
     digitalWrite(6, HIGH);
     tempSens.requestTemperatures();
     // get the temperature in fahrenheit
     // index 0 as multiple temp sensors can be connected on same bus
     g_temperature = tempSens.getTempFByIndex(0);
     //clearOutBuffer();         
     //dtostrf(g_temperature,6,2,g_temperature_str); 
     dtostrf(g_temperature,10,2,outBuffer); 
     }
 
   if(strncmp(buffer,"H0",2) == 0)
     {
     Serial.println("H0 command recd");
     // Heat stage 0 ... turn off furnace
     digitalWrite(5, LOW); 
     digitalWrite(7, LOW);
     furnace_stage = 0;
     //clearOutBuffer();
     dtostrf(0,10,0,outBuffer); 
     //char outBuffer[ ]="0";
     }
     
   if(strncmp(buffer,"H1",2) == 0)
     {
     // Heat stage 1
     digitalWrite(5, HIGH); 
     digitalWrite(7, LOW);
     furnace_stage = 1;
     //clearOutBuffer();
     //char outBuffer[ ]="1";
     dtostrf(furnace_stage,10,0,outBuffer); 
     }

   if(strncmp(buffer,"H2",2) == 0)
     {
     // Heat stage 2
     digitalWrite(5, HIGH); 
     digitalWrite(7, HIGH);
     furnace_stage = 2;
     //clearOutBuffer();
     dtostrf(furnace_stage,10,0,outBuffer); 
     //char outBuffer[ ]="2";
     }  
   if(strncmp(buffer,"H9",2) == 0)
     {
     // Heat stage  - Return current heat stage
     //clearOutBuffer();
     dtostrf(furnace_stage,10,0,outBuffer); 
     //char outBuffer[ ]="STAGE2";
     }


   if(strncmp(buffer,"S0",2) == 0)
     {
     // State 0 ... Off
     furnace_state=0;
     //clearOutBuffer();
     dtostrf(furnace_state,10,0,outBuffer); 
     //char outBuffer[ ]="0";  
     }
   if(strncmp(buffer,"S1",2) == 0)
     {
      // State 1 ... Sleep
     furnace_state=1;
     //clearOutBuffer();
     dtostrf(furnace_state,10,0,outBuffer); 
     //char outBuffer[ ]="1";      
     }
     
   if(strncmp(buffer,"S2",2) == 0)
     {
     // State 2 ... Active
     furnace_state=2;
     //clearOutBuffer();
     dtostrf(furnace_state,10,0,outBuffer); 
     //char outBuffer[ ]="2";  
     }  
     
   if(strncmp(buffer,"S3",2) == 0)
     {
     // State 3 ... Away
     furnace_state=3;
     //clearOutBuffer();
     dtostrf(furnace_state,10,0,outBuffer); 
     //char outBuffer[ ]="3";  
     }
     
   if(strncmp(buffer,"S9",2) == 0)
     {
     // Heat stage  - Return current heat stage
     //clearOutBuffer();
     dtostrf(furnace_state,10,0,outBuffer); 
     //char outBuffer[ ]="STAGE2";
     }
   
    
   
   if(strncmp(buffer,"X0",1) == 0)
     {
     // Null command
     //clearOutBuffer();
     //clearOutBuffer();
     //char outBuffer[ ]="XXX";
     dtostrf(0,10,0,outBuffer);
     }
     
   if (furnace_state == 0){
       digitalWrite(3, LOW);
       digitalWrite(4, LOW);}
       
   if (furnace_state == 2){
       digitalWrite(3, HIGH);
       digitalWrite(4, HIGH);}
       
   if (furnace_state == 1){
       digitalWrite(3, HIGH);
       digitalWrite(4, LOW);}
       
   if (furnace_state == 3){
       digitalWrite(3, LOW);
       digitalWrite(4, HIGH);}
     

   clearInBuffer();
 
}

    
