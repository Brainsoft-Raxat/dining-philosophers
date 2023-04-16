//
//  PaymentVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import UIKit

final class PaymentVC: UIViewController {
    
    private var informationModels = [InformationModel(text: "Отдел выдачи",
                                                      details: "ЦОН ул. Керей, Жанибек хандар 4, Астана",
                                                      image: "mappin.and.ellipse"),
                                     InformationModel(text: "Jusan",
                                                      details: "Списывается с выбранных карт\nНажмите чтобы поменять",
                                                      image: "creditcard.circle")
    ]
    
    private let order: ResponseOrder
    private let networkingService: NetworkingLogic
    private let userName: UserName
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        
        tableView.register(InformationCell.self, forCellReuseIdentifier: InformationCell.className)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.tintColor = .black
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        
        return button
    }()
    
    private lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Цены в KZT с учетом налогов"
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Примечание: Сумма формируется от расстояния ЦОНа до доставки и времени (час-пик)"
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сумма"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setAttributedTitle(NSAttributedString(string: "Оплатить")
            .textStyle(size: 20, color: .white), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    init(order: ResponseOrder, networkingService: NetworkingLogic, userName: UserName) {
        self.order = order
        self.networkingService = networkingService
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
        
        self.priceLabel.text = "\(order.price) KZT"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        addSubviews()
        setupConstraints()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "Оплата"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(priceTitleLabel)
        view.addSubview(priceLabel)
        view.addSubview(totalLabel)
        view.addSubview(warningLabel)
        view.addSubview(nextButton)
        view.addSubview(spinner)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                tableView.bottomAnchor.constraint(equalTo: ),
                tableView.heightAnchor.constraint(equalToConstant: 76 * 2),
                
                priceTitleLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
                priceTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                priceTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//                priceTitleLabel.heightAnchor.constraint(equalToConstant: 40),
                
                warningLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 20),
                warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                totalLabel.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 20),
                totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                priceLabel.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 20),
                priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                nextButton.heightAnchor.constraint(equalToConstant: 40),
                
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
                spinner.widthAnchor.constraint(equalToConstant: 300),
                spinner.heightAnchor.constraint(equalToConstant: 300)
            ]
        )
    }
    
    // MARK: - Button Actions
    
    @objc
    private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func nextButtonPressed() {
        spinner.startAnimating()
        networkingService.buyDelivery(id: order.orderId) { [weak self] result in
            switch result {
            case .success:
                self?.authAlert(title: "Заказ успешно оформлен", action: "Ok")
            case .failure:
                self?.authAlert(title: "Что-то пошло не так")
            }
            self?.spinner.stopAnimating()
        }
    }
    
    // MARK: - Alert
    
    private func authAlert(title: String = "Неверный ИИН", action: String = "Попробуйте снова") {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: action, style: UIAlertAction.Style.default)
        { [weak self] _ in
            guard let self = self else { return }
            if action == "Ok" {
                self.navigationController?.pushViewController(CourierVC(networkingService: self.networkingService, userName: userName), animated: true)
            } 
        })
        self.present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PaymentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InformationCell.className, for: indexPath) as? InformationCell
        else {
            return UITableViewCell()
        }
    
        cell.configure(with: informationModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 1 else { return }
        
        if informationModels[1].text == "Jusan" {
            informationModels[1] = InformationModel(text: "Cash",
                                                    details: "Оплата при получении\nНажмите чтобы поменять",
                                                    image: "tengesign.circle")
        } else {
            informationModels[1] =  InformationModel(text: "Jusan",
                                                     details: "Списывается с выбранных карт\nНажмите чтобы поменять",
                                                     image: "creditcard.circle")
        }
        
        tableView.reloadData()
    }
}
