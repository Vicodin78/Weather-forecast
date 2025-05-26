//
//  WeatherListBuilder.swift
//  Weather-forecast
//
//  Created by Vicodin on 20.05.2025.
//

import UIKit

final class WeatherListBuilder {

    static func build() -> UIViewController {
        let viewController = MainWeatherViewController()
        let interactor = WeatherListInteractor()
        let presenter = WeatherListPresenter(view: viewController, interactor: interactor)
        let router = WeatherListRouter()
        let networkService = NetworkService()
        let coreDataService = CoreDataService.shared
        
        presenter.router = router
        interactor.presenter = presenter
        interactor.networkService = networkService
        interactor.coreDataService = coreDataService
        viewController.presenter = presenter
        router.viewController = viewController
        
        return viewController
    }
}
