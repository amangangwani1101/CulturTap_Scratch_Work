import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final TextEditingController searchController; // Add this line
  final Function(String) onSuggestionSelected;
  final Function(String) onSuggestionSearch;// Add this line

  SuggestionList({
    required this.suggestions,
    required this.searchController, // Add this line
    required this.onSuggestionSelected,
    required this.onSuggestionSearch,// Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: suggestions.map((suggestion) {
            return InkWell(
              onTap: (){
                searchController.text = suggestion;


                onSuggestionSearch(suggestion);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        searchController.text = suggestion;


                        onSuggestionSearch(suggestion);
                      },
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.watch_later_outlined, size: 25, color: Theme.of(context).primaryColor),
                            onPressed: () {},
                          ),
                          Text(
                            suggestion,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset('assets/images/search_arrow.svg', width: 16.0, height: 16.0),
                      onPressed: () {
                        // Call the onSuggestionSelected callback when suggestion is tapped
                        onSuggestionSelected(suggestion);

                        // Update the search input value
                        searchController.text = suggestion;
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
