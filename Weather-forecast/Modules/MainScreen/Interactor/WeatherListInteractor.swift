//
//  WeatherListInteractor.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import Foundation

protocol WeatherListInteractorInput {
    func fetchWeatherData()
}

protocol WeatherListInteractorOutput: AnyObject {
    func displayData(_ data: WeatherData)
    func displayCachedData(_ data: WeatherCachedData)
    func displayError(_ error: Error)
}

final class WeatherListInteractor: WeatherListInteractorInput {
    
    weak var presenter: WeatherListInteractorOutput?
    var networkService: NetworkServiceProtocol?
    var coreDataService: CoreDataServiceProtocol?
    
    // Период времени когда кэш считается актуальным = 10 минут (600 секунд)
    private let cacheExpirationInterval: TimeInterval = 600
    
    // Переменные для повторного запроса данных в случае ошибки
    private let maxRetryAttempts = 5
    private let retryDelay = 3 // секунды
    private var numberOfAttempts = 0
    
    func fetchWeatherData() {
        networkService?.fetchWeatherData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                // data Сохраняется в кэш внутри NetworkService
                self.presenter?.displayData(data)
                self.numberOfAttempts = 0
            case .failure(let error):
                self.errorHandling(for: error)
            }
        }
    }
    
    private func fetchDataFromCache() {
        coreDataService?.fetchLastWeather { [weak self] result in
            guard let self else {
                print("WeatherListInteractor отсутствует.")
                return
            }
            switch result {
            case .success(let cachedData):
//                if self.isCacheFresh(cachedData.dateSaved) {
//                    self.presenter?.displayData(cachedData.data)
//                } else {
//                    self.presenter?.displayCachedData(cachedData)
//                }
                self.presenter?.displayCachedData(cachedData)
            case .failure(let coreDataError):
                presenter?.displayError(coreDataError)
            }
        }
    }
    
    private func errorHandling(for error: NetworkError) {
        switch error {
        case .invalidURL, .decodingFailed:
            presenter?.displayError(NetworkError.defaultError)
        case .isRequestInProgress:
            break
        case .unknown(let unknownError):
            presenter?.displayError(unknownError)
        default:
            presenter?.displayError(error)
            retryRequest()
        }
    }
    
    private func retryRequest() {
        // Показываем пользователю данные из кеша как временное решение
        fetchDataFromCache()
        
        // Начинаем фоновую повторную попытку загрузки данных из сети
        if numberOfAttempts < maxRetryAttempts {
            numberOfAttempts += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(numberOfAttempts * retryDelay)) {
                self.fetchWeatherData()
            }
        } else {
            // Если все попытки неудачны, выводим дефолтную ошибку
            presenter?.displayError(NetworkError.defaultError)
        }
    }
    
    private func isCacheFresh(_ dateSaved: Date) -> Bool {
        return Date().timeIntervalSince(dateSaved) < cacheExpirationInterval
    }
}
