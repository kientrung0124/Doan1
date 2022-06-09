import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:io';
import 'dart:math';






void ShowToask(String message)
{
  Fluttertoast.showToast(
      msg: '$message',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
void main()
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget
{
  @override
  AppState createState()=> AppState();
}

class AppState extends State<HomeApp>
{
  // CHẠY 1 LẦN DUY NHẤT hay dùng để kết nối server hoặc khởi tạo hàm timer để lấy dữ liệu
  IconData iconshowhide = Icons.wb_cloudy_outlined; //Icons.wb_cloudy
  IconData connectionStateIcon = Icons.adb_rounded;

  String clientIdentifier = 'appflutter';
  String mqtt_server = "ngoinhaiot.com";
  String  mqtt_user = "nguoidungmqtt6";
  String  mqtt_pass = "182E8918A7AB4035";
  int mqtt_port = 1111; // esp kết nối mqtt => TCP
  String topicsub = 'nguoidungmqtt6/B';
  String topicpub = 'nguoidungmqtt6/A';

  late mqtt.MqttClient client;
  late mqtt.MqttConnectionState connectionState;

  String ND = "0*C";
  String DA = "0%";
  String TB1 = "Đang tắt";
  String TB2 = "Đang tắt";
  String TB3 = "Đang tắt";
  String TB4 = "Đang tắt";
  String ImgTB1 = "images/off.jpeg";
  String ImgTB2 = "images/off.jpeg";
  String ImgTB3 = "images/off.jpeg";
  String ImgTB4 = "images/off.jpeg";

  int count = 0;

  @override
  void initState()
  {
    super.initState();
    ShowToask("WELCOME TO APP IOT");
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context)
  {
    // TẠO GIAO DIỆN trong Scaffold
    return Scaffold(


      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //Image(image: AssetImage('images/mqtt.jpeg'),width: 50,height: 50,),
            //Icon(Icons.adb_rounded , size: 50,),
            GestureDetector(
              child: Container(
                child: Icon(connectionStateIcon, size: 50.0),

              ),
              onTap:ConnectMQTT,
            ),
            SizedBox(width: 8.0,),
            Text("APP IOT"),
            SizedBox(width: 8.0,),
            Icon(iconshowhide, size: 50.0),

            SizedBox(height: 10.0,),

          ],
        ),
      ),

      body: Container(
        color: Colors.black12,
        child: SingleChildScrollView(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[



              Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[

                      //Icon(Icons.ac_unit , size: 100.0,),
                      Image(image:AssetImage('images/8.jpeg',),width: 80,height: 80,),

                      Text("Nhiệt Độ: ", style: TextStyle(fontSize: 30 , color: Colors.black),),
                      Text(ND, style: TextStyle(fontSize: 30 , color: Colors.black),),

                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),



              Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[

                      //Icon(Icons.ac_unit , size: 100.0,),
                      Image(image:AssetImage('images/8.jpeg',),width: 80,height: 80,),

                      Text("Độ Ẩm: ", style: TextStyle(fontSize: 30 , color: Colors.black),),
                      Text(DA, style: TextStyle(fontSize: 30 , color: Colors.black),),

                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),




              Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[

                      //Icon(Icons.ac_unit , size: 100.0,),
                      GestureDetector(
                        onTap: DK_TB1,
                        child: Image.asset(
                          ImgTB1,
                          width: 80,
                          height: 80,

                        ),
                      ),

                      Text("Đèn 1: ", style: TextStyle(fontSize: 30 , color: Colors.black),),
                      Text(TB1, style: TextStyle(fontSize: 30 , color: Colors.black),),

                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),



              Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[

                      //Icon(Icons.ac_unit , size: 100.0,),
                      GestureDetector(
                        onTap: DK_TB2,
                        child: Image.asset(
                          ImgTB2,
                          width: 80,
                          height: 80,

                        ),
                      ),


                      Text("Đèn 2: ", style: TextStyle(fontSize: 30 , color: Colors.black),),
                      Text(TB2, style: TextStyle(fontSize: 30 , color: Colors.black),),

                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),



              Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[

                      //Icon(Icons.ac_unit , size: 100.0,),
                      GestureDetector(
                        onTap: DK_TB3,
                        child: Image.asset(
                          ImgTB3,
                          width: 80,
                          height: 80,

                        ),
                      ),


                      Text("Đèn 3: ", style: TextStyle(fontSize: 30 , color: Colors.black),),
                      Text(TB3, style: TextStyle(fontSize: 30 , color: Colors.black),),

                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),



              Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[

                      //Icon(Icons.ac_unit , size: 100.0,),
                      GestureDetector(
                        onTap: DK_TB4,
                        child: Image.asset(
                          ImgTB4,
                          width: 80,
                          height: 80,

                        ),
                      ),


                      Text("Đèn 4: ", style: TextStyle(fontSize: 30 , color: Colors.black),),
                      Text(TB4, style: TextStyle(fontSize: 30 , color: Colors.black),),

                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),

              SizedBox(height: 10,),

            ],
          ) ,
        ),
      ),
    );
  }


  void DK_TB1()
  {
    print("Onclick Đèn");

    if(TB1.toString() == "Đang tắt"){
      print("Đèn Tắt");
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB1\":\"1\"}");
        ShowToask("SEND MQTT OK!!!");
      }
    }
    else if(TB1.toString() == "Đang bật"){
      print("Đèn bật");
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB1\":\"0\"}");
        ShowToask("SEND MQTT OK!!!");
      }

    }

  }
  void DK_TB2()
  {
    print("Onclick Quạt");
    if(TB2.toString() == "Đang tắt"){
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB2\":\"1\"}");
        ShowToask("SEND MQTT OK!!!");
      }
    }
    else if(TB2.toString() == "Đang bật"){
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB2\":\"0\"}");
        ShowToask("SEND MQTT OK!!!");
      }

    }
  }

  void DK_TB3()
  {
    print("Onclick Quạt");
    if(TB3.toString() == "Đang tắt"){
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB3\":\"1\"}");
        ShowToask("SEND MQTT OK!!!");
      }
    }
    else if(TB3.toString() == "Đang bật"){
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB3\":\"0\"}");
        ShowToask("SEND MQTT OK!!!");
      }

    }
  }

  void DK_TB4()
  {
    print("Onclick Quạt");
    if(TB4.toString() == "Đang tắt"){
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB4\":\"1\"}");
        ShowToask("SEND MQTT OK!!!");
      }
    }
    else if(TB4.toString() == "Đang bật"){
      if (client.connectionState == mqtt.MqttConnectionState.connected) {
        publish("{\"TB4\":\"0\"}");
        ShowToask("SEND MQTT OK!!!");
      }

    }
  }

  void ConnectMQTT() async {
    client = mqtt.MqttClient(mqtt_server, '');
    client.port = mqtt_port;
    client.logging(on: true);
    client.keepAlivePeriod = 30;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onDisconnected = onDisconnected;
    client.pongCallback = pong;
    clientIdentifier += Random().toString();
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .keepAliveFor(30)
        .withWillTopic('DisconnectMQTT')
        .withWillMessage('DisconnectMQTT')
        .withWillQos(mqtt.MqttQos.atMostOnce);
    client.connectionMessage = connMess;
    try {
      await client.connect(mqtt_user, mqtt_pass);
    }
    catch (e) {
      print(e);
      _disconnect();
    }
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      setState(() {
        connectionState = client.connectionState;
        client.subscribe(topicsub, mqtt.MqttQos.exactlyOnce);
        print('CONNECT MQTT AND SUBSCRIBE TOPIC: $topicsub');
        ShowToask("Connect MQTT OK!!!");
        Img();
      });
    }
    else {
      _disconnect();
      print('Connection failed , state is ${client.connectionState}');
    }
    client.updates.listen(_onMessage);

  }


  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  void onConnected() {
    print('EXAMPLE::OnConnected client callback - Client connection was successful');
  }
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }

  void _disconnect() {
    client.disconnect();
    onDisconnected();
    print('Disconnect Broker MQTT');

  }

  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionState == mqtt.MqttConnectionState.disconnected) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }
  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    final mqtt.MqttPublishMessage recMess = event[0].payload as mqtt.MqttPublishMessage;
    final String message =  mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('MQTT message:${message}');
    String data = message;
    print('Data :${data}');
    var DataJsonObject = json.decode(data);

    print('nhietdo :${DataJsonObject['ND']}');
    print('doam :${DataJsonObject['DA']}');



    setState(() {
      //iconshowhide = Icons.wb_cloudy_outlined; //Icons.wb_cloudy
      ND = DataJsonObject['ND'] + "*C";
      DA = DataJsonObject['DA'] + "%";

      Img();


    });

    //status
    setState(() {
      if(DataJsonObject['TB1'] == "1") {
        print(">>>>>>>>>>>>>>ON 1");
        TB1 = "Đang bật";
        ImgTB1 = "images/on.jpeg";
      }
      else if(DataJsonObject['TB1'] == "0") {
        print(">>>>>>>>>>>>>OFF 1");
        TB1 = "Đang tắt";
        ImgTB1 = "images/off.jpeg";
      }

      if(DataJsonObject['TB2'] == "1") {
        print(">>>>>>>>>>>>>>ON 2");
        TB2 = "Đang bật";
        ImgTB2 = "images/on.jpeg";
      }
      else if(DataJsonObject['TB2'] == "0") {
        print(">>>>>>>>>>>>>OFF 2");
        TB2 = "Đang tắt";
        ImgTB2 = "images/off.jpeg";
      }

      if(DataJsonObject['TB3'] == "1") {
        print(">>>>>>>>>>>>>>ON 3");
        TB3 = "Đang bật";
        ImgTB3 = "images/on.jpeg";
      }
      else if(DataJsonObject['TB3'] == "0") {
        print(">>>>>>>>>>>>>OFF 3");
        TB3 = "Đang tắt";
        ImgTB3 = "images/off.jpeg";
      }

      if(DataJsonObject['TB4'] == "1") {
        print(">>>>>>>>>>>>>>ON 4");
        TB4 = "Đang bật";
        ImgTB4 = "images/on.jpeg";
      }
      else if(DataJsonObject['TB4'] == "0") {
        print(">>>>>>>>>>>>>OFF 4");
        TB4 = "Đang tắt";
        ImgTB4 = "images/off.jpeg";
      }

    });
  }

  void publish(String message){
    if (connectionState == mqtt.MqttConnectionState.connected)
    {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topicpub, MqttQos.exactlyOnce, builder.payload);
      print('Data send:  ${message}');

    }
  }

  void Img(){
    count++;
    if(count == 1){
      iconshowhide = Icons.wb_cloudy;
    }
    else if(count == 2) {
      iconshowhide = Icons.wb_cloudy_outlined;
      count  = 0;
    }
  }
}