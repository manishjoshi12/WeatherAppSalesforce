//metaweather api webservice class
public class WeatherAppController {


// search city based on user input query
@AuraEnabled (cacheable = true)
public static Map<Integer, String> searchCity(String query){
System.debug('searching for..'+query);
if(String.isBlank(query)){
    return null;
}
String searchStr = query;
Map<Integer, String> foundCities = new Map< Integer, String>();
//List<String> foundCities = new List<String>();

try {
    //send request
    String resBody = callMetaWeatherAPI('search', searchStr);

    List<searchLocations> searchResults = (List<searchLocations>) JSON.deserialize(resBody, List<searchLocations>.class);
    
    for(searchLocations s: searchResults){
        foundCities.put(s.woeid, s.title);
    }
        return foundCities;
} catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
}

}

//query saved cities
@AuraEnabled
public static List<MetaWeather__c> getSavedWeatherData(){

    //get all saved city weather data
    List<MetaWeather__c> weatherData = [Select id, city__c, Low_Temperature__c, High_Temperature__c, Last_Updated__c from MetaWeather__c ORDER BY Last_Updated__C DESC LIMIT 20];
    //system.debug('weather data: '+ weatherData[0]);
    return weatherData;
    
}

//send http request and return JSON String

public static String callMetaWeatherAPI(String action, String arg){
    HttpRequest req = new HttpRequest();
    if(action == 'search'){
        req.setEndpoint(Label.MetaWeatherAPI+'location/search/?query='+ arg);

    }else{
        req.setEndpoint(Label.MetaWeatherAPI+'location/'+ arg+'/');
    }
    
    req.setMethod('GET');

    Http http = new Http();
    HttpResponse res = http.send(req);
    String resBody = res.getBody();
    return resBody;
}

@AuraEnabled
public static String addCity(Integer woeid){

    //String woeidStr = String.valueOf(woeid);
    List<MetaWeather__c> cityWeatherList = new List<MetaWeather__c>();
    if(woeid == null){
        return 'No WOEID found for the city!';
    }

    //check if city is already added
    cityWeatherList = [Select id, woeid__c from MetaWeather__c where woeid__c =: woeid];
        if(cityWeatherList.size() > 0){
            return 'We are already tracking weather for this city!';
        }else{

        try {

                String resBody = callMetaWeatherAPI('getWeather', String.valueOf(woeid));
                MetaWeather__c wd = parseLocationJSON(resBody);
                wd.woeid__c = woeid;
                cityWeatherList.add(wd);
            
            //System.debug('MetaWeather city: '+ cityWeatherList[0].city__c+ ' ' + cityWeatherList[0].woeid__c+ ' ' + cityWeatherList[0].low_temperature__c + ' ' + cityWeatherList[0].high_temperature__c +' ' +cityWeatherList[0].last_updated__c);

           // if(wd.woeid__c != null && wd.low_temperature__c != null, wd.high_temperature__c != null && wd.last_updated__c != null){
            // insert record into MetaWeather__c
            if(cityWeatherList.size() > 0){
                insert cityWeatherList;
                return 'Successfully Added the city to be tracked!';
            }else{
                return 'Something Went Wrong!';
            }
    
        } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
        }
    }
}


// convert temperatures to Fahrenheit
public static Integer convertToF(Decimal tempInC){

    return Math.round((tempInC * 9/5) +32);
}

public static void updateSavedCities(List<MetaWeather__c> savedCities){

    List<MetaWeather__c> citiesToUpdate = new List<MetaWeather__c>();

    for(MetaWeather__c city: savedCities){
        String woeidStr = String.valueOf(city.woeid__c);
        String res = callMetaWeatherAPI('Update', woeidStr);
        MetaWeather__c wd = parseLocationJSON(res);
        wd.id = city.id;
        citiesToUpdate.add(wd);
    }

    if(citiesToUpdate.size() > 0){
        update citiesToUpdate;
    }

}

public static MetaWeather__c parseLocationJSON(String JSONString){
    
    Map <String, Object> parse = (Map <String, Object>) JSON.deserializeUntyped(JSONString);

    List<Object> consolidatedWeatherList = (List <Object> )parse.get('consolidated_weather');

    Map <String, Object> LatestCW = (Map <String, Object>) consolidatedWeatherList[0];
    MetaWeather__c wd = new MetaWeather__c();
    wd.city__c = (String) parse.get('title');
    Decimal lowTemp = (Decimal) LatestCW.get('min_temp');
    wd.low_temperature__c = convertToF(lowTemp);     
    Decimal highTemp = (Decimal)LatestCW.get('max_temp');
    wd.high_temperature__c = convertToF(highTemp);
    wd.Last_Updated__c =  DateTime.now();

    return wd;
}

//inner class to hold search city results
public class searchLocations {
public String title;
public Integer woeid;
}
}




