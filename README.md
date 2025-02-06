# Name: Sean Baker 

ID: sbake021 

Class Name: Application Development for Smart Devices 

Assignment Name: MyNewContactList App 

Computer: MacBook Air M2, macOS Sequoia 

IDE: Android Studio Ladybug | 2024.2.1 Patch 1 Build #AI242.19072.14.2412.12360217, built on September 12, 2024 

Runtime Version: 17.0.11+0-17.0.11b1207.24-11852314 aarch64 VM: OpenJDK 64-Bit Server VM by JetBrains s.r.o. 

 

# Purpose 

This project builds an app that can optimize your route using the Google Matrix API. 






![Figure Place Finder Activity](image_placeholder.png)

















PlaceFinder Class 

The PlaceFinder class fetches nearby places using the Google Places API in an Android application. It initializes the Places API client, validates location permissions, and sends a FindCurrentPlaceRequest to retrieve place details like name, formatted address, latitude, longitude, and rating. If the user's location is unavailable, it defaults to Norfolk, VA. The response is parsed into a list of custom Place objects, extracting and structuring details such as street, city, postal code, state, and coordinates. Results are returned asynchronously via a callback interface (PlaceFinderCallback), which provides either the list of places or an error message. The class ensures robust error handling and graceful failure when permissions or API calls encounter issues.





