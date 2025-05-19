//
//  WeatherAPI.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import Foundation

struct WeatherAPI {
    static func forecastURL(for city: String = "moscow", days: Int = 5, apiKey: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.weatherapi.com"
        components.path = "/v1/forecast.json"
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "days", value: "\(days)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        return components.url
    }
}
