import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(VoiceThemeApp());
}

class VoiceThemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Theme Switcher',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: VoiceThemeScreen(),
    );
  }
}

class VoiceThemeScreen extends StatefulWidget {
  @override
  _VoiceThemeScreenState createState() => _VoiceThemeScreenState();
}

class _VoiceThemeScreenState extends State<VoiceThemeScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _command = "Tap to Speak";
  bool _isDarkMode = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Glow Animation for the Mic Button
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _command = result.recognizedWords;
            });

            if (_command.toLowerCase().contains("light")) {
              setState(() => _isDarkMode = false);
            } else if (_command.toLowerCase().contains("dark")) {
              setState(() => _isDarkMode = true);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDarkMode
              ? [Colors.black87, Colors.black]
              : [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Voice-Controlled Theme",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Smooth Fade Animation for Text
              AnimatedOpacity(
                duration: Duration(milliseconds: 600),
                opacity: 1.0,
                child: Text(
                  "Say: 'Turn on the Light' or 'Go Dark Mode'",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Animated Theme Icon (Sun/Moon)
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Icon(
                  _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  key: ValueKey<bool>(_isDarkMode),
                  size: 120,
                  color: _isDarkMode ? Colors.yellowAccent : Colors.orangeAccent,
                ),
              ),
              SizedBox(height: 30),

              // Animated Mic Button with Glow Effect
              ScaleTransition(
                scale: _glowController,
                child: FloatingActionButton(
                  onPressed: _listen,
                  backgroundColor: _isListening ? Colors.red : Colors.white,
                  elevation: 5,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.white : Colors.blueAccent,
                    size: 30,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Animated Command Text
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: 1.0,
                child: Text(
                  _command,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
