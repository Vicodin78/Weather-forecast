//
//  CurrentWeatherView.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import UIKit

final class CurrentWeatherView: UIView {

    private let cityName: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    private let temperature: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 96, weight: .medium)
        $0.textColor = .white
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let weatherDescription: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    private let icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDataForView(from weatherData: CurrentWeatherViewModel) {
        cityName.text = weatherData.city
        temperature.text = weatherData.temperature
        weatherDescription.text = weatherData.description
        ImageLoaderService.shared.loadImage(from: weatherData.iconURL) { [weak self] image in
            self?.icon.image = image
        }
    }
    
    private func layout() {
        
        [cityName, temperature, weatherDescription, icon].forEach { addSubview($0) }
        
        let spacing: CGFloat = 8
        let iconSize: CGFloat = 60
        
        NSLayoutConstraint.activate([
            cityName.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            cityName.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            temperature.topAnchor.constraint(equalTo: cityName.bottomAnchor, constant: spacing),
            temperature.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20),
            
            weatherDescription.topAnchor.constraint(equalTo: temperature.bottomAnchor, constant: spacing),
            weatherDescription.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            icon.topAnchor.constraint(equalTo: weatherDescription.bottomAnchor, constant: spacing),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.heightAnchor.constraint(equalToConstant: iconSize),
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
