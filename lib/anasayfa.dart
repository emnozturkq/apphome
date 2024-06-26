import 'package:flutter/material.dart';
import 'mqtt_manager.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late MqttManager mqttManager;
  bool isLightOn = false;
  bool isACOn = false;
  bool isDoorLocked = true;
  double temperature = 0.0; // Sıcaklık verisi, başlangıçta 0.0

  @override
  void initState() {
    super.initState();
    mqttManager = MqttManager(onMessageReceived: _handleMessage);
    mqttManager.connect();
  }

  void _handleMessage(String message) {
    print('Received message for temperature: $message'); // Gelen mesajı yazdır
    try {
      setState(() {
        temperature = double.parse(message.trim());
        print('Parsed temperature: $temperature');
      });
    } catch (e) {
      print('Error parsing temperature: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smarthome'),
        actions: [
          IconButton(
            onPressed: () {
              // Ayarlar sayfasına yönlendirme eklenebilir.
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Hoşgeldiniz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildDeviceCard(
                    'Oda Işıkları',
                    isLightOn,
                    Icons.lightbulb,
                    () {
                      setState(() {
                        isLightOn = !isLightOn;
                        mqttManager.publishMessage(
                            'Living Room Light is ${isLightOn ? 'ON' : 'OFF'}');
                      });
                    },
                  ),
                  _buildDeviceCard(
                    'Sıcaklık',
                    isACOn,
                    Icons.ac_unit,
                    () {
                      // Sıcaklık kartına tıklandığında yeni sayfa aç
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SogutucuKontrol(temperature),
                        ),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    'Oda Kapısı',
                    !isDoorLocked,
                    Icons.lock,
                    () {
                      setState(() {
                        isDoorLocked = !isDoorLocked;
                        mqttManager.publishMessage(
                            'Front Door is ${isDoorLocked ? 'Locked' : 'Unlocked'}');
                      });
                    },
                  ),
                  // Add more cards here as needed
                  _buildDeviceCard(
                    'Perde',
                    isLightOn,
                    Icons.lightbulb,
                    () {
                      setState(() {
                        isLightOn = !isLightOn;
                        mqttManager.publishMessage(
                            'Bedroom Light is ${isLightOn ? 'ON' : 'OFF'}');
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    String title,
    bool isOn,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 16,
                  color: isOn ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 10),
              Icon(
                icon,
                size: 40,
                color: isOn ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SogutucuKontrol extends StatelessWidget {
  final double temperature;

  const SogutucuKontrol(this.temperature, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isFanOn =
        temperature > 30; // Sıcaklık 30 derecenin üstündeyse fan açık olsun

    return Scaffold(
      appBar: AppBar(
        title: Text('Sıcaklık Kontrolü'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sıcaklık: $temperature°C',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // mqtt mesajı gönderilecek...
              },
              child: Text(isFanOn ? 'Fan: ON' : 'Fan: OFF'),
            ),
          ],
        ),
      ),
    );
  }
}
