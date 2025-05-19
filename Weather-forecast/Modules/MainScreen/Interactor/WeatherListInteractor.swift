//
//  WeatherListInteractor.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import Foundation

enum WeatherFetchResult {
    case fresh(WeatherData)
    case cached(WeatherData, originalError: Error)
    case failure(Error)
}

enum CompositeError: Error {
    case bothFailed(network: Error, cache: Error)
}

protocol WeatherListInteractorInput {
    func fetchWeatherData(completion: @escaping (WeatherFetchResult) -> Void)
}

protocol WeatherListInteractorOutput: AnyObject {
    func displayError(_ error: Error)
}

final class WeatherListInteractor: WeatherListInteractorInput {
    
    weak var presenter: WeatherListInteractorOutput?
    var networkService: NetworkServiceProtocol?
    var coreDataService: CoreDataServiceProtocol?
    
    func fetchWeatherData(completion: @escaping (WeatherFetchResult) -> Void) {
        networkService?.fetchWeatherData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                completion(.fresh(data))
                
            case .failure(let error):
                self.coreDataService?.fetchLastWeather { coreDataResult in
                    switch coreDataResult {
                    case .success(let cachedData):
                        completion(.cached(cachedData, originalError: error))
                    case .failure(let coreDataError):
                        completion(.failure(CompositeError.bothFailed(network: error, cache: coreDataError)))
                    }
                }
            }
        }
    }
}
