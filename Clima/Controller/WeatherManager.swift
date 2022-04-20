

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager:WeatherManager , weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=76c77e81e931b2012b8c2d80ff6656b0&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String) {
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latidute: CLLocationDegrees , longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latidute)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        //1.create a URL
        
        if let url = URL(string: urlString) {
            
            //2.create a URL session
            
            let session = URLSession(configuration: .default)
            
            //3.give the session a task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    
                    if  let weather =  parseJson(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4.start the task
            
            task.resume()
        }
        
        func parseJson(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try  decoder.decode(WeatherData.self, from: weatherData)
               
                let id = decodedData.weather[0].id
                let temp = decodedData.main.temp
                let name = decodedData.name
                
                let weather = WeatherModel(conditionId: id, cityname: name, temperature: temp)
                
                return weather
               
                
                
            }catch{
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
        
    }
    
    
}
