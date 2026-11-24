class PredictionModel {
  String? place_id;
  String? main_text;
  String? secondary_text;
  double? latitude;
  double? longitude;

  PredictionModel({
    this.place_id,
    this.main_text,
    this.secondary_text,
    this.latitude,
    this.longitude,
  });

  PredictionModel.fromJson(Map<String, dynamic> json) {
    place_id = json["place_id"]?.toString();
    main_text = json["structured_formatting"]["main_text"];
    secondary_text = json["structured_formatting"]["secondary_text"];
  }

  /// من استجابة Nominatim Search
  factory PredictionModel.fromNominatim(Map<String, dynamic> json) {
    final name = json['display_name']?.toString() ?? '';
    final parts = name.split(',');
    final main = parts.isNotEmpty ? parts.first.trim() : name;
    final secondary =
        parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

    return PredictionModel(
      place_id: json['place_id']?.toString(),
      main_text: main,
      secondary_text: secondary.isEmpty ? name : secondary,
      latitude: double.tryParse(json['lat']?.toString() ?? ''),
      longitude: double.tryParse(json['lon']?.toString() ?? ''),
    );
  }
}
