//
//  Weather+Date.swift
//  Cowabunga
//
//  Created by XQF on 04.03.23.
//

import Foundation


private let apiKey = "a6b243f000737fa523434d1e8fc4d1a7"


let dailyUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=\(apiKey)&units=metric&lang=en"


struct DailyWeatherMain: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
}

struct DailyWeather: Codable {
    let main: DailyWeatherMain
    let name: String
    let weather: [WeatherDescription]
    let wind: Wind
    let visibility: Int
}
struct WeatherDescription: Codable {
    let description: String
    let id: Int
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
}



func fetchWeather (lat: Double, lon: Double, success: @escaping (_ str: String) -> Void, failure: @escaping (_ error: String) -> Void){
    let locatedDailyUrl = URL(string: dailyUrl + "&lon=\(lon)&lat=\(lat)")
    let session = URLSession.shared
    let request = URLRequest(url: locatedDailyUrl!)
          
     let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
         guard error == nil else {
             return
         }
         guard let data = data else {
             return
         }
              
        do {
            let weather = try JSONDecoder().decode(DailyWeather.self, from: data)
            let temp = Double(round(10 * weather.main.temp) / 10)
            let tempStr = "\(temp)°, \(weather.name.substring(toIndex: 3))"
            success(tempStr)
        } catch let error {
          print("error ",error.localizedDescription)
            failure(error.localizedDescription)
        }
     })
     task.resume()
}


func setTimeSeconds() {
    let calendar = Calendar.current
    let date = Date()
    let hour = calendar.component(.hour, from: date)
    let hourFinal = UserDefaults.standard.bool(forKey: "Time24Hour") ? hour : (hour%12 == 0 ? 12 : hour%12)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    
    let newStr: String = "\(hourFinal):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    
    if newStr.utf8CString.count <= 64 {
        StatusManager.sharedInstance().setTime(newStr)
    } else {
        StatusManager.sharedInstance().setTime("Length Error")
    }
}


func setCrumbDate() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM"
    
    var newStr: String = dateFormatter.string(from: Date())
    if UserDefaults.standard.bool(forKey: "moreOnTheRight") {
        newStr = "         " + newStr
    }
    if (newStr + " ▶").utf8CString.count <= 256 {
        StatusManager.sharedInstance().setCrumb(newStr)
    } else {
        StatusManager.sharedInstance().setCrumb("Length Error")
    }
}
func setCrumbWeather() {
    guard let lat = ApplicationMonitor.shared.locationManager.locationManager.location?.coordinate.latitude else {
        return
    }
    guard let long = ApplicationMonitor.shared.locationManager.locationManager.location?.coordinate.longitude else {
        return
    }
    fetchWeather(lat: lat, lon: long) { str in
        var newStr = str
        if UserDefaults.standard.bool(forKey: "moreOnTheRight") {
            newStr = "    " + newStr
        }
        if (newStr + " ▶").utf8CString.count <= 256 {
            StatusManager.sharedInstance().setCrumb(newStr)
        } else {
            StatusManager.sharedInstance().setCrumb("Length Error")
        }
    } failure: { error in
        StatusManager.sharedInstance().setCrumb("error")
    }
}







extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
