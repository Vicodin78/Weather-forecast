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
            for (index, weather) in weathers.enumerated() {
                let dayLabel = index == 0 ? "Сегодня" : dayName(for: weather.date)
                cellModels.append(makeCellViewModel(from: weather, with: dayLabel))
            }
        }
        
        return makeCurrentViewModel(from: data)
    }
    
    private func makeCellViewModel(from weather: Forecastday, with dayLabel: String) -> WeatherCellViewModel {
        let temperature = weather.day?.avgtempC.map { "\(Int($0))°" } ?? "—"
        let wind = weather.day?.maxwindKph.map { "\(Int($0 / 3.6)) м/с" } ?? "—" //Переводим в м/с
        let humidity = weather.day?.avghumidity.map { "\(Int($0)) 💧" } ?? "—"
        
        return WeatherCellViewModel(
            day: dayLabel,
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
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            // Готовим для вью только время
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date).description
        } else {
            // Дата + время
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            return formatter.string(from: date).description
        }
    }
    
    private func dayName(for dateString: String?) -> String {
        guard let dateString = dateString else { return "-" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        guard let date = dateFormatter.date(from: dateString) else { return "-" }

        let shortWeekdayFormatter = DateFormatter()
        shortWeekdayFormatter.locale = Locale(identifier: "ru_RU")
        shortWeekdayFormatter.dateFormat = "EE" // краткое название: Пн, Вт, Ср

        return shortWeekdayFormatter.string(from: date)
    }
}

// MARK: - WeatherListInteractorOutput
extension WeatherListPresenter: WeatherListInteractorOutput {
    
    func displayData(_ data: WeatherData) {
        let data = prepareViewModel(from: data)
        view?.displayWeatherData(data)
    }
    
    func displayCachedData(_ cache: WeatherCachedData) {
        let data = prepareViewModel(from: cache.data)
        let dateSaved = formatDate(cache.dateSaved)
        
        view?.displayWeatherCachedData(data, dateSaved)
    }
    
    func displayError(_ error: any Error) {
        view?.displayError(error)
    }
}
