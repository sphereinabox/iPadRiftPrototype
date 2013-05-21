// This requires a RedBearLab BLE shield, and the library must be installed.
// See http://redbearlab.com/bleshield/
// You can buy the shield at the MakerShed: http://www.makershed.com/Bluetooth_Low_Energy_BLE_Arduino_Shield_p/mkrbl1.htm


#include <SPI.h>
#include <ble.h>

const int pin_axisX = A0;
const int pin_axisY = A1;
const int pin_statusConnectedLed = A2;
const int pin_btn_a = 5;
const int pin_btn_b = 3;
const int pin_btn_x = 6;
const int pin_btn_y = 4;
const int pin_btn_stick = 2;
const int pin_btn_start = 7;

static bool status_started = false;

void setup() {
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();

  ble_begin();

  pinMode(pin_statusConnectedLed, OUTPUT);

  pinMode(pin_btn_a, INPUT_PULLUP);
  pinMode(pin_btn_b, INPUT_PULLUP);
  pinMode(pin_btn_x, INPUT_PULLUP);
  pinMode(pin_btn_y, INPUT_PULLUP);
  pinMode(pin_btn_stick, INPUT_PULLUP);
  pinMode(pin_btn_start, INPUT_PULLUP);
}

void loop() {
  if (!ble_connected()) 
  {
    digitalWrite(pin_statusConnectedLed, LOW);
    status_started = false;
  }
  else
  {
    digitalWrite(pin_statusConnectedLed, HIGH);
    // read all the things:
    while (ble_available()) {
    }

    if (!status_started) {
      status_started = true;
      // Workaround for issues where when first connected data was not sending.
      // Allow BLE Shield to send/receive data
      ble_do_events();
      // delay a while before sending data:
      for (int i = 0; i < 15; i++) {
        delay(100);
        ble_do_events();
      }
    }  
  
    // write the current control status
    uint16_t x = analogRead(pin_axisX);
    ble_write((x >> 2) & 0xFF);

    uint16_t y = analogRead(pin_axisY);
    ble_write((y >> 2) & 0xFF);
    
    byte buttons = 0x00;
    if (digitalRead(pin_btn_a) == LOW) 
    {
      buttons |= 0x01;
    }
    if (digitalRead(pin_btn_b) == LOW) 
    {
      buttons |= 0x02;
    }
    if (digitalRead(pin_btn_x) == LOW) 
    {
      buttons |= 0x04;
    }
    if (digitalRead(pin_btn_y) == LOW) 
    {
      buttons |= 0x08;
    }
    if (digitalRead(pin_btn_stick) == LOW) 
    {
      buttons |= 0x10;
    }
    if (digitalRead(pin_btn_start) == LOW) 
    {
      buttons |= 0x20;
    }
    ble_write(buttons);
  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();  
}
