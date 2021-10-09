import 'dart:math';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import 'package:two_zero_four_eight/model/individual_cell.dart';
import 'package:two_zero_four_eight/themes/color.dart';

/// Size of the game borad is by defULT 4x4
const matrixSize = 4;

/// Max Random number to be generated
const maxValue = 100;

/// Value Decideder
const decider = 50;

///Cubit
class GameState extends Equatable {
  ///Constructor
  const GameState(
      {required this.currentGrid,
      this.score = 0,
      this.isGameOver = false,
      this.isGameWon = false});

  ///Game Grid
  final List<List<IndividualCell>> currentGrid;

  ///Total points
  final int score;

  ///IsGame won
  final bool isGameWon;

  ///IsGame over
  final bool isGameOver;
  @override
  List<Object?> get props => [currentGrid, score, isGameWon, isGameOver];

  ///Update new values
  GameState copyWith({
    List<List<IndividualCell>>? currentGrid,
    int? score,
    bool? isGameOver,
    bool? isGameWon,
  }) {
    return GameState(
      currentGrid: currentGrid ?? this.currentGrid,
      score: score ?? this.score,
      isGameWon: isGameWon ?? this.isGameWon,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

///State
class GameCubit extends Cubit<GameState> {
  ///Constructor
  GameCubit({required List<List<IndividualCell>> currentGrid})
      : super(GameState(currentGrid: currentGrid)) {
    emit(state);
  }

  var _currentGrid = [<IndividualCell>[]];
  //var _backupGrid = [<IndividualCell>[]];
  var _flatList = <IndividualCell>[];
  var _randomCell = -1;
  late IndividualCell _cellData;

  // void _copyGrid() {
  //   _backupGrid = List.generate(
  //       matrixSize,
  //       (i) => List.generate(
  //           matrixSize,
  //           (j) => IndividualCell(
  //               x: i,
  //               y: j,
  //               color: Color(ColorConstants.emptyGridBackground),
  //               fontSize: 15.0.sp)));
  // }

  void _flipGrid() {
    for (var i = 0; i < matrixSize; i++) {
      final _row = _currentGrid[i];
      _currentGrid[i] = _row.reversed.toList();
    }
  }

  void _transposeGrid(List<List<IndividualCell>> grid) {
    //New empty grid in _currentGrid
    _generateGrid();
    for (var i = 0; i < matrixSize; i++) {
      for (var j = 0; j < matrixSize; j++) {
        _currentGrid[i][j] = grid[j][i];
      }
    }
  }

  void _gameAlgorithm() {
    //_copyGrid();
    _currentGrid = _currentGrid
        .map(_filter)
        .toList()
        .map(_slide)
        .toList()
        .map(_reduce)
        .toList()
        .map(_filter)
        .toList()
        .map(_slide)
        .toList();
    _generateGrid();
    _generateNewNumber();
    emit(state.copyWith(currentGrid: _currentGrid));
  }

  ///on left swipe
  void onLeft() {
    _gameAlgorithm();
  }

  ///on right swipe
  void onRight() {
    _flipGrid();
    _gameAlgorithm();
  }

  ///on up swipe
  void onUp() {
    _transposeGrid(state.currentGrid);
    _flipGrid();
    _gameAlgorithm();
    _flipGrid();
    _transposeGrid(_currentGrid);
    emit(state.copyWith(currentGrid: _currentGrid));
  }

  ///on down swipe
  void onDown() {
    _transposeGrid(state.currentGrid);
    _gameAlgorithm();
  }

  ///is Game won
  void isGameWon() {}

  ///is Game over
  void isGameOver() {}

  ///reset Gride
  void resetGrid() {}

  ///Initialize Grid
  void initializeGrid() {
    _initialize();
    emit(state.copyWith(currentGrid: _currentGrid));
  }

  void _initialize() {
    _generateGrid();
    _generateNewNumber();
    _generateNewNumber();
  }

  void _generateNewNumber() {
    _flattenList();
    _pickRandomIndex();
    _generateCellData();
    _generateRandomValue();
  }

  void _generateGrid() => _currentGrid = List.generate(
      matrixSize,
      (i) => List.generate(
          matrixSize,
          (j) => IndividualCell(
              x: i,
              y: j,
              value: _currentGrid.length > 1 ? _currentGrid[i][j].value : 0,
              tileColor: _getCellColor(
                  _currentGrid.length > 1 ? _currentGrid[i][j].value : 0),
              fontSize: _getFontSize(
                  _currentGrid.length > 1 ? _currentGrid[i][j].value : 0),
              fontColor: _getFontColor(
                  _currentGrid.length > 1 ? _currentGrid[i][j].value : 0))));

  double _getFontSize(int cellData) {
    var _fontSize = 13.0.sp;

    switch (cellData) {
      case 16:
      case 32:
      case 64:
        _fontSize = 16.0.sp;
        break;
      case 128:
      case 256:
      case 512:
        _fontSize = 18.0.sp;
        break;
      case 1024:
      case 2048:
        _fontSize = 20.0.sp;
        break;
      case 2:
      case 4:
      case 8:
      default:
        break;
    }
    return _fontSize;
  }

  Color _getCellColor(int cellData) {
    var _color = Color(ColorConstants.emptyGridBackground);

    switch (cellData) {
      case 2:
      case 4:
        _color = Color(ColorConstants.gridColorTwoFour);
        break;
      case 8:
      case 64:
      case 256:
        _color = Color(ColorConstants.gridColorEightSixtyFourTwoFiftySix);
        break;
      case 128:
      case 512:
        _color = Color(ColorConstants.gridColorOneTwentyEightFiveOneTwo);
        break;
      case 16:
      case 32:
      case 1024:
        _color = Color(ColorConstants.gridColorSixteenThirtyTwoOneZeroTwoFour);
        break;
      case 2048:
        _color = Color(ColorConstants.gridColorWin);
        break;
      default:
        break;
    }
    return _color;
  }

  Color _getFontColor(int cellData) {
    var _color = Colors.black;

    switch (cellData) {
      case 2:
      case 4:
        _color = Color(ColorConstants.fontColorTwoFour);
        break;
      case 8:
      case 64:
      case 256:
        _color = Color(ColorConstants.gridColorTwoFour);
        break;
      case 128:
      case 512:
        _color = Color(ColorConstants.gridColorWin);
        break;
      case 16:
      case 32:
      case 1024:
        _color = Color(ColorConstants.gridColorEightSixtyFourTwoFiftySix);
        break;
      case 2048:
        _color = Color(ColorConstants.gridColorOneTwentyEightFiveOneTwo);
        break;
      default:
        break;
    }
    return _color;
  }

  void _flattenList() => _flatList = flatten(_currentGrid)
      .map((e) => e.value == 0 ? e : null)
      .whereNotNull()
      .toList();

  void _pickRandomIndex() => _randomCell = Random().nextInt(_flatList.length);

  void _generateCellData() => _cellData = _flatList[_randomCell];

  void _generateRandomValue() {
    final r = Random().nextInt(maxValue);
    _currentGrid[_cellData.x][_cellData.y].value = r > decider ? 4 : 2;
    _currentGrid[_cellData.x][_cellData.y].tileColor =
        Color(ColorConstants.gridColorTwoFour);
  }
}

/// Flatten a list
List<T> flatten<T>(Iterable<Iterable<T>> list) =>
    [for (var sublist in list) ...sublist];

List<IndividualCell> _filter(List<IndividualCell> row) =>
    row.where((element) => element.value != 0).toList();

List<IndividualCell> _slide(List<IndividualCell> row) =>
    List<IndividualCell>.filled(matrixSize - row.length, IndividualCell()) +
    row;

List<IndividualCell> _reduce(List<IndividualCell> row) {
  for (var i = 3; i >= 1; i--) {
    final a = row[i].value;
    final b = row[i - 1].value;
    if (a == b) {
      row[i].value = a + b;
      row[i - 1].value = 0;
    }
  }
  return row;
}
