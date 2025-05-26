//
//  WeatherListRouter.swift
//  Weather-forecast
//
//  Created by Vicodin on 20.05.2025.
//

import UIKit

protocol WeatherListRouterInput: AnyObject {
    
}

final class WeatherListRouter: WeatherListRouterInput {
    weak var viewController: UIViewController?
}
