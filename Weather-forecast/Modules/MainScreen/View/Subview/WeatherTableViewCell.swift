//
//  WeatherTableViewCell.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import UIKit

final class WeatherTableViewCell: UITableViewCell {
    
    private let day: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    private let icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    private let weatherDescription: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    private let temperature: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .white
        return $0
    }(UILabel())
    
    private let wind: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .white
        return $0
    }(UILabel())
    
    private let humidity: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .white
        return $0
    }(UILabel())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with data: WeatherCellViewModel) {
        day.text = data.day
        weatherDescription.text = data.description
        temperature.text = data.temperature
        wind.text = data.wind
        humidity.text = data.humidity
        ImageLoaderService.shared.loadImage(from: data.iconURL) { [weak self] image in
            self?.icon.image = image
        }
    }
    
    private func layout() {
        
        //Общие размеры и отсутпы
        let iconSize: CGFloat = 32
        let horizontalSpacing: CGFloat = 16
        let verticalSpacing: CGFloat = 8
        let interItemSpacing: CGFloat = 12
        
        
        let dayDescriptionStack = UIStackView(arrangedSubviews: [day, weatherDescription])
        dayDescriptionStack.axis = .vertical
        dayDescriptionStack.spacing = 4
        dayDescriptionStack.translatesAutoresizingMaskIntoConstraints = false
        dayDescriptionStack.alignment = .leading
        
        let metricsStack = UIStackView(arrangedSubviews: [temperature, wind, humidity])
        metricsStack.axis = .horizontal
        metricsStack.spacing = interItemSpacing
        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        metricsStack.alignment = .trailing
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        [dayDescriptionStack, icon, metricsStack].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            dayDescriptionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalSpacing),
            dayDescriptionStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing),
            dayDescriptionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalSpacing),
            dayDescriptionStack.widthAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.width / 2),

            icon.leadingAnchor.constraint(lessThanOrEqualTo: dayDescriptionStack.trailingAnchor, constant: interItemSpacing),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.heightAnchor.constraint(equalToConstant: iconSize),

            metricsStack.leadingAnchor.constraint(lessThanOrEqualTo: icon.trailingAnchor, constant: interItemSpacing),
            metricsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalSpacing),
            metricsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
    }
}
