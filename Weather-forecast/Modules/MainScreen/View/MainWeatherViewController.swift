//
//  MainWeatherViewController.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import UIKit

final class MainWeatherViewController: UIViewController, WeatherListPresenterOutput {
    
    var presenter: WeatherListPresenterInput!
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var errorView: WeatherErrorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(WeatherErrorView())
    
    private let alertView: WeatherAlertView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(WeatherAlertView())
    
    private let currentWeatherView: CurrentWeatherView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(CurrentWeatherView())
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: WeatherTableViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.showsVerticalScrollIndicator = false
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    @objc private func handleRefresh() {
        presenter.updateWeatherList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        alertView.hideView()
        errorView.hideView()
        layout()
        subscribeToNotification()
    }
    
    private func subscribeToNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func displayWeatherData(_ data: CurrentWeatherViewModel) {
        alertView.hideView()
        errorView.hideView()
        currentWeatherView.setDataForView(from: data)
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func displayCachedData(_ data: CurrentWeatherViewModel) {
        currentWeatherView.setDataForView(from: data)
        tableView.reloadData()
    }
    
    func displayOutdatedCacheAlert(_ date: String) {
        alertView.configureAndShowView(with: date)
    }
    
    func displayError(_ error: any Error) {
        errorView.configureAndShowView(with: error)
        refreshControl.endRefreshing()
    }
    
    private func layout() {
        
        //Общие размеры и отсутпы
        let horizontalSpacing: CGFloat = 16
        let verticalSpacing: CGFloat = 16
        let interItemSpacing: CGFloat = 16
        
        [errorView, currentWeatherView, alertView, tableView].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalSpacing),
            errorView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing),
            errorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalSpacing),
            
            currentWeatherView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalSpacing),
            currentWeatherView.topAnchor.constraint(equalTo: errorView.bottomAnchor, constant: interItemSpacing),
            currentWeatherView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalSpacing),
            
            alertView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalSpacing),
            alertView.topAnchor.constraint(equalTo: currentWeatherView.bottomAnchor, constant: interItemSpacing/2),
            alertView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalSpacing),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: alertView.bottomAnchor, constant: interItemSpacing),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -verticalSpacing)
        ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - UITableViewDataSource
extension MainWeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.setupCell(with: presenter.model(at: indexPath.row))
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MainWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
