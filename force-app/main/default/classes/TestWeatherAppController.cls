@istest
public class TestWeatherAppController {
    
    static testmethod void testAddCity (){
       /* StaticResourceCalloutMock mock= new StaticResourceCalloutMock();
        mock.setStaticResource('GetWeatherResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');*/
        Test.setMock(HttpCalloutMock.class,new MetaWeatherHttpCalloutMock());

      /*  List<MetaWeather__c> savedCities = new List<MetaWeather__c>();

        for(integer i =0 ; i <=5; i++){
            MetaWeather__c tempRec = new MetaWeather__c(city__c = 'Test'+i, woeid__c = 1234+1);
            savedCities.add(tempRec);
        }*/
        Integer testWOEID = 44418;
        String action = 'getWeather';

        Test.startTest();
        String response = WeatherAppController.addCity(testWOEID);
        Test.stopTest();
        System.assertEquals('Successfully Added the city to your Favorites!',response);

        List<MetaWeather__c> mw = [Select id, woeid__c FROM MetaWeather__c Where woeid__c=:testWOEID];
        System.assertEquals(1,mw.size());


    }
    static testmethod void testUpdateCities(){
        Test.setMock(HttpCalloutMock.class,new MetaWeatherHttpCalloutMock());
        List<MetaWeather__c> savedCities = new List<MetaWeather__c>();

        for(integer i =0 ; i <=5; i++){
            MetaWeather__c tempRec = new MetaWeather__c(city__c= 'Test'+ String.valueOf(i), woeid__c = 1234+i);
            savedCities.add(tempRec);
        }

        MetaWeather__c testC = new MetaWeather__c(city__c ='London', woeid__c = 44418);
        savedCities.add(testC);

        insert savedCities;

        
        

        List<MetaWeather__c> beforeUpdateList = [SELECT id, woeid__c, Last_Updated__c FROM MetaWeather__c];
        Test.startTest();
        WeatherAppController.updateSavedCities(savedCities);

        Test.stopTest();

        List<MetaWeather__c> afterUpdateList = [SELECT id, woeid__c, Last_Updated__c FROM MetaWeather__c];

        for(integer i =0 ; i < afterUpdateList.size(); i++){
            System.assertNOTEquals(beforeUpdateList[i].last_updated__c,afterUpdateList[i].last_updated__c);
        }
        
    }

}
