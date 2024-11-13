import 'dart:async';

import 'package:karanda/bdo_news/bdo_news_provider.dart';
import 'package:karanda/bdo_news/models/bdo_event_model.dart';
import 'package:karanda/bdo_news/models/bdo_update_model.dart';

class BdoNewsDataController {
  final _updateStreamController =
      StreamController<List<BdoUpdateModel>>.broadcast();
  final _labUpdateStreamController =
      StreamController<List<BdoUpdateModel>>.broadcast();
  final _eventStreamController =
      StreamController<List<BdoEventModel>>.broadcast();
  final _newEventStreamController =
      StreamController<List<BdoEventModel>>.broadcast();
  final _nearDeadlineEventStreamController =
      StreamController<List<BdoEventModel>>.broadcast();
  List<BdoUpdateModel> _updates = [];
  List<BdoUpdateModel> _labUpdates = [];
  List<BdoEventModel> _events = [];
  List<BdoEventModel> _eventsOriginal = [];

  Stream<List<BdoUpdateModel>> get updates => _updateStreamController.stream;

  Stream<List<BdoUpdateModel>> get labUpdates =>
      _labUpdateStreamController.stream;

  Stream<List<BdoEventModel>> get events => _eventStreamController.stream;

  Stream<List<BdoEventModel>> get newEvents => _newEventStreamController.stream;

  Stream<List<BdoEventModel>> get nearDeadlineEvents =>
      _nearDeadlineEventStreamController.stream;

  static final BdoNewsDataController _instance =
      BdoNewsDataController._internal();

  factory BdoNewsDataController() {
    return _instance;
  }

  BdoNewsDataController._internal() {
    _getEvents();
    _getLabUpdates();
    _getUpdates();
  }

  void subscribeEvents() => _publishEvents();

  void subscribeUpdates() => _publishUpdates();

  void subscribeLabUpdates() => _publishLabUpdates();

  void sortEventsByDeadline(){
    if(_events.isNotEmpty){
      _events.sort((a, b) => a.deadline.compareTo(b.deadline));
      _publishEvents();
    }
  }

  void sortEventsByAdded(){
    if(_events.isNotEmpty){
      _events.sort((a, b) => b.added.compareTo(a.added));
      _publishEvents();
    }
  }

  void shuffleEvents(){
    if(_events.isNotEmpty){
      _events.shuffle();
      _publishEvents();
    }
  }

  void _publishEvents() {
    if (_eventsOriginal.isNotEmpty) {
      _eventStreamController.sink.add(_events);
      _nearDeadlineEventStreamController.sink
          .add(_eventsOriginal.where((element) => element.nearDeadline).toList());
      _newEventStreamController.sink
          .add(_eventsOriginal.where((element) => element.newTag).toList());
    }
  }

  void _publishUpdates() {
    if (_updates.isNotEmpty) {
      _updateStreamController.sink.add(_updates);
    }
  }

  void _publishLabUpdates() {
    if (_labUpdates.isNotEmpty) {
      _labUpdateStreamController.sink.add(_labUpdates);
    }
  }

  Future<void> _getEvents() async {
    List<BdoEventModel> result = await BdoNewsProvider.getEvents();
    result.sort((a, b) => a.deadline.compareTo(b.deadline));
    _eventsOriginal = result;
    _events = result;
    _publishEvents();
  }

  Future<void> _getUpdates() async {
    List<BdoUpdateModel> result = await BdoNewsProvider.getKRUpdates();
    result.sort((a, b) => b.added.compareTo(a.added));
    _updates = result;
    _publishUpdates();
  }

  Future<void> _getLabUpdates() async {
    List<BdoUpdateModel> result = await BdoNewsProvider.getLabUpdates();
    result = result.where((data) => data.major).toList();
    result.sort((a, b) => b.added.compareTo(a.added));
    _labUpdates = result;
    _publishLabUpdates();
  }
}
