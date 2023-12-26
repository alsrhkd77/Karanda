class Blacklist {
  late String discordId;
  late String blockingCode;
  Blacklist({required this.discordId, required this.blockingCode});

  Blacklist.fromData(Map data){
    discordId = data['target_discord_id'];
    blockingCode = data['blocking_code'];
  }
}