
Future<List<String>> fetchSuggestions(String query) async {
  final String serverUrl = Constant().serverUrl;
  final apiUrl = '$serverUrl/api/suggestions?query=$query';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    print('here is the response');
    print(response);



    if (response.statusCode == 200) {
      // Parse the JSON response and return suggestions
      final jsonResponse = json.decode(response.body);
      List<String> suggestions =  List<String>.from(jsonResponse['suggestions']);
      print(suggestions);

      return suggestions;
    } else {
      print('Error fetching suggestions: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    print('Error fetching suggestions: $error');
    return [];
  }
}