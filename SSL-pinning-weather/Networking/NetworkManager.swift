//
//  NetworkManager.swift
//  SSL-pinning-weather
//
//  Created by Rohit Ragmahale on 16/02/2023.
//

import Foundation

protocol DataManager {
    func getCityWeatherData(completion: @escaping ((_ data: WeatherResponse?, _ error: Error?) -> Void))
}

enum DataError: Error {
    case someError
}

// ADD WEATHER_APP_ID
private let appID = "WEATHER_APP_ID"
private let leedsWeatherURL = "https://api.openweathermap.org/data/2.5/weather?q=leeds&appid=\(appID)&units=metric"

class NetworkManager:  NSObject {
    static let shared = NetworkManager()
    var session: URLSession!
    var urlCredentials: URLCredential? {
        return URLCredential(user: "", password: "", persistence: .forSession)
    }
    
    private override init() {
        super.init()
        session = URLSession.init(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
    }
}

extension NetworkManager: DataManager {
    func getCityWeatherData(completion: @escaping ((WeatherResponse?, Error?) -> Void)) {
        guard let url = URL(string: leedsWeatherURL) else { return }
        
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                print(error)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, DataError.someError)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(WeatherResponse.self, from: data)
                completion(response, nil)
            } catch let error {
                completion(nil, error)
            }
        }.resume()
        
    }
}


