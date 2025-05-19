//
//  NetworkService.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import Foundation

enum NetworkError: Error {
    case noInternetConnection
    case serverUnavailable
    case timeout
    case invalidResponse
    case invalidURL
    case decodingFailed
    case isRequestInProgress
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "Отсутствует подключение к интернету"
        case .serverUnavailable:
            return "Сервер недоступен. Попробуйте позже."
        case .timeout:
            return "Превышено время ожидания ответа от сервера"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .invalidURL:
            return "Некорректный адрес сервера"
        case .decodingFailed:
            return "Ошибка обработки данных"
        case .isRequestInProgress:
            return "Запрос уже выполняется"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol NetworkServiceProtocol {
    func fetchWeatherData(completion: @escaping (Result<WeatherData, Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    private var session: URLSession
    private var coreDataService: CoreDataServiceProtocol
    private let apiKey: String
    
    private static let defaultSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: config)
    }()
    
    init(
        session: URLSession = NetworkService.defaultSession,
        coreDataService: CoreDataServiceProtocol = CoreDataService.shared
    ) {
        self.session = session
        self.coreDataService = coreDataService
        guard let key = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String else {
            fatalError("Missing API Key")
        }
        self.apiKey = key
    }
    
    private var isRequestInProgress = false
    private let requestQueue = DispatchQueue(label: "NetworkService.requestQueue", attributes: .concurrent)
    
    func fetchWeatherData(completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard !isRequestInProgress else {
            completeOnMain(.failure(NetworkError.isRequestInProgress), completion: completion)
            return
        }
        
        changeProgressState(with: true)
        
        guard let url = WeatherAPI.forecastURL(apiKey: apiKey) else {
            completeOnMain(.failure(NetworkError.invalidURL), completion: completion)
            changeProgressState(with: false)
            return
        }
        
        let request = URLRequest(url: url, timeoutInterval: 10)
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.changeProgressState(with: false) }
            
            if let error = error as NSError? {
                self.completeOnMain(.failure(self.mapError(error)), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data else {
                self.completeOnMain(.failure(NetworkError.invalidResponse), completion: completion)
                return
            }
            
            do {
                let weatherData = try JSONDecoderService.shared.decodeWeatherData(from: data)
                self.coreDataService.saveLastWeatherLikeRawJSON(data) { _ in }
                self.completeOnMain(.success(weatherData), completion: completion)
            } catch {
                self.completeOnMain(.failure(NetworkError.decodingFailed), completion: completion)
            }
        }.resume()
    }
    
    private func completeOnMain<T>(_ result: Result<T, Error>, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    private func changeProgressState(with value: Bool) {
        requestQueue.async(flags: .barrier) {
            self.isRequestInProgress = value
        }
    }
    
    private func mapError(_ error: NSError) -> NetworkError {
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            return .noInternetConnection
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
            return .serverUnavailable
        default:
            return .unknown(error)
        }
    }
}