public void fetchNearbyPlaces(LatLng location, PlaceFinderCallback callback) {

    try {

        // Default to Norfolk, VA if the location is null

        if (location != null) {

            Log.d(TAG, "Location is null. Defaulting to Norfolk, VA.");

            location = new LatLng(36.8508, -76.2859); // Latitude and Longitude for Norfolk, VA

        }



        // Define the fields to fetch, including FORMATTED_ADDRESS

        List<com.google.android.libraries.places.api.model.Place.Field> placeFields = Arrays.asList(

                Com.google.android.libraries.places.api.model.Place.Field.NAME,

                com.google.android.libraries.places.api.model.Place.Field.FORMATTED_ADDRESS,

                com.google.android.libraries.places.api.model.Place.Field.LAT_LNG,

                com.google.android.libraries.places.api.model.Place.Field.RATING

        );



        // Create the request

        FindCurrentPlaceRequest request = FindCurrentPlaceRequest.newInstance(placeFields);



        // Check location permissions

        if (ActivityCompat.checkSelfPermission(

                findPlaceActivity,

                Manifest. Permission.ACCESS_FINE_LOCATION

        ) != PackageManager.PERMISSION_GRANTED) {

            callback.onError(new SecurityException("Location permission is not granted."));

            Log.e(TAG, "Location permission is not granted.");

            return;

        }



The private List<Place> parsePlaces(FindCurrentPlaceResponse response) {

Parses the data from google Places and stores the places in a database, making them easily accessible for next time. 





![Figure  Find Place Activity](image_placeholder.png)





FindPlaceActivity 



The FindPlaceActivity class is an Android activity designed to allow users to search for places, filter them by category or radius, and manage the results, integrating with a local database and the Google Places API. Here is a concise explanation of how it works:

Initialization:

UI components like Spinner, Switch, EditText, and ListView are initialized in onCreate. A default location (Norfolk, VA) and radius (5000 meters) are set. The PlaceFinder class fetches places using the Google Places API, and the DatabaseHelper class manages locally saved places.

Fetching Places:

Users can input a search radius and select or type a category.

If a custom address is provided, it is converted to latitude and longitude using AddressUtils. If no address is entered, the App uses the device's current location after verifying location permissions.

The PlaceFinder fetches nearby places asynchronously, updating the foundPlaces list and the ListView with results.

Switching Views:

A Switch toggles between manual category input (EditText) and predefined categories (Spinner). The ViewSwitcher handles toggling between these views.

Handling Search Results:

Search results (foundPlaces) are displayed in a ListView using a custom adapter (MyListAdapter).

Users can select a place from the list, and it gets added to selected places, saved to the database using DatabaseHelper, and shown in a toast notification.

Navigation to Places List:

A button (button_go_to_places_list) bundles the selected places and starts PlacesListActivity to display or manage them further.

Permission Management:

If location permissions are not granted, the App prompts the user. Upon permission approval, it fetches places using the current location.

Data Persistence:

Places from the database are loaded during initialization and combined with fetched places to allow offline access and continuity.







private void findPlaces() {

    if (radiusEditText.getText().toString().isEmpty()) {

        showToastMessage("Please enter a valid radius.");

        return;

    }

    radius = Integer.parseInt(radiusEditText.getText().toString());



    category = categorySwitch.isChecked() ? categoryEditText.getText().toString() :

            (categorySpinner.getSelectedItem() != null ? categorySpinner.getSelectedItem().toString() : "");



    if (category.isEmpty()) {

        showToastMessage("Please enter or select a category.");

        return;

    }



    if (category.equalsIgnoreCase("MyPlaces")) {

        // Show only database places

        found places.clear();

        foundPlaces.addAll(databasePlaces);

        updateListView();

    } else {

        // Handle fetching nearby places for other categories

        String address = addressEditText.getText().toString().trim();

        if (!address.isEmpty()) {

            LatLng addressLatLng = AddressUtils.getLatLngFromAddress(address, this);

            if (addressLatLng != null) {

                latitude = addressLatLng.latitude;

                longitude = addressLatLng.longitude;

                fetchNearbyPlaces();

            } else {

                showToastMessage("Failed to find location for the given address.");

            }

        } else if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {

            fetchNearbyPlaces();

        } else {

            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);

        }

    }

}











Selected Places are the  most important part of this. In the FindPlaceActivity class, selected places are stored in memory and persistently in a local database. Here's a detailed breakdown of how this works:



1. Storage in Memory

Selected places are stored temporarily in an ArrayList<Place> called selectedPlaces. This list acts as a container to hold the places the user selects during their session.

When a user clicks on an item in the ListView of found places, the selected place is assigned to the variable selectedPlace.

Upon clicking the "Select Place" button (button_select_place), the selected place is added to the selectedPlaces list if it is not already there:

java

Copy code

if (!selectedPlaces.contains(selectedPlace)) {

    selectedPlaces.add(selectedPlace);

    databaseHelper.addPlace(selectedPlace); // Save to database

    showToastMessage("Place added to the selected list and saved to the database.");

}

This ensures that duplicates are avoided in the list.



2. Persistent Storage in the Database

Selected places are saved persistently using a local database handled by the DatabaseHelper class. This allows them to be retained even after the App is closed or restarted.

Saving Places:

The method databaseHelper.addPlace(selectedPlace) adds the selected place to the database. DatabaseHelper likely uses SQLite or another database solution to store place details persistently.

Loading from Database:

When the activity starts, loadDatabasePlaces() is called, which fetches all previously saved places from the database using databaseHelper.getAllPlaces():

java

Copy code

databasePlaces.addAll(databaseHelper.getAllPlaces());

foundPlaces.addAll(databasePlaces); // Combine database places with found places

This ensures that saved places are displayed alongside newly fetched places in the ListView.



3. Data Flow

The user selects a place from the list of found places.

The selected place is added to the selectedPlaces list (in-memory).

The place is saved persistently in the database using DatabaseHelper.addPlace.

Previously saved places are loaded from the database during initialization (loadDatabasePlaces).



4. Benefits of the Approach

Persistence: Places remain available across app sessions since they are stored in a local database.

Avoiding Duplicates: The app checks if a place already exists in the selectedPlaces list before adding it, preventing redundant entries.

Dynamic Updates: The ListView is updated in real-time whenever places are added or loaded.

 













When the "Go to Selected Places" button is clicked in the FindPlaceActivity, the App first verifies whether the selectedPlaces list contains any places. A toast message is displayed if the list is empty, informing the user that no places have been selected to pass. If places have been 

selected, the App prepares to navigate to the PlacesListActivity by bundling the list of selected places using a Bundle and an Intent. The selectedPlaces list, which is made parcelable for data transfer, is attached to the Intent, and the App uses startActivity to launch the PlacesListActivity. In the new activity, the bundle is retrieved, and the list of selected places is extracted and displayed, often in a ListView or RecyclerView for the user to view or manage. This process ensures smooth data transfer between activities and allows users to seamlessly navigate and interact with their selected places on a dedicated screen.

PlacesListActivity



Button goToPlacesListButton = findViewById(R.id.button_go_to_places_list);

if (goToPlacesListButton != null) {

    goToPlacesListButton.setOnClickListener(v -> {

        if (selectedPlaces == null || selectedPlaces.isEmpty()) {

            Toast.makeText(this, "No places selected to pass.", Toast.LENGTH_SHORT).show();

            return;

        }



        Intent intent = new Intent(FindPlaceActivity.this, PlacesListActivity.class);



        Bundle bundle = new Bundle();

        bundle.putParcelableArrayList("selectedPlaces", selectedPlaces);



        Log.d("FindPlaceActivity", "Passing " + selectedPlaces.size() + " places to PlacesListActivity.");

        intent.putExtra("bundle", bundle);



        startActivity(intent);

    });

}





Then we go to the PlacesListActivity



@Override

protected void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);

    setContentView(R.layout.activity_places_list);



    selectedPlaces = getSelectedPlaces();

    setList();

}



This class is solely set up to pass a list of places to our matrix algorithm and map to find the quickest path. 



 





The PlacesListActivity class passes data to the MapActivity by bundling a list of selected places (selected places) and attaching it to an Intent. Here's a detailed explanation of how it works:



1. Triggering the Button Click

In the onClick method, when the user clicks the "Find Route" button (R.id.button_find_route), the following code is executed:

public void onClick(View view) {

    Intent intent;



    if (view.getId() == R.id.button_add_place) {

        if (selectedPlaces.size() < 9) {

            intent = new Intent(this, FindPlaceActivity.class);

            intent.putExtra("bundle", saveSelectedPlaces());

            startActivity(intent);

        } else {

            Toast.makeText(this, getString(R.string.message_you_cant_select_more_places),

                    Toast.LENGTH_SHORT).show();

        }

    } else if (view.getId() == R.id.button_find_route) {

        intent = new Intent(this, MapActivity.class);

        intent.putExtra("places", saveSelectedPlaces());

        startActivity(intent);

    }

}





