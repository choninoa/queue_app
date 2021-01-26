import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ke/pages/MapPage.dart';
import 'package:ke/persistence/models/storeModel.dart';
import 'package:ke/utils/countdown_clock.dart';
import 'package:ke/utils/localizationsKE.dart';

class NextEntryPreview extends StatefulWidget {
  StoreModel store;
  String distance;
  String time;
  List<DateAux> horariosDisponibles;
  Function createReservation;
  NextEntryPreview(
      {this.store,
      this.distance,
      this.time,
      this.horariosDisponibles,
      this.createReservation});
  @override
  _NextEntryPreviewState createState() => _NextEntryPreviewState();
}

class _NextEntryPreviewState extends State<NextEntryPreview>
    with SingleTickerProviderStateMixin {
  int currentPosition = 0;
  PageController _pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height/2,
      width: MediaQuery.of(context).size.width - 20,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.15),
            offset: Offset(1, 1),
            blurRadius: 8,
            spreadRadius: 1)
      ], borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 4,
                  child: Image.asset(
                    "assets/images/Walmart.jpg",
                    fit: BoxFit.cover,
                  )),
              widget.store != null
                  ? Container(
                      //height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width / 3 -
                          40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.store.name,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(widget.store.address),
                          Divider(
                            color: Colors.grey,
                          ),
                          Text(
                            "Opening time:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat.jm()
                                  .format(DateTime.parse(widget.store.openAt)) +
                              " to " +
                              DateFormat.jm().format(
                                  DateTime.parse(widget.store.closedAt))),
                          Divider(
                            color: Colors.grey,
                          ),
                          Row(
                            children: [
                              Text(
                                "Distance: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(widget.distance)
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Time to Destination: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(widget.time)
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
              ),
              Text(
                "Next Entry",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      "assets/images/one-man-walking.png",
                      height: 25,
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      "assets/images/Car.png",
                      height: 25,
                    ),
                  ),
                ],
              )
            ],
          ),
          Divider(
            color: Colors.grey,
          ),
          widget.horariosDisponibles != null
              ? Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width - 40,
                  child: PageView.builder(
                      itemCount: widget.horariosDisponibles.length,
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          currentPosition = page;
                          print(currentPosition);
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.navigate_before,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pageController.animateToPage(
                                        currentPosition - 1,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease);
                                  });
                                }),
                            AutoSizeText(
                              widget.horariosDisponibles[index].text,
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.blue),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.navigate_next,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pageController.animateToPage(
                                        currentPosition + 1,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease);
                                  });
                                }),
                          ],
                        ));
                      }),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          SizedBox(
            height: 5,
          ),
          widget.horariosDisponibles != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("Date",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Time",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          DateFormat.yMMMd(
                                  LocalizationsKE.of(context).locale.toString())
                              .format(DateTime.now()),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            DateFormat.jm(LocalizationsKE.of(context)
                                    .locale
                                    .toString())
                                .format(DateTime.now()),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      width: 0.5,
                      height: 50,
                      color: Colors.grey,
                    ),
                    /*Text(widget.horariosDisponibles[0].dateTime
                            .difference(DateTime.now()).inMinutes.toString()),*/
                    SlideCountdownClock(
                        onDone: () {
                          setState(() {
                            widget.horariosDisponibles
                                .removeAt(currentPosition);
                          });
                        },
                        shouldShowHours: widget
                                    .horariosDisponibles[currentPosition]
                                    .dateTime
                                    .difference(DateTime.now())
                                    .inMinutes >=
                                60
                            ? true
                            : false,
                        textStyle: TextStyle(
                            fontSize: 22,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                        separator: ":",
                        duration: widget
                            .horariosDisponibles[currentPosition].dateTime
                            .difference(DateTime.now())),
                    Text("Time for\nbooking")
                  ],
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Center(
              child: InkWell(
            onTap: () {
              print(widget.horariosDisponibles[currentPosition].dateTime);
              widget
                .createReservation(widget.horariosDisponibles[currentPosition].dateTime);
            },
            child: Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.indigo),
              child: Center(
                child: Text(
                  LocalizationsKE.of(context).reservar,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
