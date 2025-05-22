//
//  WeatherListPresenter.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import Foundation

protocol WeatherListPresenterInput {
    func viewDidLoad()
    func numberOfRows() -> Int
    func model(at index: Int) -> WeatherCellViewModel
    func updateWeatherList()
}

protocol WeatherListPresenterOutput: AnyObject {
    func displayWeatherData(_ data: CurrentWeatherViewModel)
    func displayError(_ error: Error)
}

final class WeatherListPresenter: WeatherListPresenterInput {

    weak var view: WeatherListPresenterOutput?
    private let interactor: WeatherListInteractorInput
    var router: WeatherListRouterInput?
    
    private var cellModels: [WeatherCellViewModel] = []
    
    init(view: WeatherListPresenterOutput, interactor: WeatherListInteractorInput) {
        self.view = view
        self.interactor = interactor
    }

    func viewDidLoad() {
        interactor.fetchWeatherData { [weak self] result in
            guard let self else { return }
            switch result {
            case .fresh(let weatherData):
                self.prepareAndTransmit(data: weatherData)
            case .cached(let weatherData, let originalError):
                self.prepareAndTransmit(data: weatherData)
                self.view?.displayError(originalError)
            case .failure(let error):
                self.view?.displayError(error)
            }
        }
    }
    
    func updateWeatherList() {
        viewDidLoad()
    }
    
    func numberOfRows() -> Int {
        cellModels.count
    }
    
    func model(at index: Int) -> WeatherCellViewModel {
        cellModels[index]
    }
    
    private func prepareAndTransmit(data: WeatherData) {
        cellModels.removeAll()
        
        guard let weathers = data.forecast?.forecastday else { return }
        for weather in weathers {
            cellModels.append(prepareData(for: weather))
        }
        
        let currentWeather = prepareData(for: data)
        view?.displayWeatherData(currentWeather)
    }
    
    private func prepareData(for weather: Forecastday) -> WeatherCellViewModel {
        return WeatherCellViewModel(
            day: weather.date ?? "-",
            iconURL: weather.day?.condition?.icon ?? "-",
            description: weather.day?.condition?.text ?? "-",
            temperature: weather.day?.avgtempC != nil ? "\(Int(weather.day!.avgtempC!))°" : "—",
            wind: weather.day?.maxwindKph != nil ? "\(Int(weather.day!.maxwindKph! / 3.6)) м/с" : "—", //Переводим в м/с для привычного отображения
            humidity: weather.day?.avghumidity != nil ? "\(Int(weather.day!.avghumidity!)) 💧" : "—"
        )
    }
    
    private func prepareData(for currentWeather: WeatherData) -> CurrentWeatherViewModel {
        return CurrentWeatherViewModel(
            city: currentWeather.location?.name ?? "—",
            iconURL: currentWeather.current?.condition?.icon ?? "",
            description: currentWeather.current?.condition?.text ?? "—",
            temperature: currentWeather.current?.tempC != nil ? "\(Int(currentWeather.current!.tempC!))°" : "—"
        )
    }
}

// MARK: - WeatherListInteractorOutput
extension WeatherListPresenter: WeatherListInteractorOutput {
    func displayError(_ error: any Error) {
        view?.displayError(error)
    }
}
