import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _turn = 'X';

  int count = 0;

  List<String> values = ['', '', '', '', '', '', '', '', ''];

  List<int> possibleMoves = [0, 1, 2, 3, 4, 5, 6, 7, 8];

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

  void _move(int index) {
    if (values[index] == '') {
      count++;
      HapticFeedback.lightImpact();
      possibleMoves.remove(index);
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
                      fontSize: 22,
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
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const TextSpan(
                    text: 'Won!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
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
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Draw!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 255, 179, 0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      //BOT MOVE LOGIC HERE
      if (count < 9 && count % 2 != 0) {
        //Easy
        int botIndex = possibleMoves[Random().nextInt(possibleMoves.length)];
        //Medium

        //Impossible

        //Move based on difficulty
        Future.delayed(const Duration(milliseconds: 500), () {
          _move(botIndex);
        });
      }
    }
  }

  void _resetGame() {
    setState(() {
      values = ['', '', '', '', '', '', '', '', ''];
      possibleMoves = [0, 1, 2, 3, 4, 5, 6, 7, 8];
      _turn = 'X';
      count = 0;
    });
  }

  void _showCustomDialog(Widget message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
    var deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: deviceHeight - 200,
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: const Color.fromARGB(255, 74, 74, 74),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.antiAlias,
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
                              _move(index);
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
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
