//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
// 1. import CoreLocation
import CoreLocation
import Alamofire
import SwiftyJSON


// 2 .Add CLLocationManagerDelegate
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "531f5508f22bb1668df89181cf760723"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    var isToggled : Bool = true

    //TODO: 3 .Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            temperatureLabel.text = "\(weatherDataModel.temperatureInCelsius)°C"
            isToggled = true
        }
        else {
            temperatureLabel.text = "\(weatherDataModel.temperatureInFahrenheit)°F"
            isToggled = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO: 4.a Set up the location manager here.
        locationManager.delegate = self
        // 4.b You are able to set varying degrees of accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // 4.c Triggers authorization from the user
        locationManager.requestWhenInUseAuthorization()
        // Sends coordinates to the delegate
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData( url : String, parameters : [String : String] ) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
        response in
            if response.result.isSuccess {
                print("Success!! Got the weather data.")
                
                //SwiftyJSON allows the JSON method
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double {
        weatherDataModel.temperatureInCelsius = Int(tempResult - 273.15)
        
        weatherDataModel.temperatureInFahrenheit = Int((tempResult * (9/5)) - 459.67)
        weatherDataModel.city = json["name"].stringValue
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        if isToggled {
            temperatureLabel.text = "\(weatherDataModel.temperatureInCelsius)°C"
        } else {
        temperatureLabel.text = "\(weatherDataModel.temperatureInFahrenheit)°F"
        }
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL, parameters : params)
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
}


