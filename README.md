/////////////////////////////////
Weather App Lightning Web Component with MetaWeather (www.metaweather.com/api) project
////////////////////////////////

Weather Forecast API: https://www.metaweather.com/api/ 

 ///////////////////////////////////////
    Run below code from Execute Anonymously in Developer Console to Schedule Daily Weather Update
    //////////////

    DailyWeatherUpdate d = new DailyWeatherUpdate();
    String cronScheduler = '0 0 1 * * ?';
    System.Schedule('Update Saved Cities', cronScheduler, d); 

    _____________________________________________________
    _______________________________________________________

Project Requirements:

    • Coordinators are users in Salesforce and they should be able to search and add their city to start tracking the weather. 

    • Cities should be stored in a new SObject

    • Cities should periodically update the forecast every night (1:00 AM) from 3rd party API above. We only need the weather for the current day.

    • The data on the new page should show

        ○ High Temperature (Fahrenheit)

        ○ low Temperature (Fahrenheit)

        ○ last retrieved/updated datetime

        ○ City/region Name

 

Functionalities:

    • Users should be able to see a list of 20 recent city they added by default.

    • City list should show the data points in the requirements above.

    • Users should be able to add new city.

    • Users should be able to remove cities they added

____________________________________
USER STORIES
---------------------------------------

1. As a Coordinator, I want to be able to search for a city so that I can add it to a list to track it's weather.
    - Search for a city.
    - 

2. As a Coordinator, I want to see a list city that are being tracked,its low and high temperature of the day, and when it was last updated.

3. As a Coordinator, I want to be able remove any city from the List of tracked cities.

4. As a Coordinator, I want to see all cities in the tracked list get updated automatically every night at 1 am so I can see the temperature data for the given day.


Architecure and Components

Lightning App
    - MyWeather
    - Meta Weather - home page for MyWeather to show the weatherApp LWC.

Custom Object

    Weather Data (MetaWeather__c) - to store information for cities that will be tracked and updated.

Custom Fields

    City__c - to store name of the city
    Woeid__c - to store the woeid of the city to be used for weather callout
    low_temperature__c - to store the min temp of the day
    high_temperature__c - to store the max temp of the day
    Last_updated__c - to store Datetime of when the weather data for the city was last updated

Lightning Web Component

- Front end App and client side controller for the Weather App

    weatherApp.html
    WeatherApp.js
      
Apex
    WeatherAppController.cls - Apex Controller to send API request to Metaweather.com, add new city to be tracked and query saved cities data.
    DailyWeatherUpdate.cls - Scheduler class to update Saved cities weather data
    TestWeatherAppController.cls
    MetaWeatherHttpCalloutMock


    --------------------------------------------------
    Unfinished items

- Clean up UI for more user friendly view
    - Add weather icons'
    - Auto-populate search

- Potential functionalities to add
    - populate and filter cities in the search dropdown as user types 
    - remove multiple cities from the tracked list at the same time
    