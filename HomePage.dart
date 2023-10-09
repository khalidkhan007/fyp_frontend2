import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantHomePage extends StatefulWidget {
  @override
  _RestaurantHomePageState createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  bool isDataLoaded = false;
  var parsedData;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> originalData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    //getlocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HOME',
          style: TextStyle(fontFamily: 'Pacifico'),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [

          ElevatedButton(
            onPressed: () {
              // Replace 'item['address']' with the actual path to the restaurant's address
              String restaurantAddress = data.isNotEmpty ? data[0]['address'] : " ";
              calculateDistance(restaurantAddress);
            },
            child: Text("Calculate Distance"),
          ),

          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterData,
            ),
          ),
          Expanded(
            child: isDataLoaded
                ? buildDataList(data)
                : Center(child:CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
  // calculate Distance
  Future<void> calculateDistance(String restaurantAddress) async {
    try {
      // Get the customer's current location
      final Position customerLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Use geocoding to convert the restaurant's address into coordinates
      List<Location> locations = await locationFromAddress(restaurantAddress);
      if (locations.isNotEmpty) {
        double restaurantLatitude = locations[0].latitude;
        double restaurantLongitude = locations[0].longitude;

        // Calculate the distance between the customer's location and the restaurant
        double distance = await Geolocator.distanceBetween(
          customerLocation.latitude,
          customerLocation.longitude,
          restaurantLatitude,
          restaurantLongitude,
        );

        // Print the distance (in meters)
        print('Distance to restaurant: $distance meters');
      } else {
        print('Unable to determine restaurant coordinates from address.');
      }
    } catch (e) {
      print('Error during geocoding or distance calculation: $e');
    }
  }


// this is FetchData function
  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.0.104:8080/customer/signin/home'));

      if (response.statusCode == 200) {

        parsedData = parseJsonResponse(response.body);
        setState(() {
          data = parsedData;
          originalData = parsedData; // Store the original data for filtering.
          isDataLoaded = true;

        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching data: $e');
    }
  }
// this is FilterData function
  void filterData(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all restaurants.
      setState(() {
        data = originalData;
      });
    } else {
      final filteredData = originalData.where((item) {
        final name = item['name'].toString().toLowerCase();
        final address = item['address'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            address.contains(query.toLowerCase());
      }).toList();
      setState(() {
        data = filteredData;
      });
    }
  }
  //parseJsonResponse
  List<Map<String, dynamic>> parseJsonResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed;
  }

//Custom Widgets
  Widget buildDataList(List<Map<String, dynamic>> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          color: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          elevation: 4.0,
          child: Container(
            width: 120,
            height: 120,
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage("Assets/images/13.png"),
                              child: Text(
                                item['name'][0],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Name: ${item['name']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Address: ${item['address']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

