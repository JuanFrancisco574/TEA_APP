import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show the initial alert dialog after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAlertDialog());
  }

  // Function to display the initial alert dialog
  void _showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('¡Importante!')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Esta aplicación tiene como objetivo ayudar a padres de familia que sospechan que su hijo podría padecer Trastorno del Espectro Autista (TEA). '
                      'La aplicación funciona mediante un algoritmo de inteligencia artificial que utiliza la versión corta del cuestionario Quantitative Checklist for Autism in Toddlers, '
                      'también conocido como Q-CHAT-10 y otras características. Esta destinada para ser usada en niños con edad menor o igual a 35 meses.',
                ),
                SizedBox(height: 20),
                Text(
                  'Es importante destacar que los resultados arrojados por la aplicación no deberían ser tomados como un diagnóstico médico; más bien como un diagnóstico preliminar que ayuda '
                      'a los padres de familia a evaluar un posible riesgo de TEA en sus hijos. En caso de haber realizado la prueba y haber obtenido riesgo de TEA es recomendable que acuda con un '
                      'especialista lo más pronto posible para obtener un diagnóstico certero.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Entiendo'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TEA Detector'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the SurveyScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurveyScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent, // Button color
            foregroundColor: Colors.white, // Button text color
            textStyle: TextStyle(fontSize: 16),
            minimumSize: Size(200, 60), // Button width and height
            padding: EdgeInsets.symmetric(horizontal: 16), // Button padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Button border radius
            ),
          ),
          child: Text('Iniciar prueba'),
        ),
      ),
    );
  }
}

class SurveyScreen extends StatefulWidget {
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int currentQuestionIndex = 0; // Track the current question index
  List<int> answers = List.filled(9, -1); // Store answers, initialized to -1
  String ageInput = ''; // Store age input for question 7
  List<double> _inputData = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
  List<double>? _outputData;

  // List of questions
  final List<String> questions = [
    'Pregunta 1: ¿Su hijo le mira cuando le llama por su nombre?',
    'Pregunta 2: ¿Su hijo finge (por ejemplo, cuida muñecas, habla por un teléfono de juguete)?',
    'Pregunta 3: Si usted u otro miembro de la familia está visiblemente disgustado, ¿su hijo muestra signos de querer consolarle? de querer consolarles (por ejemplo, acariciándoles el pelo o abrazándoles).',
    'Pregunta 4: Describiría las primeras palabras de su hijo como:',
    'Pregunta 5: ¿Su hijo hace gestos sencillos (por ejemplo, decir adiós con la mano)?',
    'Pregunta 6: ¿Su hijo mira fijamente a la nada sin ningún propósito aparente?',
    'Pregunta 7: Ingrese la edad en meses de su hijo',
    'Pregunta 8: ¿Cuál es el sexo de su hijo?',
    'Pregunta 9: ¿Cuál es la etnia de su hijo?',
  ];

