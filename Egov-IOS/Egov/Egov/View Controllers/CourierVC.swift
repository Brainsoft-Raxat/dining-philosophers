//
//  CourierVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import UIKit

final class CourierVC: UIViewController {
    
    private let networkingService: NetworkingLogic
    private let userName: UserName
    
    // - MARK: - Constants
    private struct Constants {
        static let padding: CGFloat = 16
        
        static let titleFontSize: CGFloat = 34
        
        static let headerTextHeight: CGFloat = 20
        static let headerTextWidth: CGFloat = 100
        static let headerTextFontSize: CGFloat = 15
        
        static let cellHeight: CGFloat = 76
        
        static let settingButtonImage: String = "gear"
    }
    
    // MARK: - Private Attributes
    
    private let viewModel: CourierViewModel = CourierViewModel()
    
    // MARK: - UI elements
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    private lazy var makeRequestOfDocuments: UIButton = {
        let button = UIButton()
        
        button.addTarget(self, action: #selector(makeRequestPressed), for: .touchUpInside)
        button.setTitle("Заказать", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.cellHeight
        
        tableView.register(InformationCell.self, forCellReuseIdentifier: InformationCell.className)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(networkingService: NetworkingLogic, userName: UserName) {
        self.networkingService = networkingService
        self.userName = userName
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addSubviews()
        setupConstraints()
        setupBinders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesBackButton = true
        viewModel.getOrders()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.hidesBackButton = false
    }
    
    // MARK: - Setup Binders
    
    private func setupBinders() {
        viewModel.getOrders()

        viewModel.$orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
            .store(in: &viewModel.channelsRequests)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard error != nil else { return }

                self?.networkingErrorAlert()

                self?.viewModel.error = nil
            }
            .store(in: &viewModel.channelsRequests)
    }
    
    // MARK: - View and NavigationBar setup
    
    private func setupView() {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Заказы"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: makeRequestOfDocuments)
    }
    
    // MARK: - Adding Subviews
    
    private func addSubviews() {
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    // - MARK: - Button Actions
    
    @objc
    private func makeRequestPressed() {
        navigationController?.pushViewController(DeliveryInformationVC(networkingService: networkingService,
                                                                       userName: userName),
                                                 animated: true)
    }
    
    @objc
    private func refresh() {
        viewModel.getOrders()
    }
    
    // MARK: - Alerts
    
    private func networkingErrorAlert() {
        let alert = UIAlertController(title: "Произошла ошибка сети", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        })
        
        if self.presentedViewController == nil {
            present(alert, animated: true)
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CourierVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InformationCell.className, for: indexPath) as? InformationCell
        else {
            return UITableViewCell()
        }
        
        let model = viewModel.orders[indexPath.row]
//        Kazakhstan, Astana, Qabanbay Batyr 53
        let address = "\(model.region), \(model.city), \(model.street) \(model.house)"
        let order = InformationModel(text: "Доставить по адресу:", details: address, image: "shippingbox", price: model.deliveryPrice)
        cell.configure(with: order)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(ConfirmOrderVC(order: viewModel.orders[indexPath.row], networkingService: networkingService), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
