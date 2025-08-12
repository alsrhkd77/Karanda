class BarteringMastery {
  //beginner, apprentice, skilled, professional, artisan, master, guru
  final String rank;
  final int level;
  final double reductionRate;

  BarteringMastery({
    this.rank = "master",
    this.level = 1,
    this.reductionRate = 0.1723,
  });

  factory BarteringMastery.fromJson(Map json) {
    return BarteringMastery(
      rank: json["rank"],
      level: json["level"],
      reductionRate: json["reduction rate"],
    );
  }

  Map toJson() {
    return {
      "rank": rank,
      "level": level,
      "reduction rate": reductionRate,
    };
  }

  bool isSame(BarteringMastery other) {
    if (rank == other.rank && level == other.level) {
      return true;
    }
    return false;
  }
}
