class BlacklistModel {
  late String discordId;
  late String userName;

  BlacklistModel.fromData(Map data){
    discordId = data['discord_id'];
    userName = data['user_name'];
  }
}