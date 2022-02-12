global class WebService {
    
    @AuraEnabled
    global static string methodName(){
        try {
            //send request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Label.MetaWeatherAPI);
            req.setMethod('GET');


            Http http = new Http()
            HttpResponse res = http.send(req);
            JSONParser parser = JSON.createParser(res.getBody());

            MetaWeatherDataWrapper weatherData = new MetaWeatherDataWrapper();

            while(parser.nextToken() != null){
                
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public WebService() {

    }
}
