import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';

class SlideCountdownClock extends StatefulWidget {
  final Duration duration;
  final TextStyle textStyle;
  final TextStyle separatorTextStyle;
  final String separator;
  final BoxDecoration decoration;
  final SlideDirection slideDirection;
  final VoidCallback onDone;
  final EdgeInsets padding;
  final bool tightLabel;
  final bool shouldShowDays;
  final bool shouldShowHours;

  SlideCountdownClock({
    Key key,
    @required this.duration,
    this.textStyle: const TextStyle(
      fontSize: 100,
      color: Colors.black,
    ),
    this.separatorTextStyle,
    this.decoration,
    this.tightLabel: false,
    this.separator: "",
    this.slideDirection: SlideDirection.Down,
    this.onDone,
    this.shouldShowDays: false,
    this.shouldShowHours: false,
    this.padding: EdgeInsets.zero,
  }) : super(key: key);

  @override
  SlideCountdownClockState createState() =>
      SlideCountdownClockState(duration, shouldShowDays);
}

class SlideCountdownClockState extends State<SlideCountdownClock> {
  SlideCountdownClockState(Duration duration, bool shouldShowDays) {
    timeLeft = duration;
    this.shouldShowDays = shouldShowDays;

    if (timeLeft.inHours > 99) {
      this.shouldShowDays = true;
    }
  }

