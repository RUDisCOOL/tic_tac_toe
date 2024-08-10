import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String player = 'X';
  late String robot = player == 'X' ? 'O' : 'X';
  late String _turn = player;

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
          if (winner == player) {
            _showCustomDialog(
              title: const Text(
                'Congratulations!!',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              message: const Text(
                'You have WON the Game!!',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            _showCustomDialog(
              title: const Text(
                'Better Luck Next Time!!',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              message: const Text(
                'Oops! You have LOST the Game!!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        }
        if (!win && count == 9) {
          _resetGame();
          _showCustomDialog(
            title: const Text(
              'Well Tried!!',
              style: TextStyle(
                  color: Color.fromRGBO(253, 216, 53, 1),
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            message: const Text(
              'It\'s a DRAW!!',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
      }
      //BOT MOVE LOGIC HERE
      if (count < 9 && count % 2 != 0) {
        //Easy
        // int botIndex = possibleMoves[Random().nextInt(possibleMoves.length)];

        //Medium
        int botIndex = blockWin(rankList(possibleWins(index)));

        //Impossible

        //Move based on difficulty
        Future.delayed(const Duration(milliseconds: 500), () {
          _move(botIndex);
        });
      }
    }
  }

  int blockWin(Map<int, List<List<int>>> rankedList) {
    int max = 0;
    for (int key in rankedList.keys) {
      if (max < key) {
        max = key;
      }
    }
    int index;
    if (rankedList.isEmpty) {
      index = possibleMoves[Random().nextInt(possibleMoves.length)];
    } else {
      List<int> closestWin = rankedList[max]![0];
      index = closestWin[0];
      for (index in closestWin) {
        if (values[index] == '') {
          break;
        }
      }
    }
    print(index);
    return index;
  }

  Map<int, List<List<int>>> rankList(List<List<int>> possibleWinsList) {
    Map<int, List<List<int>>> rankedList = {};
    for (var list in possibleWinsList) {
      int count = 0;
      for (var index in list) {
        if (values[index] == player) {
          count++;
        }
      }
      if (rankedList.containsKey(count)) {
        rankedList[count]!.add(list);
      } else {
        rankedList[count] = [list];
      }
    }
    return rankedList;
  }

  List<List<int>> possibleWins(int index) {
    List<List<int>> possibleWinsList = [];
    for (var list in winnerIndexList) {
      if (list.contains(index)) {
        bool isPossibleWin = true;
        for (var i in list) {
          if (values[i] == robot) {
            isPossibleWin = false;
            break;
          }
        }
        if (isPossibleWin) possibleWinsList.add(list);
      }
    }
    return possibleWinsList;
  }

  void _resetGame() {
    setState(() {
      values = ['', '', '', '', '', '', '', '', ''];
      possibleMoves = [0, 1, 2, 3, 4, 5, 6, 7, 8];
      _turn = player;
      count = 0;
    });
  }

  void _showCustomDialog({Widget? title, required Widget message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: title,
          content: message,
          actions: [
            Center(
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromARGB(255, 13, 70, 117),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(20),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.pause_rounded,
                      color: Color.fromARGB(255, 80, 80, 80),
                    ),
                    iconSize: 45,
                  ),
                  const Text(
                    'TIC TAC TOE',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 80, 80, 80),
                    ),
                  ),
                  const SizedBox(
                    width: 85,
                  )
                ],
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: deviceHeight - 200,
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, top: 25, bottom: 25 + 85),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color.fromARGB(255, 80, 80, 80),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: GridView.count(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          mainAxisSpacing: 17,
                          crossAxisSpacing: 17,
                          children: List.generate(
                            9,
                            (int index) {
                              return GestureDetector(
                                onTap: () {
                                  if (count % 2 == 0) {
                                    _move(index);
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
                    ),
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
