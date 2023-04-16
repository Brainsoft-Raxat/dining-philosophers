//
//  ConfirmOrderVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import UIKit

final class ConfirmOrderVC: UIViewController {
    
    private var informationModels = [InformationModel(text: "Отдел выдачи",
                                                      details: "ЦОН ул. Керей, Жанибек хандар 4, Астана",
                                                      image: "mappin.and.ellipse"),
                                     InformationModel(text: "Jusan",
                                                      details: "Списывается с выбранных карт\nНажмите чтобы поменять",
                                                      image: "creditcard.circle")
    ]
    
    private let order: Order
    private let networkingService: NetworkingLogic
    
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
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "Напишите cвой номер телефона")
            .textStyle(size: 17, color: UIColor.gray)
        textField.textColor = .black
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        
        textField.leftViewMode = .always
        let containerImageView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        
        let imageView = UIImageView(frame: CGRect(x: 12, y: 9, width: 30, height: 30))
        imageView.image = UIImage(systemName: "phone.circle")
        containerImageView.addSubview(imageView)
        textField.leftView = containerImageView
        
        return textField
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setAttributedTitle(NSAttributedString(string: "Принять")
            .textStyle(size: 20, color: .white), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(order: Order, networkingService: NetworkingLogic) {
        self.order = order
        self.networkingService = networkingService
        
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
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "Информация о доставке"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(textField)
        view.addSubview(acceptButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.heightAnchor.constraint(equalToConstant: 76 * 6),
                
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textField.heightAnchor.constraint(equalToConstant: 40),
                textField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
                
                acceptButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                acceptButton.heightAnchor.constraint(equalToConstant: 40),
                acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            ]
        )
    }
    
    // MARK: - Button Actions
    
    @objc
    private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func acceptButtonPressed() {
        networkingService.takeOrder(id: order.id, phone: textField.text ?? Singletion.entity.phone, iin: Singletion.entity.iin) { [weak self] result in
            switch result {
            case .success:
                self?.authAlert(title: "Заказ успешно передан", action: "Ok")
            case .failure:
                self?.authAlert(title: "Что-то пошло не так")
            }
        }
    }
    
    // MARK: - Alert
    
    private func authAlert(title: String = "Неверный ИИН", action: String = "Попробуйте снова") {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: action, style: UIAlertAction.Style.default)
        { [weak self] _ in
            guard let self = self else { return }
            if action == "Ok" {
                self.navigationController?.popViewController(animated: true)
            }
        })
        self.present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension ConfirmOrderVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.endEditing(true)
        
        let infoInsertVC = InformationInsertVC(title: "Напишите номер телефона на который придет смс код",
                                               placeholder: "Номер телефона")
        infoInsertVC.delegate = self
        
        if let sheet = infoInsertVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(infoInsertVC, animated: true)
    }
    
}

// MARK: - InformationGetterProtocol

extension ConfirmOrderVC: InformationGetterProtocol {
    func getAddress(_ address: String) {}
    func getDeliveryService(_ message: String) {}
    
    func getMessageForCourier(_ message: String) {
        textField.text = message
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ConfirmOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InformationCell.className, for: indexPath) as? InformationCell
        else {
            return UITableViewCell()
        }
        
        var info: InformationModel
        switch indexPath.row {
        case 0:
            info = InformationModel(text: "№ заявки", details: order.requestId, image: "doc.circle.fill", price: -1)
        case 1:
            info = InformationModel(text: "ФИО получателя", details: "\(order.recipientName) \(order.recipientSurname)", image: "person.crop.circle", price: -1)
        case 2:
            info = InformationModel(text: "Государственная услуга", details: order.serviceName, image: "paperclip.circle", price: -1)
        case 3:
            info = InformationModel(text: "Отдел выдачи",
                                   details: "ЦОН ул. Керей, Жанибек хандар 4, Астана",
                                   image: "mappin.and.ellipse", price: -1)
        case 4:
            let address = "\(order.region), \(order.city), \(order.street) \(order.house)"
            info = InformationModel(text: "Адрес доставки:", details: address, image: "shippingbox", price: -1)
        default:
            info = InformationModel(text: "Сумма оплаты", details: "\(order.deliveryPrice)", image: "tengesign.circle", price: -1)
        }
        cell.configure(with: info)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
