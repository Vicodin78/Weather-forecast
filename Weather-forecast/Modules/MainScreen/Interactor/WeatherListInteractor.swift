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
    func displayFreshData(_ data: WeatherData)
    func displayCachedData(_ data: WeatherCachedData, silently: Bool)
    func displayError(_ error: Error)
}

final class WeatherListInteractor: WeatherListInteractorInput {
    
    weak var presenter: WeatherListInteractorOutput?
    var networkService: NetworkServiceProtocol?
    var coreDataService: CoreDataServiceProtocol?
    
    // Период времени когда кэш считается актуальным = 10 минут (600 секунд)
    private let cacheExpirationInterval: TimeInterval = 600
    
    // Переменные для повторного запроса данных в случае ошибки
    private let maxRetryAttempts = 3
    private let retryDelay = 3 // секунды
    private var numberOfAttempts = 0
    
    func fetchWeatherData() {
        fetchCachedData()
        
        networkService?.fetchWeatherData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                // data Сохраняется в кэш внутри NetworkService
                self.presenter?.displayFreshData(data)
                self.numberOfAttempts = 0
            case .failure(let error):
                self.errorHandling(for: error)
            }
        }
    }
    
    private func fetchCachedData() {
        coreDataService?.fetchLastWeather { [weak self] result in
            guard let self else {
                print("WeatherListInteractor деинициализирован")
                return
            }
            
            switch result {
            case .success(let cachedData):
                self.processCachedData(cachedData)
            case .failure(let coreDataError):
                self.presenter?.displayError(coreDataError)
            }
        }
    }
    
    private func processCachedData(_ cachedData: WeatherCachedData) {
        let isFreshCache = isCacheFresh(cachedData.dateSaved)
        let isFirstAttempt = numberOfAttempts == 0
        
        let shouldSendSilently = isFreshCache && isFirstAttempt
        
        presenter?.displayCachedData(cachedData, silently: shouldSendSilently)
        // Если кеш свежий и это не последняя попытка получить данные из сети отправляем его тихо (без уведомления), если нет - с уведомлением
    }
    
    private func errorHandling(for error: NetworkError) {
        switch error {
        case .isRequestInProgress:
            break
        case .invalidURL, .decodingFailed:
            presenter?.displayError(NetworkError.defaultError)
        case .unknown(let unknownError):
            presenter?.displayError(unknownError)
        case .invalidResponse,
            .noInternetConnection,
            .serverUnavailable,
            .timeout,
            .defaultError:
            
            handleRetryOrFail(with: error)
        }
    }
    
    private func handleRetryOrFail(with error: NetworkError) {
        if numberOfAttempts < maxRetryAttempts {
            retryRequest() // Начинаем фоновую повторную попытку загрузки данных из сети
        } else {
            presenter?.displayError(error) // Если все попытки неудачны, выводим ошибку
            numberOfAttempts = 0
        }
    }
    
    private func retryRequest() {
        numberOfAttempts += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(numberOfAttempts * retryDelay)) {
            self.fetchWeatherData()
        }
    }
    
    private func isCacheFresh(_ dateSaved: Date) -> Bool {
        return Date().timeIntervalSince(dateSaved) < cacheExpirationInterval
    }
}