In the PlacesListActivity, data is passed to the MapActivity when the "Find Route" button is clicked. The selectedPlaces list, which contains the places chosen by the user, is bundled using the saveSelectedPlaces() method that wraps it into a Bundle with the key "selectedPlaces". This bundle is then attached to an Intent using putExtra with the key "places". The startActivity(intent) method launches the MapActivity, carrying the bundled data. In the MapActivity, the bundle is retrieved using getBundleExtra("places"), and the list of places is extracted with getParcelableArrayList("selectedPlaces"). This enables MapActivity to access the selected places for further use, such as displaying markers on a map or calculating routes. This process ensures seamless data transfer between the two activities using a Bundle and an Intent.







MapActivity 

This class is the most detailed but not the most mathematically challenging one. 

The MapActivity class in this code manages the display of a Google Map and facilitates the visualization of selected places, routes, and travel modes (driving, walking, bicycling). Upon creation (onCreate), the activity initializes Google Play Services and the map using a SupportMapFragment. It retrieves the list of selected places via an Intent passed from a previous activity, ensuring the current location is prioritized in the list. The activity also checks for location permissions at runtime, prompting the user if they are missing, and builds a GoogleApiClient to connect to the location services. Buttons for driving, bicycling, and walking modes allow users to dynamically update the mode of travel, which triggers route optimization and recalculates the best path between selected places.

The activity uses the RouteFinder class (likely an asynchronous task) to calculate optimized routes based on two optimization types: distance or time. The findRoute() method starts this process, which fetches the directions and updates the map with polylines representing the route. The method displayMarkers() places markers on the map for each Place in the ordered list returned by the RouteFinder. Current locations are marked in blue, and all others are marked in red with appropriate titles and descriptions. Additional information, such as distance or time matrices and the optimal route, is displayed in a TextView using the displayAdditionalInfo() method.

Location updates are handled via the onLocationChanged() callback, where the user's current latitude and longitude are obtained and set as the starting location if not already initialized. The activity displays the route and directions dynamically by decoding the provided polyline data using Google Maps Utility methods. The activity also handles user interactions like button presses to switch between travel modes and spinner selections to choose optimization types. By combining location updates, Google Maps API, and route optimization logic, the MapActivity efficiently visualizes the best route, displays markers, and provides relevant route information to the user.





1. Retrieving Selected Places from the Previous Activity

The getPlaces() method retrieves the list of Place objects passed via an Intent. It ensures that the current location is placed first in the list for accurate route optimization.

ArrayList<Place> getPlaces() {

    Intent intent = getIntent();

    Bundle placesBundle = intent.getBundleExtra("places");

    if (placesBundle == null) {

        return new ArrayList<>();

    }

    ArrayList<Parcelable> parcelableList = placesBundle.getParcelableArrayList("selectedPlaces");



    if (parcelableList == null) {

        return new ArrayList<>();

    }



    ArrayList<Place> placeList = new ArrayList<>();

    for (Parcelable parcelable : parcelableList) {

        if (parcelable instanceof Place) {

            placeList.add((Place) parcelable);

        }

    }



    // Ensure the current location is first in the list

    Place currentLocation = null;

    for (Place place : placeList) {

        if (place.getName().equals(getResources().getString(R.string.current_location))) {

            currentLocation = place;

            break;

        }

    }



    if (currentLocation != null) {

        placeList.remove(currentLocation);

        placeList.add(0, currentLocation);

    }



    return placeList;

}







2. Displaying Markers on the Map

The displayMarkers() method adds markers for all selected places on the map. The current location marker is highlighted in blue, and other locations are marked in red.









private void displayMarkers(List<Place> orderedPlaces) {

    LatLng latLng;

    MarkerOptions markerOptions = new MarkerOptions();



    Place currentLocation = null;

    int iterator = 0;



    if (orderedPlaces.get(0).getName().equals(getResources().getString(R.string.current_location))) {

        currentLocation = orderedPlaces.get(0);

        iterator = 1;

    }



    if (currentLocation != null) {

        // Current location:

        latLng = new LatLng(orderedPlaces.get(0).getLatitude(), orderedPlaces.get(0).getLongitude());

        markerOptions.position(latLng);

        markerOptions.title(orderedPlaces.get(0).getName());

        markerOptions.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE));

        mMap.addMarker(markerOptions);



        // Other locations:

        for (int i = iterator; i < orderedPlaces.size(); i++) {

            latLng = new LatLng(orderedPlaces.get(i).getLatitude(), orderedPlaces.get(i).getLongitude());

            markerOptions.position(latLng);

            markerOptions.title(i + ". " + orderedPlaces.get(i).getName());

            markerOptions.snippet(orderedPlaces.get(i).getDescription());

            markerOptions.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));

            mMap.addMarker(markerOptions);

        }

    }



    // If there is no current location in the tour

    for (int i = iterator; i < orderedPlaces.size(); i++) {

        latLng = new LatLng(orderedPlaces.get(i).getLatitude(), orderedPlaces.get(i).getLongitude());

        markerOptions.position(latLng);

        markerOptions.title(orderedPlaces.get(i).getName());

        markerOptions.snippet(orderedPlaces.get(i).getDescription());

        markerOptions.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));

        mMap.addMarker(markerOptions);

    }

}



3. Building Routes Based on Travel Mode

