Scenario: User selects bus options based on geographical proximity using a map.
    Given the application has access to a map with all the bus stops and their geographical locations.
    When a user zooms in the map,
    Then the application displays the bus stops in that geographical zone by marking them in the map.

Scenario: User views route details.
    Given the user is on the main page of the app,
    When a user selects a certain bus route,
    Then the app should display detailed information about the route including start and end points, total duration, and estimated arrival times at all the stops.

Scenario: User searches different bus options of a stop.
    Given the application has access to up-to-date bus schedules,
    When a user selects a certain bus stop,
    Then the application directly displays the schedule of bus services available at the selected bus stop

Scenario: Initial Sign-In and Progress Save.
    Given that a user has achieved a score or set preferences in the application without being signed in,
    When the user opts to sign in through their preferred method
    Then the application should successfully sign the user in and prompt them to save their current score and preferences to their account.

Scenario: Retrieving Progress on a New Device.
    Given that a user has previously saved their application score and preferences by signing in on one device,
    When the user signs into the same account on a different device,
    Then the application should automatically retrieve and apply the user’s score and preferences, allowing the user to continue from where they left off.

Scenario: Adding a Profile Picture
    Given that a user is signed into their account and on their profile page,
    When the user selects the option to add or change their profile picture and uploads a new image,
    And the user completes the sign-in and authorization process allowing access to their profile picture,
    Then the application should successfully upload and display the new profile picture on the user's profile.

Scenario: Changing User Name
    Given that a user is signed into their account and on their profile or account settings page,
    When the user selects the option to change their name, inputs a new name, and confirms the change,
    Then the application should update the user’s name across the platform, reflecting the change in all areas where the user’s name is displayed.