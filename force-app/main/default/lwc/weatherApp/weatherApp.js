import { LightningElement, track, api } from 'lwc';
import searchCity from '@salesforce/apex/WeatherAppController.searchCity';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSavedWeatherData from '@salesforce/apex/WeatherAppController.getSavedWeatherData';
import addCity from '@salesforce/apex/WeatherAppController.addCity';
import {deleteRecord} from 'lightning/uiRecordApi';


const columns = [
    {label: 'City', fieldName: 'City__c' },
    {label: 'Low (F)', fieldName: 'Low_Temperature__c', type: 'number'},
    {label: 'High (F)', fieldName: 'High_Temperature__c', type: 'number'},
    {label: 'Last Updated', fieldName: 'Last_Updated__c', type :'datetime'},
    {type: "button", typeAttributes: {
        label:'Remove',
        name: 'Remove',
        variant: 'Destructive',
        
    }} 
];

export default class WeatherApp extends LightningElement {
    @track citySearchList = [];
    searchValue = '';
    selectedCity = 0;
    searchResultsFound = true;
    isLoaded = true;
    foundSavedCities = false;
    @track weatherData = [];
    columns = columns;
    addedToFav = false;

  connectedCallback(){ 
    this.populateSavedCities(); 
    }

    populateSavedCities(){
     getSavedWeatherData() 
        .then(data => {
           
            console.log('this is printing..'+ 'size: '+ data.length);
            this.weatherData = data; 
            if(this.weatherData.length > 0){
                this.foundSavedCities = true;
            }else{
                this.foundSavedCities = false;
            }
            
        })
        .catch(err => console.log(err));
    }

    //search query string updated
    searchQuery(event){
        this.searchValue = event.target.value;
        if(event.keyCode === 13){
            this.handleSearchQuery();
        }
        
    }

    //call method on button click
    handleSearchQuery(){
        this.isLoaded = false;
        
        if(this.searchValue !== ''){    
            
            searchCity({query: this.searchValue})
            .then(data => {
                this.citySearchList =[];
                console.log('result'+ JSON.stringify(data));
                
                for(var key in data){
                    this.citySearchList.push({value:data[key], key:key});
                }
                if(this.citySearchList.length > 0){
                    this.searchResultsFound = true;
                }else{
                    this.searchResultsFound=false;
                }
                
               this.searchValue='';
               this.isLoaded = true;
            })
           
            .catch(error => {
                this.citySearchList = undefined;
                this.isLoaded=true;
                console.log(error);

            })
        }else{
            this.citySearchList = undefined;
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Please enter some text to start searching!',
            });
            this.dispatchEvent(event);
        }
        
    }

    //handle add City button click
    handleAddCity(event){
        this.selectedCity = event.target.value;
        console.log('selected city: '+this.selectedCity);
        
        addCity({woeid:this.selectedCity})
        .then(()=>{
           // this.citySearchList.delete(this.selectedCity);
            this.populateSavedCities()
        
            this.dispatchEvent(
                
                new ShowToastEvent({
                    title:'Success',
                    message: 'We are now tracking the weather for this city!',
                    variant: 'success'
                })
            );
           
        })
        .catch(error => {
            this.dispatchEvent(
            new ShowToastEvent({
                title:'Error',
                message: 'Failed to track this city!',
                variant:'error'
                
            }));
            console.log(error);

        })
    }

    deleteCity(event){
        const cityId = event.detail.row.Id;
        deleteRecord(cityId)
        .then(()=>{
            this.populateSavedCities()
            
            this.dispatchEvent(
                
                new ShowToastEvent({
                    title:'Success',
                    message: 'City Removed!',
                    variant: 'success'
                })
            );
           
        })
        .catch((error) =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'City Could Not Be Removed!',
                    variant: 'error'
                })
            );
        });
    }
}