The onClick method responds to button presses for driving, bicycling, or walking modes. It sets the route mode and updates the route dynamically using the findRoute() method.

public void onClick(View view) {

    if (view.getId() == R.id.driving_button) {

        if (pressedButtonId != R.id.driving_button) {

            setButtonColor(R.id.driving_button);

            pressedButtonId = R.id.driving_button;

            mode = "driving";

            findRoute(optymalizationType);

        }

    } else if (view.getId() == R.id.bicycling_button) {

        if (pressedButtonId != R.id.bicycling_button) {

            setButtonColor(R.id.bicycling_button);

            pressedButtonId = R.id.bicycling_button;

            mode = "bicycling";

            findRoute(optymalizationType);

        }

    } else if (view.getId() == R.id.walking_button) {

        if (pressedButtonId != R.id.walking_button) {

            setButtonColor(R.id.walking_button);

            pressedButtonId = R.id.walking_button;

            mode = "walking";

            findRoute(optymalizationType);

        }

    }

}



4. Displaying Route Directions with Polylines

The displayDirections() method clears the map and overlays the polylines that represent the route, decoded using the Google Maps Utility Library.

void displayDirections(List<String[]> directions) {

    mMap.clear();

    mMap.animateCamera(CameraUpdateFactory.zoomBy(0));

    displayMarkers(RouteFinder.getOrderedPlaces());

    for (String[] legs : directions) {

        for (String directionsList : legs) {

            PolylineOptions options = new PolylineOptions();

            options.color(Color.RED);

            options.width(8);

            options.addAll(PolyUtil.decode(directionsList));

            mMap.addPolyline(options);

        }

    }



    LatLng latLng = new LatLng(latitude, longitude);

    mMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));

    mMap.animateCamera(CameraUpdateFactory.zoomTo(14));

}



5 Managing Location Updates

The onLocationChanged() method is triggered when the user's location changes. It retrieves the current latitude and longitude and initializes the route-finding process.



    @Override

    public void onLocationChanged(Location location) {

        latitude = location.getLatitude();

        longitude = location.getLongitude();



        // Stop location updates

//        if (mGoogleApiClient != null) {

//            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this);

//            Log.d("onLocationChanged", "Removing Location Updates");

//        }



        if (!isStartingLocationSet) {

            selectedPlaces = getPlaces();

            isStartingLocationSet = true;

            // In async task:

            // Get googleDistanceMatrixUrl, download and parse json, build valuesMatrix:

            findRoute(optymalizationType);

        }

    }





5. Fetching and Optimizing Routes

The findRoute() method initiates the route-finding process using an external helper class, RouteFinder. RouteFinder optimizes routes based on the Google matrix and allows you to prioritize route distance or time.

private void findRoute(OptymalizationType optymalizationType) {

    RouteFinder routeFinder = new RouteFinder(this);

    routeFinder.execute(optymalizationType);

}



void setOptymalizationModeListener() {

    Spinner spinner = findViewById(R.id.optymalization_mode_spinner);

    spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {

        @Override

        public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {

            switch (position) {

                case 0:

                    optymalizationType = OptymalizationType.DISTANCE;

                    findRoute(optymalizationType);

                    break;

                case 1:

                    optymalizationType = OptymalizationType.TIME;

                    findRoute(optymalizationType);

                    break;

            }

        }



        @Override

        public void onNothingSelected(AdapterView<?> adapterView) {

        }

    });

}





The MapActivity Class is a way to display the routes provided by our RouteFinder class, which solves the matrix problem. 



5 RouteFinder Class



The RouteFinder class is an AsyncTask implementation in Android that handles route optimization and directions fetching for a list of places using the Google Maps Distance Matrix API and Directions API. It optimizes routes based on distance or time using configurable algorithms (like Simulated Annealing) and updates the UI once the computation is complete. Below is a detailed explanation of how it works:



1. Pre-Execution and Initialization

In onPreExecute(), a progress dialog notifies the user that route calculation has started. The system also logs the start time to measure performance.

A weak reference (WeakReference<MapActivity>) to MapActivity ensures memory safety, preventing potential memory lea



@Override

protected void onPreExecute() {

    MapActivity mapActivity = mapActivityRef.get();

    if (mapActivity != null) {

        mapActivity.showProgressDialog(mapActivity);

        Log.d("RouteFinder", "Start pomiaru czasu.");

        startTime = System.nanoTime();

    }

    super.onPreExecute();

}

2. Background Task: Route Calculation

The doInBackground method performs the heavy lifting:

Fetch Distance Matrix: It builds a URL for the Google Distance Matrix API using the list of places' latitudes and longitudes. The UrlDownloader fetches the JSON response.

Parse Distance/Time: The DataParser extracts the distance or time matrix from the response based on the selected optimization type (distance or time).

Solve the Traveling Salesman Problem (TSP): Using the solveTSP method, the best route is computed based on a Simulated Annealing optimization algorithm.

Fetch Directions: After determining the optimal order of places, it builds a Directions API URL to fetch route polylines for visualization.

@Override

