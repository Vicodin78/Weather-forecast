//
//  WeatherErrorView.swift
//  Weather-forecast
//
//  Created by Vicodin on 22.05.2025.
//

import UIKit

final class WeatherErrorView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wifi.exclamationmark")
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Что-то пошло не так"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let messageLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .red.withAlphaComponent(0.15)
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.red.withAlphaComponent(0.17).cgColor
    }
    
    private lazy var collapsedHeightConstraint = heightAnchor.constraint(lessThanOrEqualToConstant: 0)
    
    private func setupLayout() {
        
        //Общие размеры и отсутпы
        let iconSize: CGFloat = 40
        let horizontalSpacing: CGFloat = 20
        let verticalSpacing: CGFloat = 16
        let interItemSpacing: CGFloat = 8
        
        [iconImageView, titleLabel, messageLabel].forEach { addSubview($0) }
        
        let constraintsArray = [
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: verticalSpacing),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: interItemSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalSpacing),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: interItemSpacing),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalSpacing),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalSpacing)
        ]
        
        constraintsArray.forEach { $0.priority = .defaultHigh }
        collapsedHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        
        NSLayoutConstraint.activate([collapsedHeightConstraint])
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    func configureAndShowView(with error: Error) {
        //Добавляем описание ошибки в messageLabel
        if let error = error as? NetworkError {
            titleLabel.text = "Не удалось загрузить данные"
            messageLabel.text = error.localizedDescription
        } else {
            messageLabel.text = error.localizedDescription
        }
        //Включаем отображение представления
        subviewsIsHidden(false)
        NSLayoutConstraint.deactivate([collapsedHeightConstraint])
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func hideView() {
        subviewsIsHidden(true)
        UIView.animate(withDuration: 0.3) {
            NSLayoutConstraint.activate([self.collapsedHeightConstraint])
            self.layoutIfNeeded()
        }
    }
    
    private func subviewsIsHidden(_ value: Bool) {
        iconImageView.isHidden = value
        titleLabel.isHidden = value
        messageLabel.isHidden = value
    }
    
}

