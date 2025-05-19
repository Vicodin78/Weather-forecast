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
    
    private let currentWeatherView = CurrentWeatherView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: WeatherTableViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.showsVerticalScrollIndicator = false
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    @objc private func refreshData() {
        presenter.updateWeatherList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        layout()
        subscribeToNotification()
    }
    
    private func subscribeToNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshData),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func displayWeatherData(_ data: CurrentWeatherViewModel) {
        currentWeatherView.setDataForView(from: data)
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func displayError(_ error: any Error) {
        
    }
    
    private func layout() {
        [currentWeatherView, tableView].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            currentWeatherView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            currentWeatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            currentWeatherView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: currentWeatherView.bottomAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

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

extension MainWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