protected Void doInBackground(OptymalizationType... params) {

    MapActivity mapActivity = mapActivityRef.get();

    if (mapActivity == null) {

        return null;

    }

    OptymalizationType optymalizationType = params[0];

    UrlDownloader urlDownloader = new UrlDownloader();

    DataParser dataParser = new DataParser();



    // GOOGLE DISTANCE MATRIX WORK:

    String distMatrixUrl = getDistanceMatrixUrl(mapActivity.getPlaces());



    try {

        gDistanceMatrixData = urlDownloader.readUrl(distMatrixUrl);

    } catch (IOException e) {

        Log.e("RouteFinder", "Error reading distance matrix URL", e);

        return null;

    }



    switch (optymalizationType) {

        case DISTANCE:

            valuesMatrix = dataParser.parseDistance(gDistanceMatrixData);

            break;



        case TIME:

            valuesMatrix = dataParser.parseTime(gDistanceMatrixData);

            break;



        default:

            valuesMatrix = dataParser.parseDistance(gDistanceMatrixData);

    }

    solveTSP(valuesMatrix);



    orderedPlaces = new ArrayList<>();

    for (int i : shortestPath) {

        orderedPlaces.add(mapActivity.getSelectedPlaces().get(i));

    }



    // GOOGLE DIRECTIONS WORK:

    String directionsUrl = getDirectionsUrl(orderedPlaces);



    try {

        gDirectionsData = urlDownloader.readUrl(directionsUrl);

    } catch (IOException e) {

        Log.e("RouteFinder", "Error reading directions URL", e);

        return null;

    }



    directions = dataParser.parseDirections(gDirectionsData);

    return null;

}



3. Route Optimization: Solving TSP

The TSP problem is solved using the Simulated Annealing algorithm:

It iteratively swaps two places in the route to find better solutions based on an acceptance probability.

The temperature decreases with each iteration (cooling rate), balancing exploration and exploitation.

The algorithm stops when the temperature is low or the iteration limit is reached.

getDistanceMatrixUrl(): Constructs the URL for Google Distance Matrix API using the coordinates of all places.

getDirectionsUrl(): Builds the URL for Google Directions API for the optimized order of places.

computeDistance(): Calculates the total distance of a given path using the distance matrix.



Summary

Using Simulated Annealing, the RouteFinder class uses asynchronous tasks to optimize routes for a set of places by solving the Traveling Salesman Problem (TSP). It fetches distance and direction data from the Google Maps APIs, parses it, and visualizes the optimal route on a map. The process includes dynamic UI updates, such as displaying markers, route polylines, and additional distance/time information, providing a seamless user experience.





private static List<Integer> solveUsingSimulatedAnnealing(int[][] valuesMatrix, List<Integer> places) {

    List<Integer> currentPath = new ArrayList<>(places);

    List<Integer> bestPath = new ArrayList<>(places);

    int currentDistance = computeDistance(currentPath, valuesMatrix);

    int bestDistance = currentDistance;

    double temperature = 10000;

    double coolingRate = 0.003;

    int iterationLimit = 10000;

    int iteration = 0;

    Random random = new Random();



    while (temperature > 1 && iteration < iterationLimit) {

        List<Integer> newPath = new ArrayList<>(currentPath);

        int swapIndex1 = random.nextInt(newPath.size());

        int swapIndex2 = random.nextInt(newPath.size());



        // Swap two cities

        int temp = newPath.get(swapIndex1);

        newPath.set(swapIndex1, newPath.get(swapIndex2));

        newPath.set(swapIndex2, temp);



        int newDistance = computeDistance(newPath, valuesMatrix);



        // Accept the new solution with a probability

        if (acceptanceProbability(currentDistance, newDistance, temperature) > random.nextDouble()) {

            currentPath = new ArrayList<>(newPath);

            currentDistance = newDistance;

        }



        // Keep track of the best solution found

        if (currentDistance < bestDistance) {

            bestPath = new ArrayList<>(currentPath);

            bestDistance = currentDistance;

        }



        // Cool the system

        temperature *= 1 - coolingRate;

        iteration++;

    }



    shortestDistance = bestDistance;

    return bestPath;

}

The solveUsingSimulatedAnnealing method implements the Simulated Annealing algorithm to solve the Traveling Salesman Problem (TSP). The TSP aims to find the shortest route that visits all given places (represented as indices) and returns to the starting point. Simulated Annealing is a heuristic optimization technique inspired by the cooling process of metals, balancing exploration and exploitation to avoid getting stuck in local minima.



Current path starts with the initial sequence of places (cities) to be visited.

currentDistance calculates the total distance for this path using the computeDistance method and the valuesMatrix, which holds the distances between each pair of cities.

A high temperature (temperature = 10,000) is set, gradually decreasing during the iterations, controlling the probability of accepting worse solutions.

A cooling rate (coolingRate = 0.003) determines how quickly the temperature decreases.

Code:

java

Iterative Improvement:

The algorithm explores new paths by randomly swapping two cities in the currentPath. It evaluates the total distance of the new path (newDistance) and compares it to the current distance (currentDistance).

If the new distance is shorter, the new path is accepted.



If the new distance is longer, it may still be accepted with a probability determined by the acceptance probability function. This helps escape local minima by occasionally accepting worse solutions.









int temp = newPath.get(swapIndex1);

newPath.set(swapIndex1, newPath.get(swapIndex2));

newPath.set(swapIndex2, temp);



