public  class DailyWeatherUpdate implements Schedulable {
    
    public void execute(SchedulableContext ctx){
        List<MetaWeather__c> savedCities = [SELECT Id, woeid__c FROM MetaWeather__c ORDER BY Last_Updated__C DESC LIMIT 20];
        WeatherAppController.updateSavedCities(savedCities);
    }
}