  // Function to get the options based on the question number
  List<Widget> _getOptions() {
    if (currentQuestionIndex <= 5) {
      List<String> options = ['Muchas veces al día', 'Un par de veces al día', 'Unas cuantas veces a la semana', 'Menos de una vez a la semana', 'Nunca'];
      if(currentQuestionIndex == 0 || currentQuestionIndex == 2){ // Options to questions 1 and 7 in QCHAT10
        options = ['Siempre', 'Normalmente', 'Algunas veces', 'Rara vez', 'Nunca'];
      }else if ( currentQuestionIndex == 3 ){ // Options to question 8 in QCHAT10
        options = ['Muy típico', 'Bastante típico', 'Algo inusual', 'Muy inusual', 'Mi hijo no habla'];
      }

      return options.asMap().entries.map((entry) {
        int index = entry.key;
        String option = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0), // Adds vertical margin
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Button text color
              textStyle: TextStyle(fontSize: 16),
              minimumSize: Size(200, 60), // Button width and height
              padding: EdgeInsets.symmetric(horizontal: 16), // Button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Button border radius
              ),
              backgroundColor: answers[currentQuestionIndex] == index ? Colors.blue : Colors.indigoAccent,
            ),
            onPressed: () {
              setState(() {
                answers[currentQuestionIndex] = index; // Store the selected answer
              });
            },
            child: Text(option),
          ),
        );
      }).toList();
    } else if (currentQuestionIndex == 6) {
      // Age input for question 7
      return [
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Edad en meses del niño (rango entre 0 y 35 meses)',
            errorText: ageInput.isNotEmpty && !_isValidAge(ageInput) ? 'Por favor ingrese una edad valida' : null,
          ),
          onChanged: (value) {
            setState(() {
              ageInput = value;
            });
          },
        )
      ];
    } else if (currentQuestionIndex == 7) {
      // Options for question 8
      final options = ['Masculino', 'Femenino'];
      return options.asMap().entries.map((entry) {
        int index = entry.key;
        String option = entry.value;
        return Column(
          children: [
            SizedBox(height: 5), // Add space before the first button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Button text color
                textStyle: TextStyle(fontSize: 16),
                minimumSize: Size(200, 60), // Button width and height
                padding: EdgeInsets.symmetric(horizontal: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Button border radius
                ),
                backgroundColor: answers[currentQuestionIndex] == index ? Colors.blue : Colors.indigoAccent,
              ),
              onPressed: () {
                setState(() {
                  answers[currentQuestionIndex] = index; // Store the selected answer
                });
              },
              child: Text(option),
            ),
            SizedBox(height: 10), // Add space after the button
          ],
        );
      }).toList();
    } else if (currentQuestionIndex == 8) {
      // Options for question 9
      final options = ['Latino', 'Asiático', 'Americano'];
      return options.asMap().entries.map((entry) {
        int index = entry.key;
        String option = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajusta el valor según sea necesario
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Button text color
              textStyle: TextStyle(fontSize: 16),
              minimumSize: Size(200, 60), // Button width and height
              padding: EdgeInsets.symmetric(horizontal: 16), // Button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Button border radius
              ),
              backgroundColor: answers[currentQuestionIndex] == index ? Colors.blue : Colors.indigoAccent,
            ),
            onPressed: () {
              setState(() {
                answers[currentQuestionIndex] = index; // Store the selected answer
              });
            },
            child: Text(option),
          ),
        );
      }).toList();
    } else {
      return [];
    }
  }

  // Function to validate age input for question 7
  bool _isValidAge(String input) {
    final age = int.tryParse(input);
    return age != null && (age > 0 && age <= 35);
  }


  void _nextQuestion() {
    if ((currentQuestionIndex <= 5 && answers[currentQuestionIndex] != -1) ||
        (currentQuestionIndex == 6 && ageInput.isNotEmpty) ||
        (currentQuestionIndex >= 7 && answers[currentQuestionIndex] != -1)) {
      if (currentQuestionIndex == 6) {
        // Store age input as answer for question 7
        answers[currentQuestionIndex] = int.parse(ageInput);
      }
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++; // Move to the next question
        });
      } else {
        // Navigate to the FinalScreen when the last question is answered
        print("..................................................................");
        for (int answer in answers) {
          print(answer);
        }

        // Call the IA model to get the final result
        _runModelAndNavigate();
      }
    } else {
      // Show a snackbar if no answer is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una opción antes de continuar.'),
        ),
      );
    }
  }



  // Function to handle the previous button click
  void _runModelAndNavigate() async {
    try {
      // Load the TFLite interpreter
      // TODO: Add the real model and convert each feacture (Q-10 Answer) to its numeric representation
      final interpreter = await Interpreter.fromAsset('assets/model.tflite');

      var input = [List<double>.from(_inputData)]; // Batch size of 1, 9 features
      var output = List.filled(2, 0.0).reshape([1, 2]); // Output size: [1, 2]

      // Run inference
      interpreter.run(input, output);

      setState(() {
        _outputData = output[0];
      });

      print("Output: $_outputData");

      // Ensure _outputData is not null before using it
      if (_outputData != null) {
        final result = _outputData!; // Use the non-nullable operator (!)

        // Interpret the result (e.g., binary classification)
        String message = result[0] > 0.5
            ? 'Según la información proporcionada, existe un posible riesgo de que su hijo sea diagnosticado con TEA. Consulte con un especialista.'
            : 'Los resultados no sugieren un riesgo significativo de TEA. Consulte con un especialista si tiene dudas.';

        // Navigate to FinalScreen with the result message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FinalScreen(message: message)),
        );
      } else {
        throw Exception('No output data from model');
      }


    } catch (e) {
      print('Error while running the TFLite model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el modelo de IA. Inténtelo de nuevo.'),
        ),
      );
    }
  }


  void _previousQuestion() {
    if (currentQuestionIndex == 0) {
      // If on the first question, go back to the previous screen
      Navigator.pop(context);
    } else {
      setState(() {
        currentQuestionIndex--; // Move to the previous question
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prueba'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the current question number
            Text(
              'Pregunta ${currentQuestionIndex + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display the current question text
            Text(
              questions[currentQuestionIndex],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display the answer options
            ..._getOptions(),
            Spacer(),
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousQuestion, // Handle previous button click
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextQuestion, // Handle next button click
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class FinalScreen extends StatelessWidget {
  final String message;

  // Constructor to accept the message
  FinalScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display a thank you message
            Text(
              'Resultado de la prueba',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Button to go back to the home screen
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Button text color
                textStyle: TextStyle(fontSize: 16),
                minimumSize: Size(200, 60), // Button width and height
                padding: EdgeInsets.symmetric(horizontal: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Button border radius
                ),
                backgroundColor: Colors.indigoAccent,
              ),
              onPressed: () {
                // Pop all routes until the first one (home screen)
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Volver al incio'),
            ),
          ],
        ),
      ),
    );
  }
}
