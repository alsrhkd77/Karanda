import 'package:karanda/common/channel.dart';
import 'package:karanda/maretta/maretta_model.dart';

class MarettaChannelModel {
  late AllChannel channel;
  late int channelNumber;

  List<MarettaModel> details = [];

  MarettaChannelModel({required this.channel, required this.channelNumber}){
    for(int i=0;i<channelNumber;i++){
      MarettaModel model = MarettaModel(channel: channel, channelNumber: i+1);
      details.add(model);
    }
  }
}