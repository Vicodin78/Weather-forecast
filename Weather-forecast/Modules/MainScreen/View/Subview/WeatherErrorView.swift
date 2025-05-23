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
    
    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("Повторить", attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 16)]))
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        $0.configuration = config
        $0.layer.cornerRadius = 8
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .system))
    
    var onRetry: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .red.withAlphaComponent(0.2)
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.red.withAlphaComponent(0.3).cgColor
    }
    
    private lazy var collapsedHeightConstraint = heightAnchor.constraint(lessThanOrEqualToConstant: 0)
    
    private func setupLayout() {
        [iconImageView, titleLabel, messageLabel, retryButton].forEach { addSubview($0) }
        
        let constraintsArray = [
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            retryButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            retryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ]
        
        constraintsArray.forEach { $0.priority = .defaultHigh }
        collapsedHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        
        NSLayoutConstraint.activate([collapsedHeightConstraint])
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    @objc private func retryTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onRetry?()
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
        retryButton.isHidden = value
    }
    
}

