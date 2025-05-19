//
//  JSONDecoderService.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import Foundation

struct TimeZoneWrapper: Codable {
    let location: Location?
}

final class JSONDecoderService {
    
    static let shared = JSONDecoderService()
    
    private init() {}
    
    private var cachedTimeZoneID: String?
    
    func resetTimeZoneID() {
        cachedTimeZoneID = nil
    } // на случай внедрения смены города
    
    private func getDateFormatter(from timeZone: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZone)
        return formatter
    }
    
    private func getJSONDecoder(with formatter: DateFormatter) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
    
    func decodeWeatherData(from data: Data) throws -> WeatherData {
        let timeZoneID = cachedTimeZoneID ?? getTimeZoneID(from: data)
        let formatter = getDateFormatter(from: timeZoneID)
        let decoder = getJSONDecoder(with: formatter)
        return try decoder.decode(WeatherData.self, from: data)
    }
    
    private func getTimeZoneID(from data: Data) -> String {
        let errorGettingTimeZone: (Error?) -> String = { error in
            let message = error.map { "Не удалось декодировать TimeZone из JSON: \($0)" }
                ?? "Не удалось извлечь TimeZone ID"
            print(message)
            return TimeZone.current.identifier
        }
        
        do {
            guard let id = try JSONDecoder().decode(TimeZoneWrapper.self, from: data).location?.tzID else {
                return errorGettingTimeZone(nil)
            }
            cachedTimeZoneID = id
            return id
        } catch {
            return errorGettingTimeZone(error)
        }
    }
}
