//
//  WeatherAlertView.swift
//  Weather-forecast
//
//  Created by Vicodin on 22.05.2025.
//

import UIKit

final class WeatherAlertView: UIView {
    
    private let titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Последнее обновление:"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .right
        $0.numberOfLines = 1
        $0.isHidden = true
        return $0
    }(UILabel())
    
    private let messageLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.isHidden = true
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
        backgroundColor = .orange.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.orange.withAlphaComponent(0.13).cgColor
    }
    
    private lazy var collapsedHeightConstraint = heightAnchor.constraint(lessThanOrEqualToConstant: 0)
    
    private func setupLayout() {
        
        //Общие размеры и отсутпы
        let horizontalSpacing: CGFloat = 20
        let verticalSpacing: CGFloat = 8
        let interItemSpacing: CGFloat = 6
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stackView.axis = .horizontal
        stackView.spacing = interItemSpacing
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        let constraintsArray = [
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: verticalSpacing),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalSpacing),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: horizontalSpacing),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -horizontalSpacing),
            
            collapsedHeightConstraint
        ]
        
        constraintsArray.forEach { $0.priority = .defaultHigh }
        collapsedHeightConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([collapsedHeightConstraint])
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    func configureAndShowView(with date: String) {
        //Добавляем дату сохранения данных в кеш
        messageLabel.text = date
        
        //Отображаем представление
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
        titleLabel.isHidden = value
        messageLabel.isHidden = value
    }
    
}
