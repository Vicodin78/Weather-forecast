//
//  CoreDataService.swift
//  Weather-forecast
//
//  Created by Vicodin on 18.05.2025.
//

import Foundation
import CoreData

struct WeatherCachedData {
    let id: UUID
    let data: WeatherData
    let dateSaved: Date
}

protocol CoreDataServiceProtocol {
    func saveLastWeatherLikeRawJSON(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchLastWeather(completion: @escaping (Result<WeatherCachedData, Error>) -> Void)
}

enum CoreDataServiceError: Error, LocalizedError {
    case noCachedWeather
    
    var errorDescription: String? {
        switch self {
        case .noCachedWeather:
            return "Нет сохранённых данных о погоде."
        }
    }
}

final class CoreDataService: CoreDataServiceProtocol {
    
    static let shared = CoreDataService()
    private var persistentContainer: NSPersistentContainer
    private lazy var context = persistentContainer.newBackgroundContext()
    
    init(persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "Weather_forecast")) {
        self.persistentContainer = persistentContainer
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка загрузки CoreData: \(error)")
            }
        }
    }
    
    func saveLastWeatherLikeRawJSON(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteLastWeather { result in
            switch result {
            case .success():
                self.saveHelper(data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func saveHelper(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            do {
                let weatherCache = WeatherCache(context: self.context)
                weatherCache.id = UUID()
                weatherCache.jsonData = data
                weatherCache.dateSaved = Date()
                
                try self.context.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
                print("JSON сохранён в Core Data")
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print("Ошибка при сохранении JSON в Core Data: \(error)")
            }
        }
    }
    
    func fetchLastWeather(completion: @escaping (Result<WeatherCachedData, Error>) -> Void) {
        context.perform {
            let fetchRequest: NSFetchRequest<WeatherCache> = WeatherCache.fetchRequest()
            
            do {
                //Извлекаем кеш и разворачиваем опциональные значения
                if let weatherCache = try self.context.fetch(fetchRequest).first,
                   let id = weatherCache.id,
                   let data = weatherCache.jsonData,
                   let dateSaved = weatherCache.dateSaved
                {
                    //Декодируем данные и собираем в структуру
                    let weatherData = try JSONDecoderService.shared.decodeWeatherData(from: data)
                    let result = WeatherCachedData(id: id, data: weatherData, dateSaved: dateSaved)
                    DispatchQueue.main.async {
                        //Возкращаем полученную структуру источнику запроса
                        completion(.success(result))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(CoreDataServiceError.noCachedWeather))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func deleteLastWeather(completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = WeatherCache.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.context.execute(deleteRequest)
                try self.context.save() // опционально, можно и убрать, но лишним не будет
                DispatchQueue.main.async {
                    completion(.success(()))
                }
                print("Все записи WeatherCache удалены из Core Data")
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print("Ошибка при удалении записей WeatherCache: \(error)")
            }
        }
    }
}