int newDistance = computeDistance(newPath, valuesMatrix);



// Accept the new solution with a probability

if (acceptanceProbability(currentDistance, newDistance, temperature) > random.nextDouble()) {

    currentPath = new ArrayList<>(newPath);

    currentDistance = newDistance;

}





Temperature Cooling:

After evaluating a new solution, the temperature is reduced by multiplying it with (1 - coolingRate). This ensures that as the iterations progress, the search focuses more on exploitation (accepting better solutions) than exploration.



        temperature *= 1 - coolingRate;



The loop continues until the temperature drops below 1. At this point, the algorithm has likely converged to a near-optimal solution. 



Summary

The solveUsingSimulatedAnnealing method uses Simulated Annealing to approximate the optimal solution to the Traveling Salesman Problem. It iteratively improves a random path by swapping cities, evaluating the distance, and accepting or rejecting new paths based on the acceptance probability and cooling temperature. This approach avoids local minima and efficiently balances exploration and exploitation to find near-optimal routes (Allanah, F).







The RouteFinder Also uses an UrlDownloader class to download and parse the JSON. 



UrlDownloader



The readUrl(String myUrl) method takes a URL string (myUrl) as input and establishes an HTTP connection using the HttpURLConnection class.

URL is initialized with the provided URL string.

HttpURLConnection opens a connection to the URL and sends an HTTP request.

Connect () establishes the connection to start the communication.



Once the connection is established, the method reads the input stream of the HTTP response using a BufferedReader. This ensures efficient reading of text data line by line.



try {

    URL url = new URL(myUrl);

    urlConnection = (HttpURLConnection) url.openConnection();

    urlConnection.connect();



    inputStream = urlConnection.getInputStream();

    BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));

    StringBuilder sb = new StringBuilder();



    String line;

    while((line = br.readLine()) != null) {

        sb.append(line);

    }



    data = sb.toString();

    Log.d("downloadUrl", data);



    br.close();



} catch (IOException e) {

    e.printStackTrace();

}

The UrlDownloader class performs the following tasks:

Connects to a specified URL using HttpURLConnection.

Reads the server response line by line via a BufferedReader and concatenates it into a single string.

Logs the raw data for debugging.

Ensures proper cleanup of network resources by closing the input stream and disconnecting the connection.

Handles any IOException that occurs during the network operation.

This utility is handy for downloading JSON responses from APIs, such as Google Maps APIs, which are later parsed for use in the application.









DataParser Class



The DataParser class is responsible for extracting meaningful data from JSON responses returned by various APIs, such as the Google Distance Matrix API, Directions API, or Places API. It processes the JSON data and converts it into more usable structures like arrays, matrices, and Place objects. Below is a detailed explanation of its methods and functionality:



List<String[]> parseDirections(String jsonData){



    JSONArray jRoutes;

    JSONArray jLegs;

    JSONArray jSteps;

    String[] polylines;

    List<String[]> route = new ArrayList<>();



    try {

        JSONObject jObject = new JSONObject(jsonData);

        jRoutes = jObject.getJSONArray("routes");



        // Traversing all routes

        for(int i=0; i<jRoutes.length(); i++){

            jLegs = ( (JSONObject)jRoutes.get(i)).getJSONArray("legs");



            // Traversing all legs

            for(int j=0; j<jLegs.length(); j++){

                jSteps = ( (JSONObject)jLegs.get(j)).getJSONArray("steps");

                polylines = new String[jSteps.length()];



                // Traversing all steps

                for(int k=0; k<jSteps.length(); k++){

                    String polyline;

                    polyline = (String)((JSONObject)((JSONObject)jSteps.get(k)).get("polyline")).get("points");

                    polylines[k] = polyline;

                }

                route.add(polylines);

            }

        }

    } catch (Exception e){

        e.printStackTrace();

    }

    return route;

}

This method extracts route polylines from a JSON response from the Google Directions API. These polylines are encoded strings representing the paths between places.

How it Works:

The JSON response is traversed hierarchically:

Routes → Legs → Steps.

Within each step, the polyline object contains encoded path data under the key. 

"points".

It collects all polylines for each step and stores them in a String[] array.

The arrays are added to a List<String[]> representing multiple legs or segments of a route.







2. parseDistance(String jsonData)

This method extracts a distance matrix from the JSON response of the Google Distance Matrix API. The matrix contains distances between all specified origins and destinations.

How it Works:

It parses the "rows" array in the JSON response.

Each row contains "elements," where each element holds the distance value under "distance → value."

It fills a 2D integer array (distanceMatrix) with these distances.

This is what you see displayed on the map output. 



int[][] parseDistance(String jsonData){

    int[][] distanceMatrix = new int[0][0];

    JSONArray jRows;

    JSONArray jElements;



    try {

        JSONObject jObject = new JSONObject(jsonData);

        jRows = jObject.getJSONArray("rows");

        distanceMatrix = new int[jRows.length()][jRows.length()];



        for (int i = 0; i < jRows.length(); i++) {

            jElements = ((JSONObject)jRows.get(i)).getJSONArray("elements");



            for (int j = 0; j < jElements.length(); j++) {

                int distance = (int) ((JSONObject)((JSONObject)jElements.get(j))

                        .get("distance")).get("value");

                distanceMatrix[i][j] = distance;

            }



        }

    } catch (Exception e){

        e.printStackTrace();

    }

    return distanceMatrix;

}



