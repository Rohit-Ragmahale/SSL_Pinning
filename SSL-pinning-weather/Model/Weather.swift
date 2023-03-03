//
//  Weather.swift
//  SSL-pinning-weather
//
//  Created by Rohit Ragmahale on 16/02/2023.
//

import Foundation

struct WeatherResponse: Decodable {
    let main: Weather
    let base: String
}


struct Weather: Decodable {
    let temp: Double?
    let humidity: Double?
}
