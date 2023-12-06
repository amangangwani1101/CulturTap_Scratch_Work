List<Map<String, dynamic>> generateCategoryData({
  String specificName = '',
  String name = '',
  String apiEndpoint = '',
}) {
  return [
    {
      'specificName': specificName,
      'name': name,
      'apiEndpoint': apiEndpoint,
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance': <String>[],
      'storyLocation': <String>[],
      'storyTitle': <String>[],
      'storyCategory': <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
  ];
}
