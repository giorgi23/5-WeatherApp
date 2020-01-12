
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    
        func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
        func didFailWithError(error: Error)
    
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=1fd31eb7c0f816e569221d2b5b34d51f&units=metric"
    
    func fetchWeather(cityName: String) {
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
        
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
        
    }
    
    func performRequest(with urlString: String) {
        //creating a URL
        
        if let url = URL(string: urlString) {
            
            
            //creating a session
            let session = URLSession(configuration: .default)
            
            
            //Give a task to session
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                
                if let safeData = data{
                    let dataString = String(data: safeData, encoding: .utf8)
                    print(dataString!)
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //starting the task
            task.resume()
        }
    }
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityname: name, temperature: temp)
            return weather
            
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    
}
