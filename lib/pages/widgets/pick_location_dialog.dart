import 'dart:convert';

import 'package:carpool_training/env_variables.dart';
import 'package:carpool_training/modules/place.dart';
import 'package:carpool_training/style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PickLocationDialog extends StatefulWidget {
  final Function(Place) onSelectLocation;
  const PickLocationDialog({super.key, required this.onSelectLocation});

  @override
  State<PickLocationDialog> createState() => PickLocationDialogState();
}

class PickLocationDialogState extends State<PickLocationDialog> {
  bool isLoading = false;
  final searchController = TextEditingController();
  Future<List<Place>>? futurePlaces;

  Future<List<Place>> getPlaces() async {
    final url = Uri.parse(GOOGLE_API_URL);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': GOOGLE_API_KEY,
        'X-Goog-FieldMask':
            'places.displayName,places.formattedAddress,places.id,places.location',
      },
      body: jsonEncode({
        'textQuery': searchController.text,
        'regionCode': 'MY',
        'pageSize': 7,
      }),
    );

    if (response.statusCode == 200) {
      final json = await jsonDecode(response.body);
      final data = json['places'] as List;

      print(data);
      return data.map((e) => Place.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 250,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SearchBar(
                controller: searchController,
                hintText: 'Search by Location',
                trailing: [
                  IconButton(
                    onPressed: () {
                      setState(() => isLoading = true);
                      futurePlaces = getPlaces();
                      setState(() => isLoading = false);
                    },
                    icon: Icon(Icons.search),
                  ),
                ],
              ),

              SizedBox(height: 30),
              Text('Search Results :'),
              SizedBox(height: 15),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : FutureBuilder(
                      future: futurePlaces,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No data found');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final places = snapshot.data!;
                        return Expanded(
                          child: ListView.builder(
                            itemCount: places.length,
                            itemBuilder: (context, index) {
                              final place = places[index];

                              return GestureDetector(
                                onTap: () {
                                  widget.onSelectLocation(place);
                                  Navigator.pop(context);
                                },
                                child: Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: cardGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(place.formattedAddress),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