3. parseTime(String jsonData)

This method works similarly to parseDistance but extracts the duration matrix (time taken) instead of distance. It processes the "duration → value" field in the JSON response.

int[][] parseTime(String jsonData){

    int[][] timeMatrix = new int[0][0];

    JSONArray jRows;

    JSONArray jElements;



    try {

        JSONObject jObject = new JSONObject(jsonData);

        jRows = jObject.getJSONArray("rows");

        timeMatrix = new int[jRows.length()][jRows.length()];



        for (int i = 0; i < jRows.length(); i++) {

            jElements = ((JSONObject)jRows.get(i)).getJSONArray("elements");



            for (int j = 0; j < jElements.length(); j++) {

                int time = (int) ((JSONObject)((JSONObject)jElements.get(j)).get("duration")).get("value");

                timeMatrix[i][j] = time;

            }



        }

    } catch (Exception e){

        e.printStackTrace();

    }

    return timeMatrix;

}

The parseDistance and parseTime methods process JSON responses from the Google Distance Matrix API, but they extract different information. parseDistance retrieves the distance values (in meters) by accessing the "distance → value" field within each response element, representing the physical distance between two locations. In contrast, parseTime extracts the duration values (in seconds) from the "duration → value" field, representing the estimated travel time between two locations. Both methods iterate over the "rows" and "elements" arrays of the JSON response, but the key difference lies in the field they target: "distance" for physical distance and "duration" for travel time. The resulting output is a 2D integer array in both cases, where each entry corresponds to the distance or time between two locations.









































Basic Places App:



The rest of the app's functionality is fairly basic. It allows you to store places in a database, edit them, and view them on a map. Any places you have added from the PlaceFinder app will also be stored in the main App. You can reach this part of the App by clicking Places Database.



![Figure  Application Greeting Click Places Database to access basic address book features](image_placeholder.png)



The Rest of the code was based upon my maps assignment, which I never got the chance to turn in on time. 





![Figure  Clicking on A place will bring up its details including a built in map](image_placeholder.png)



![Figure  Clicking the far left will allow you to add a place. The middle button is for routing selected places through the matrix api, and the third button will bring up a map of all your places](image_placeholder.png)



The classes AddPlace EditPlace PlaceDetails, Place and DatabaseHelper work together to handle the creation, management, and storage of "places" in the database for the application. They utilize utilities like AddressUtils for geocoding and Bitmap handling for images. Here's how they interact and function:



1. AddPlace Class

Purpose: This class provides the user interface and logic to allow users to add a new "Place" to the application. It retrieves input details (like name, address, and image), converts the address into coordinates, and stores the new place in the database.

Key Functionality:

User Input Handling:

The user provides:

Name, State, Street, City, and Postal Code through EditText.

An optional image by selecting it through the gallery using an Intent.



Geocoding Address:

The address (street, city, state, postal code) is passed to AddressUtils.getLatLngFromAddress(), which uses the Android Geocoder to fetch latitude and longitude.

    public static LatLng getLatLngFromAddress(String address, Context context) {

        Geocoder geocoder = new Geocoder(context, Locale.getDefault());

        try {

            List<Address> addresses = geocoder.getFromLocationName(address, 1);

            if (addresses != null && !addresses.isEmpty()) {

                Address location = addresses.get(0);

                return new LatLng(location.getLatitude(), location.getLongitude());

            }

        } catch (IOException e) {

            Log.e("AddressUtils", "Error in geocoding", e);

        }

        return null;

    }

}

Creating the Place Object:

A Place object is created with the input details, latitude/longitude, and an optional image. If no image is selected, a default image is assigned.

    // Create a Place object

    Place place = new Place();

    place.setName(name);

    place.setState(state);

    place.setStreet(street);

    place.setCity(city);

    place.setPostalCode(postalcode);

    place.setLatitude(latLng.latitude);

    place.setLongitude(latLng.longitude);



    // Assign a default image if none is selected

    if (imageToStore == null) {

        Bitmap defaultImage = BitmapFactory.decodeResource(this.getResources(), R.drawable.client_image);

        place.setImage(defaultImage);

    } else {

        place.setImage(imageToStore);

    }



    // Insert place into the database

    DB = DatabaseHelper.getInstance(AddPlace.this);

    DB.addPlace(place);



    // Retrieve the most recently added client ID and navigate to ClientList

    ArrayList<Place> allPlaces = DB.getAllPlaces();

    int id = allPlaces.get(allPlaces.size() - 1).getId();



    Intent intent = new Intent(AddPlace.this, PlacesList.class);

    intent.putExtra("clientID", id);

    startActivity(intent);

}

The new Place is saved into the SQLite database using DatabaseHelper.

The AddPlace class provides the user interface and logic for adding a new "Place" to the App by collecting user input such as name, address (state, street, city, postal code), and an optional image. It uses AddressUtils to geocode the provided address into latitude and longitude, ensuring accurate location data. A Place object is created with this information and, if no image is selected, a default image is assigned. The DatabaseHelper class then handles storing this Place in the SQLite database, where images are converted into byte arrays for storage in a BLOB column. DatabaseHelper also supports retrieving, updating, and deleting records, along with querying the database to filter places based on name, street, or city. Images are converted back into Bitmap objects when retrieved for display. Once the new place is added, the user is redirected to a list of saved places. Together, these components ensure seamless data input, geolocation, and persistent storage of place information with images in the App.





