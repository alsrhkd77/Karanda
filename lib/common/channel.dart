enum AllChannel {
  balenos,
  serendia,
  calpheon,
  mediah,
  valencia,
  heidel,
  epheria,
  keplan,
  kamasylvia,
  odyllita,
  florin
}

// 외국 채널은 첫글자 대문자
class Channel {
  static final Map<AllChannel, int> kr = {
    AllChannel.balenos: 3,
    AllChannel.serendia: 3,
    AllChannel.calpheon: 3,
    AllChannel.mediah: 3,
    AllChannel.valencia: 3,
    AllChannel.heidel: 3,
    AllChannel.epheria: 3,
    AllChannel.keplan: 3,
    AllChannel.kamasylvia: 3,
    AllChannel.florin: 3,
    AllChannel.odyllita: 1,
  };

  static final Map<AllChannel, String> _krServerName = {
    AllChannel.balenos: '발레노스',
    AllChannel.serendia: '세렌디아',
    AllChannel.calpheon: '칼페온',
    AllChannel.mediah: '메디아',
    AllChannel.valencia: '발렌시아',
    AllChannel.heidel: '하이델',
    AllChannel.epheria: '에페리아',
    AllChannel.keplan: '케플란',
    AllChannel.kamasylvia: '카마실비아',
    AllChannel.florin: '플로린',
    AllChannel.odyllita: '오딜리타',
  };

  static String toKrServerName(AllChannel channel) {
    return _krServerName[channel]!;
  }
}