  bool shouldShowDays;
  Duration timeLeft;
  Stream<DateTime> timeStream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    var time = DateTime.now();
    final initStream =
        Stream<DateTime>.periodic(Duration(milliseconds: 1000), (_) {
      timeLeft -= Duration(seconds: 1);
      if (timeLeft.inSeconds == 0) {
        Future.delayed(Duration(milliseconds: 1000), () {
          if (widget.onDone != null) widget.onDone();
        });
      }
      return time;
    });
    timeStream = initStream.take(timeLeft.inSeconds).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    Widget dayDigits;
    if (timeLeft.inDays > 99) {
      List<Function> digits = [];
      for (int i = timeLeft.inDays.toString().length - 1; i >= 0; i--) {
        digits.add((DateTime time) =>
            ((timeLeft.inDays) ~/ math.pow(10, i) % math.pow(10, 1)).toInt());
      }
      dayDigits = _buildDigitForLargeNumber(
          timeStream, digits, DateTime.now(), 'daysHundreds');
    } else {
      dayDigits = _buildDigit(
        timeStream,
        (DateTime time) => (timeLeft.inDays) ~/ 10,
        (DateTime time) => (timeLeft.inDays) % 10,
        DateTime.now(),
        "Days",
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height / 9,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (shouldShowDays) ? dayDigits : SizedBox(),
          (shouldShowDays) ? _buildSpace() : SizedBox(),
          (widget.separator.isNotEmpty && shouldShowDays)
              ? _buildSeparator()
              : SizedBox(),
          if (widget.shouldShowHours)
            _buildDigit(
              timeStream,
              (DateTime time) => (timeLeft.inHours % 24) ~/ 10,
              (DateTime time) => (timeLeft.inHours % 24) % 10,
              DateTime.now(),
              "Hours",
            ),
          if (widget.shouldShowHours) _buildSpace(),
          if (widget.shouldShowHours)
            (widget.separator.isNotEmpty) ? _buildSeparator() : SizedBox(),
          _buildSpace(),
          /*_buildDigit(
            timeStream,
            (DateTime time) => (timeLeft.inHours % 24) ~/ 10,
            (DateTime time) => (timeLeft.inHours % 24) % 10,
            DateTime.now(),
            "Hours",
          ),
          _buildSpace(),
          (widget.separator.isNotEmpty) ? _buildSeparator() : SizedBox(),
          _buildSpace(),*/
          _buildDigit(
            timeStream,
            (DateTime time) => (timeLeft.inMinutes % 60) ~/ 10,
            (DateTime time) => (timeLeft.inMinutes % 60) % 10,
            DateTime.now(),
            "minutes",
          ),
          _buildSpace(),
          (widget.separator.isNotEmpty) ? _buildSeparator() : SizedBox(),
          _buildSpace(),
          _buildDigit(
            timeStream,
            (DateTime time) => (timeLeft.inSeconds % 60) ~/ 10,
            (DateTime time) => (timeLeft.inSeconds % 60) % 10,
            DateTime.now(),
            "seconds",
          )
        ],
      ),
    );
  }

  Widget _buildSpace() {
    return SizedBox(width: 3);
  }

  Widget _buildSeparator() {
    return AutoSizeText(
      widget.separator,
      style: widget.separatorTextStyle ?? widget.textStyle,
    );
  }

  Widget _buildDigitForLargeNumber(
    Stream<DateTime> timeStream,
    List<Function> digits,
    DateTime startTime,
    String id,
  ) {
    String timeLeftString = timeLeft.inDays.toString();
    List<Widget> rows = [];
    for (int i = 0; i < timeLeftString.toString().length; i++) {
      rows.add(
        Container(
          decoration: widget.decoration,
          padding:
              widget.tightLabel ? EdgeInsets.only(left: 3) : EdgeInsets.zero,
          child: Digit<int>(
            padding: widget.padding,
            itemStream: timeStream.map<int>(digits[i]),
            initValue: digits[i](startTime),
            id: id,
            decoration: widget.decoration,
            slideDirection: widget.slideDirection,
            textStyle: widget.textStyle,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: rows,
        ),
      ],
    );
  }

  Widget _buildDigit(
    Stream<DateTime> timeStream,
    Function tensDigit,
    Function onesDigit,
    DateTime startTime,
    String id,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 9,
              //width: MediaQuery.of(context).size.width/2-10,
              decoration: widget.decoration,
              padding: widget.tightLabel
                  ? EdgeInsets.only(left: 3)
                  : EdgeInsets.zero,
              child: Digit<int>(
                padding: widget.padding,
                itemStream: timeStream.map<int>(tensDigit),
                initValue: tensDigit(startTime),
                id: id,
                decoration: widget.decoration,
                slideDirection: widget.slideDirection,
                textStyle: widget.textStyle,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 9,
              //width: MediaQuery.of(context).size.width/2-10,
              decoration: widget.decoration,
              padding: widget.tightLabel
                  ? EdgeInsets.only(right: 3)
                  : EdgeInsets.zero,
              child: Digit<int>(
                padding: widget.padding,
                itemStream: timeStream.map<int>(onesDigit),
                initValue: onesDigit(startTime),
                decoration: widget.decoration,
                slideDirection: widget.slideDirection,
                textStyle: widget.textStyle,
                id: id,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ClipHalfRect extends CustomClipper<Rect> {
  final double percentage;
  final bool isUp;
  final SlideDirection slideDirection;

  ClipHalfRect({
    @required this.percentage,
    @required this.isUp,
    @required this.slideDirection,
  });

  @override
  Rect getClip(Size size) {
    Rect rect;
    if (slideDirection == SlideDirection.Down) {
      if (isUp)

        ///-1.0 -> 0.0
        rect = Rect.fromLTRB(
            0.0, size.height * -percentage, size.width, size.height);
      else

        /// 0 -> 1
        rect = Rect.fromLTRB(
          0.0,
          0.0,
          size.width,
          size.height * (1 - percentage),
        );
    } else {
      if (isUp)
        rect =
            Rect.fromLTRB(0.0, size.height * (1 + percentage), size.width, 0.0);
      else
        rect = Rect.fromLTRB(
            0.0, size.height * percentage, size.width, size.height);
    }
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class Digit<T> extends StatefulWidget {
  final Stream<T> itemStream;
  final T initValue;
  final String id;
  final TextStyle textStyle;
  final BoxDecoration decoration;
  final SlideDirection slideDirection;
  final EdgeInsets padding;

  Digit({
    @required this.itemStream,
    @required this.initValue,
    @required this.id,
    @required this.textStyle,
    @required this.decoration,
    @required this.slideDirection,
    @required this.padding,
  });

  @override
  _DigitState createState() => _DigitState();
}

class _DigitState extends State<Digit> with SingleTickerProviderStateMixin {
  StreamSubscription<int> _streamSubscription;
  int _currentValue = 0;
  int _nextValue = 0;
  AnimationController _controller;

  bool haveData = false;

  Animatable<Offset> _slideDownDetails = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: Offset.zero,
  );
  Animation<Offset> _slideDownAnimation;

  Animatable<Offset> _slideDownDetails2 = Tween<Offset>(
    begin: const Offset(0.0, 0.0),
    end: Offset(0.0, 1.0),
  );
  Animation<Offset> _slideDownAnimation2;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    _slideDownAnimation = _controller.drive(_slideDownDetails);
    _slideDownAnimation2 = _controller.drive(_slideDownDetails2);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }

      if (status == AnimationStatus.dismissed) {
        _currentValue = _nextValue;
      }
    });

    _currentValue = widget.initValue;
    _streamSubscription = widget.itemStream.distinct().listen((value) {
      haveData = true;
      if (_currentValue == null) {
        _currentValue = value;
      } else if (value != _currentValue) {
        _nextValue = value;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_streamSubscription != null) _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fakeWidget = Opacity(
      opacity: 0.0,
      child: AutoSizeText(
        '9',
        style: widget.textStyle,
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
      ),
    );

    return Container(
      padding: widget.padding,
      alignment: Alignment.center,
      decoration: widget.decoration ?? BoxDecoration(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, w) {
          return Stack(
            fit: StackFit.passthrough,
            overflow: Overflow.clip,
            children: <Widget>[
              haveData
                  ? FractionalTranslation(
                      translation:
                          (widget.slideDirection == SlideDirection.Down)
                              ? _slideDownAnimation.value
                              : -_slideDownAnimation.value,
                      child: ClipRect(
                        clipper: ClipHalfRect(
                          percentage: _slideDownAnimation.value.dy,
                          isUp: true,
                          slideDirection: widget.slideDirection,
                        ),
                        child: AutoSizeText(
                          '$_nextValue',
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0,
                          style: widget.textStyle,
                        ),
                      ),
                    )
                  : SizedBox(),
              FractionalTranslation(
                translation: (widget.slideDirection == SlideDirection.Down)
                    ? _slideDownAnimation2.value
                    : -_slideDownAnimation2.value,
                child: ClipRect(
                  clipper: ClipHalfRect(
                    percentage: _slideDownAnimation2.value.dy,
                    isUp: false,
                    slideDirection: widget.slideDirection,
                  ),
                  child: AutoSizeText(
                    '$_currentValue',
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                    style: widget.textStyle,
                  ),
                ),
              ),
              fakeWidget,
            ],
          );
        },
      ),
    );
  }
}

enum SlideDirection {
  Down,
  Up,
}