The PlacesMap class is an AppCompatActivity that integrates a Google Map to display markers for multiple places retrieved from the App's database. It allows users to visualize locations on a map, interact with markers, and view additional information using a bottom dialog. Here's a breakdown of how it works:



1. Initializing Components and Map

The activity initializes a MapView (mapAllClients) to render the Google Map and uses the DatabaseHelper to fetch all saved places from the SQLite database.

The onCreate method sets up the UI, including a toolbar for navigation and prepares the MapView lifecycle using mapAllClients.getMapAsync(this), which ensures that the map is loaded asynchronously.







![Figure  PlacesMap](image_placeholder.png)



The PlacesMap class is an AppCompatActivity that displays all stored places on a Google Map using markers fetched from the database via the DatabaseHelper. It initializes a MapView to load the map asynchronously, centers the camera on a default location (Virginia), and iterates through the list of places to add custom markers at their respective latitude and longitude coordinates. Custom icons for markers are generated using the vectorToBitmap method, which converts vector drawables into bitmaps. When a marker is clicked, it opens a BottomInfoDialog to show detailed information about the selected place, passing the place's ID for reference. The class also implements the BottomInfoListener interface, allowing polylines (routes) to be drawn on the map when triggered by the dialog. Proper lifecycle management of the MapView ensures efficient resource handling, while the user-friendly interaction provides a smooth experience for visualizing places and their details on the map.







The PlacesMap class indirectly utilizes Parcelable through its interaction with the Place model and the database. In Android, Parcelable is an interface that allows efficient serialization of objects so they can be passed between components like activities, fragments, or dialogs.

Here’s how Parcelable comes into play:

Passing Place Data:

The Place class is likely implemented as a Parcelable to allow it to be passed between components, such as when opening dialogs or navigating between activities. This ensures that a Place object, which contains data like name, address, latitude, longitude, and an optional image, can be efficiently serialized and deserialized.

Passing Data to BottomInfoDialog:

When a marker is clicked, a BottomInfoDialog is instantiated, and the selected place's ID is passed as part of a Bundle. While the example only passes an ID, if the full Place object were passed, its Parcelable implementation would enable smooth and efficient data transfer.



The MyListAdapter class is a custom implementation of a BaseAdapter designed to display a list of Place objects within a ListView in an Android application. It provides a flexible and efficient way to render place data, such as names and descriptions, with additional functionality to delete an item dynamically from the list. All of the adapters play a role in the recycler views you will see several times throughout the App. 





 

 

![Figure  Basic List View](image_placeholder.png)

 





 

![Figure Modifying Place Details](image_placeholder.png)

  

Code Explanation  

# Purpose  

 1 AndroidManifest.xml  

  Figure 3.1 Oncreate method  

![Figure 3.2 Android Lifecycle  ](image_placeholder.png)

   

 

 

What Is An Android Activity | Robots.net. Retrieved September 29, 2024, from https://robots.net/tech/what-is-an-android-activity  

Goodbye to Activity Lifecycle and Hello to Compose Lifecycle | by PINAR TURGUT | Medium. Retrieved September 29, 2024, from https://pinarturgut09.medium.com/goodbye-toactivitylifecycle-and-hello-to-compose-lifecycle-6eaaf8270580  

Geocoder. (n.d.). Android Developers. https://developer.android.com/reference/android/location/Geocoder 

 

Admin. (2020, January 9). Why setcontentview() in Android had been so popular till now?. AndroidRide. https://androidride.com/what-setcontentview-android-studio/   

  Google Developers. (n.d.). Get started with Google Maps Platform. Retrieved from https://developers.google.com/maps/documentation/android-sdk/start 

Android Developers. (n.d.). Create dynamic lists with RecyclerView. Retrieved from https://developer.android.com/guide/topics/ui/layout/recyclerview 

 GeeksforGeeks. (n.d.). Difference between Serializable and Parcelable in Android. Retrieved from https://www.geeksforgeeks.org/difference-between-serializable-and-parcelable-in-android/  Vogella. (n.d.). Android Parcelable tutorial. Retrieved from https://www.vogella.com/tutorials/AndroidParcelable/article.html 

  Johncarl81. (n.d.). Parceler. Retrieved from https://github.com/johncarl81/parceler  Android Developers. (n.d.). Pickers. Retrieved from 

https://developer.android.com/develop/ui/views/components/pickers  Android Developers. (n.d.). Geocoder. Retrieved from 

https://developer.android.com/reference/android/location/Geocoder 

 Android Developers. (n.d.). Understand the activity lifecycle. Retrieved from https://developer.android.com/guide/components/activities/activity-lifecycle Google Developers. (n.d.). Google Maps Utility Library for Android. Retrieved from https://developers.google.com/maps/documentation/android-sdk/utility/setup 

Android Developers Blog. (n.d.). Updates and resources for Android development. Retrieved from https://android-developers.googleblog.com/ 

 

