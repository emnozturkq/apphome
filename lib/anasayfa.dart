import 'package:flutter/material.dart';
import 'mqtt_manager.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final double horizontalPadding = 40;
  final double verticalPadding = 25;
  late MqttManager mqttManager;
  List<String> messages = [];
  bool motionDetected = false;
  String distance = "No Data";

  @override
  void initState() {
    super.initState();
    mqttManager = MqttManager();
    mqttManager.onMessageReceived = (message) {
      setState(() {
        messages.add(message);
        // Mesajın 'Motion Detected' olup olmadığını kontrol edebilirsiniz
        if (message == "Motion Detected") {
          motionDetected = true;
        } else {
          motionDetected = false;
        }

        // Mesafe bilgisi alınıyor ve güncelleniyor
        print("Received distance message: $message");
        distance = message;
      });
    };
    mqttManager.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.person,
                    size: 45,
                    color: Color.fromRGBO(7, 15, 43, 1),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hoşgeldin",
                    style: TextStyle(
                        fontSize: 20, color: Color.fromRGBO(7, 15, 43, 1)),
                  ),
                  Text(
                    'Kullanıcı Deneme',
                    style: TextStyle(
                        fontSize: 40, color: Color.fromRGBO(7, 15, 43, 1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(
                thickness: 1,
                color: Color.fromRGBO(7, 15, 43, 1),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Color.fromRGBO(7, 15, 43, 1),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (mqttManager.getStatus() ==
                            'MqttConnectionState.connected') {
                          mqttManager.publishMessage('Hello from Flutter!');
                        }
                      },
                      child: const Text(
                        'Publish Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: motionDetected ? Colors.red : Colors.yellow,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Bu butona basıldığında herhangi bir işlev eklemek istemiyorsanız burayı boş bırakabilirsiniz
                      },
                      child: const Text(
                        'Check Motion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 20),
              child: Text(
                "Mesajlar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromRGBO(7, 15, 43, 1),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 20),
              child: Text(
                "Mesafe: $distance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromRGBO(7, 15, 43, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomCreate extends StatelessWidget {
  const RoomCreate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(7, 15, 43, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
