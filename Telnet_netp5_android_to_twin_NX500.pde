// Creates a telnet client that sends photo capture commands to NX500 telnet server
// tap screen to send shutter trigger to both cameras
// first tap is for login response
// requires Internet Android permissions
// requires oscP5 libary installed in Processing SDK 3.0+

// Written by Andy Modla
// last revision 2016/10/15
// No copyright restriction
// use at you own risk with NX-KS2 hack for Samsung NX500 cameras
// turn on Wifi in camera and press ev+mobile to turn on telnet/ftp

// The results of testing with this code shows too much lag time to
// achieve synchronous shutter release in twin NX500 cameras.

import netP5.*;
//import oscP5.*; // does not use this part of oscP5 library

TcpClient telnetClient1; 
TcpClient telnetClient2; 
String IP1 = "192.168.1.192";  // local network DHCP assigned
String IP2 = "192.168.1.204";
//String IP1 = "192.168.43.163";  // Samsung S6 Hot spot assigned
//String IP2 = "192.168.43.235";
//String IP1 = "192.168.0.100"; // mobile photo net DHCP assigned
//String IP2 = "192.168.0.101";
int bbkg = 0;   // black
int wbkg = 255; // white
int bkg = bbkg;
int port = 23;
boolean shoot = false;
boolean first_tap = false;

void setup() { 
  size(400, 400);
  // Connect to the cameras at telnet port.
  // This code will not run if you haven't
  // previously started a server on this port.
  // log into each camera
  try {
    telnetClient1 = new TcpClient( IP1, port);
    if (telnetClient1 != null) {
      telnetClient1.setName("Right");
      println("name1="+telnetClient1.name());
      println(telnetClient1.getString());
    }
  }
  catch (Exception e) {
    println("Wifi problem "+IP1);
  }
  try {
    telnetClient2 = new TcpClient( IP2, port); 
    if (telnetClient2 != null) {
      telnetClient2.setName("Left");
      println("name2="+telnetClient2.name());
      println(telnetClient2.getString());
    }
  }
  catch (Exception e) {
    println("Wifi problem "+IP2);
  }
} 

void draw() { 
  // Change the background if the shutter released
  background(bkg);
  if (telnetClient1 != null) {
    String rs1= telnetClient1.getString();
    if (rs1 != null && rs1.length() > 0) {
      println("1: "+rs1);
      telnetClient1.getStringBuffer().setLength(0);
      bkg = bbkg;
    }
  }
  if (telnetClient2 != null) {
    String rs2= telnetClient2.getString();
    if (rs2 != null && rs2.length() > 0) {
      println("2: "+rs2);
      telnetClient2.getStringBuffer().setLength(0);
      bkg = bbkg;
    }
  }
  if (shoot) {
    shoot = false;
    telnetClient1.send("st app nx capture single\n");
    telnetClient2.send("st app nx capture single\n");
  }
} 

// keyboard input for debug
void keyPressed() {
  if (key == 's' || key == 'S' || key == 24) {
    bkg = wbkg; 
    println("SHOOT");
    shoot = true;
  } else if (key == 'r' || key == 'R') {
    telnetClient1.send("root\n");
    telnetClient2.send("root\n");
    println("READY");
    first_tap = true;
  } else if (key == 'm' || key == 'M') {
    println("mode1="+telnetClient1.mode());
    println("mode2="+telnetClient2.mode());
  }
}

void mousePressed() {
  if (first_tap) {
    shoot = true;
    bkg = wbkg;
  } else {
    // does telnet login with root
    first_tap = true;
    telnetClient1.send("root\n");
    telnetClient2.send("root\n");
    println("READY TAP");
  }
}