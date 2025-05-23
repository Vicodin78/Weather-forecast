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
    func displayWeatherCachedData(_ data: CurrentWeatherViewModel, _ date: String)
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
        interactor.fetchWeatherData()
    }
    
    func updateWeatherList() {
        viewDidLoad()
    }
    
    func numberOfRows() -> Int {
        cellModels.count
    }
    
    func model(at index: Int) -> WeatherCellViewModel {
        guard cellModels.indices.contains(index) else {
            return WeatherCellViewModel(day: "-", iconURL: "-", description: "-", temperature: "—", wind: "—", humidity: "—")
        }
        return cellModels[index]
    }
    
    private func prepareViewModel(from data: WeatherData) -> CurrentWeatherViewModel {
        cellModels.removeAll()
        
        if let weathers = data.forecast?.forecastday {
            for weather in weathers {
                cellModels.append(makeCellViewModel(from: weather))
            }
        }
        
        return makeCurrentViewModel(from: data)
    }
    
    private func makeCellViewModel(from weather: Forecastday) -> WeatherCellViewModel {
        let temperature = weather.day?.avgtempC.map { "\(Int($0))°" } ?? "—"
        let wind = weather.day?.maxwindKph.map { "\(Int($0 / 3.6)) м/с" } ?? "—" //Переводим в м/с
        let humidity = weather.day?.avghumidity.map { "\(Int($0)) 💧" } ?? "—"
        
        return WeatherCellViewModel(
            day: weather.date ?? "-",
            iconURL: weather.day?.condition?.icon ?? "-",
            description: weather.day?.condition?.text ?? "-",
            temperature: temperature,
            wind: wind,
            humidity: humidity
        )
    }
    
    private func makeCurrentViewModel(from weather: WeatherData) -> CurrentWeatherViewModel {
        let temperature = weather.current?.tempC.map { "\(Int($0))" } ?? "—"
        
        return CurrentWeatherViewModel(
            city: weather.location?.name ?? "—",
            iconURL: weather.current?.condition?.icon ?? "",
            description: weather.current?.condition?.text ?? "—",
            temperature: temperature
        )
    }
}

// MARK: - WeatherListInteractorOutput
extension WeatherListPresenter: WeatherListInteractorOutput {
    
    func displayData(_ data: WeatherData) {
        view?.displayWeatherData(prepareViewModel(from: data))
    }
    
    func displayCachedData(_ cache: WeatherCachedData) {
        view?.displayWeatherCachedData(prepareViewModel(from: cache.data), cache.dateSaved.description)
    }
    
    func displayError(_ error: any Error) {
        view?.displayError(error)
    }
}
