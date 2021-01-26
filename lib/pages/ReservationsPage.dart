import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ke/persistence/models/reservationModel.dart';
import 'package:ke/persistence/models/userModel.dart';
import 'package:ke/persistence/repositories/reservationRepository.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/utils/apiCalls.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/utils/localizationsKE.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationsPage extends StatefulWidget {
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  ApiCalls apiCalls;
  AuthServices _auth;
  ReservationRepository reservationRepository;
  List<ReservationModel> reservations;
  List<ReservationModel> auxReservations;
  CalendarController _calendarController;
  Map<DateTime, List> _listEvents = new Map();
  bool all = true;
  ScrollController _scrollController;
  TextStyle _theme = TextStyle(color: Colors.white, fontSize: 20);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
    loadShared().then((user) => {getReservations(user)});
    initializeDateFormatting();
    _calendarController = CalendarController();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? _theme != TextStyle(color: Colors.indigo, fontSize: 20)
                ? setState(
                    () {
                      _theme = TextStyle(color: Colors.indigo, fontSize: 20);
                      print('setState is called');
                    },
                  )
                : {}
            : _theme != TextStyle(color: Colors.white, fontSize: 20)
                ? setState(() {
                    print('setState is called');
                    _theme = TextStyle(color: Colors.white, fontSize: 20);
                  })
                : {},
      );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarController.dispose();

    super.dispose();
  }

  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (300 - kToolbarHeight);
  }

  void showQrCode(context, ReservationModel reservation) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.indigo),
            child: Center(
                child: Text(
              reservation.nameStore,
              style: TextStyle(color: Colors.white),
            )),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImage(
                    embeddedImage: AssetImage("assets/images/ke.png"),
                    data: reservation.id +
                        "*" +
                        reservation.idStore +
                        "*" +
                        reservation.idUser +
                        "*" +
                        reservation.date +
                        "*")
              ],
            ),
          ),
        ),
      );

  getReservations(String uuid) {
    Map<String, dynamic> query = {
      "idUser": uuid,
    };

    apiCalls.getReservations(query: query).then((value) {
      setState(() {
        reservationRepository = ReservationRepository.fromJson(value);
        auxReservations = reservationRepository.reservations
            .where((element) => element.status == "CREATED")
            .toList();
        reservations = auxReservations;
        for (var i = 0; i < auxReservations.length; i++) {
          DateTime dateTime = DateTime.parse(auxReservations[i].date);
          dateTime = new DateTime(
              dateTime.year, dateTime.month, dateTime.day, 00, 00, 00, 00, 00);
          if (_listEvents.containsKey(dateTime)) {
            _listEvents[dateTime].add(auxReservations[i].nameStore);
          } else {
            _listEvents[dateTime] = new List();
            _listEvents[dateTime].add(auxReservations[i].nameStore);
          }
        }
      });
    });
  }

  Future<String> loadShared() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("useruuid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Virtual KE",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),*/
      body: Container(
        height: MediaQuery.of(context).size.height - 55,
        child: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              leading: Container(),
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 1,
              expandedHeight: 9.0 * 40,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: _theme,
                    child: AutoSizeText(
                      all
                          ? LocalizationsKE.of(context).todasreservaciones
                          : LocalizationsKE.of(context).reservaciones,
                      maxLines: 1,
                    ),
                  ),
                  /*background: Image.asset(
                  "assets/images/supermarket.jpg",
                  fit: BoxFit.cover,
                  // height: 150,
                  width: MediaQuery.of(context).size.width,
                ),*/
                  background: Hero(
                    tag: "calendar",
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(40)),
                        color: Colors.indigo,
                      ),
                      child: Stack(
                        children: [
                          Theme(
                            data: ThemeData.dark(),
                            child: TableCalendar(
                              events: _listEvents,
                              availableCalendarFormats: const {
                                CalendarFormat.month: '',
                              },
                              rowHeight: 40,
                              headerStyle: HeaderStyle(
                                  titleTextStyle: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  )),
                              locale:
                                  LocalizationsKE.of(context).locale.toString(),
                              calendarStyle: CalendarStyle(
                                  weekdayStyle: TextStyle(color: Colors.white),
                                  markersColor: Colors.white,
                                  weekendStyle: TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold),
                                  eventDayStyle: TextStyle(color: Colors.white),
                                  selectedColor: Color.fromRGBO(22, 15, 89, 1)),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(color: Colors.white),
                                  weekendStyle:
                                      TextStyle(color: Colors.greenAccent)),
                              onDaySelected:
                                  (DateTime day, List events, List holidays) {
                                setState(() {
                                  all = false;
                                  reservations = auxReservations
                                      .where((element) =>
                                          (DateTime.parse(element.date).year ==
                                                  day.year &&
                                              DateTime.parse(element.date)
                                                      .month ==
                                                  day.month &&
                                              DateTime.parse(element.date)
                                                      .day ==
                                                  day.day))
                                      .toList();
                                });
                              },
                              calendarController: _calendarController,
                            ),
                          ),
                          Positioned(
                            right: 50,
                            top: 20,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  reservations = !all
                                      ? auxReservations
                                      : auxReservations
                                          .where((element) => (DateTime.parse(
                                                          element.date)
                                                      .year ==
                                                  _calendarController
                                                      .selectedDay.year &&
                                              DateTime.parse(element.date)
                                                      .month ==
                                                  _calendarController
                                                      .selectedDay.month &&
                                              DateTime.parse(element.date)
                                                      .day ==
                                                  _calendarController
                                                      .selectedDay.day))
                                          .toList();
                                  all = !all;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(20),
                                    color: all ? Colors.white : Colors.indigo),
                                child: Text(
                                  LocalizationsKE.of(context).todas,
                                  style: TextStyle(
                                      color:
                                          all ? Colors.indigo : Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
            reservations != null
                ? SliverFixedExtentList(
                    itemExtent: 75,
                    delegate: SliverChildBuilderDelegate((context, index) {
                      DateTime todayDate =
                          DateTime.parse(reservations[index].date).toLocal();
                      var formatter = new DateFormat('dd/MM/yyyy');
                      var fos = new DateFormat.jm();
                      String newDt = DateFormat.yMMMEd(
                              LocalizationsKE.of(context).locale.toString())
                          .format(todayDate);
                      String hour = fos.format(todayDate);
                      String date = formatter.format(todayDate);
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        leading: Container(
                            height: 70,
                            width: 70,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blue.withOpacity(.15),
                                      offset: Offset(1, 1),
                                      blurRadius: 8,
                                      spreadRadius: 1)
                                ],
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.indigoAccent),
                            child: Center(
                              child: AutoSizeText(
                                hour,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        title: AutoSizeText(
                          newDt,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  reservations[index].nameStore != null
                                      ? reservations[index].nameStore
                                      : reservations[index].idStore,
                                  overflow: TextOverflow.fade,
                                )),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.15),
                                        offset: Offset(1, 1),
                                        blurRadius: 8,
                                        spreadRadius: 1)
                                  ],
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(reservations[index].cant.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    CupertinoIcons.person_2_alt,
                                    color: Colors.indigoAccent,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          showQrCode(context, reservations[index]);
                        },
                      );
                    }, childCount: reservations.length))
                : SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
