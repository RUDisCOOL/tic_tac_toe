import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _turn = 'O';

  int count = 0;

  List<String> values = ['', '', '', '', '', '', '', '', ''];

  List<List<int>> winnerIndexList = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  (bool, String?) checkWinner(int index) {
    for (List<int> winnerList in winnerIndexList) {
      if (winnerList.contains(index) &&
          values[winnerList[0]] != '' &&
          (values[winnerList[0]] == values[winnerList[1]]) &&
          (values[winnerList[1]] == values[winnerList[2]])) {
        return (true, values[index]);
      }
    }
    return (false, null);
  }

  void _resetGame() {
    setState(() {
      values = ['', '', '', '', '', '', '', '', ''];
      _turn = 'O';
      count = 0;
    });
  }

  void _showCustomDialog(Widget message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: message,
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(Color.fromARGB(255, 13, 70, 117)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchImages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      fetchImages();
    }
  }

  void fetchImages() {
    precacheImage(Image.asset('assets/images/O.png').image, context);
    precacheImage(Image.asset('assets/images/X.png').image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        shadowColor: Colors.black,
        title: Text(
          'TIC TAC TOE',
          style: GoogleFonts.varelaRound(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: const Color.fromARGB(255, 74, 74, 74),
              padding: const EdgeInsets.all(15),
              child: GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(
                  9,
                  (int index) {
                    return GestureDetector(
                      onTap: () {
                        count++;
                        if (values[index] == '') {
                          setState(() {
                            values[index] = _turn;
                            _turn = _turn == 'O' ? 'X' : 'O';
                          });
                          if (count > 4) {
                            var (bool win, String? winner) = checkWinner(index);
                            if (win) {
                              _resetGame();
                              _showCustomDialog(
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Player ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: Image.asset(
                                          'assets/images/$winner.png',
                                          height: 22,
                                          width: 22,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' has ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'WON!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(255, 0, 230, 118),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (!win && count == 9) {
                              _resetGame();
                              _showCustomDialog(
                                RichText(
                                  text: const TextSpan(
                                    text: 'It\'s a ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'DRAW!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(255, 255, 179, 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: values[index] == ''
                              ? const SizedBox()
                              : Image.asset(
                                  'assets/images/${values[index]}.png'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Image.asset(
                      'assets/images/$_turn.png',
                      height: 60,
                      width: 60,
                    ),
                  ),
                  TextSpan(
                    text: '\'s turn',
                    style: GoogleFonts.varelaRound(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
