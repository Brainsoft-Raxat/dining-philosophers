//
//  DeliveryInformationVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import UIKit
import MapKit

final class DeliveryInformationVC: UIViewController {

    
    // MARK: - Data
    
    private lazy var informationModels = [InformationModel(text: "Выбрать курьерскую службу",
                                                           details: "Нажмите здесь, чтобы продолжить",
                                                           image: "shippingbox"),
                                          InformationModel(text: "Выбрать адрес доставки",
                                                           details: "Нажмите здесь, чтобы продолжить",
                                                           image: "location.circle.fill"),
                                          InformationModel(text: "Представитель",
                                                           details: "Нажмите здесь, чтобы продолжить",
                                                           image: "person.circle")]
    private let networkingService: NetworkingLogic
    private let userName: UserName
    
    // MARK: - UI
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.tintColor = .black
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        
        return button
    }()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        
        return map
    }()
    
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
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "Инструкции для курьера")
            .textStyle(size: 17, color: UIColor.gray)
        textField.textColor = .black
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        
        textField.leftViewMode = .always
        let containerImageView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        
        let imageView = UIImageView(frame: CGRect(x: 12, y: 14, width: 29, height: 22))
        imageView.image = UIImage(systemName: "text.bubble")
        containerImageView.addSubview(imageView)
        textField.leftView = containerImageView
    
        return textField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setAttributedTitle(NSAttributedString(string: "Далее")
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
        askWhoIsReceiver()
    }
    
    // MARK: - Setup View
    private func setupView() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Доставка документов"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        setupMapView()
    }
    
    // Kazakhstan, Astana, Qabanbai Batyr 53
    private func setupMapView(location: Location? = nil) {
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: 51.116744, longitude: 71.404191)
        mapView.addAnnotation(annotation1)
        
        if let location = location {
            let annotation2 = MKPointAnnotation()
            annotation2.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            annotation2.title = "Delivery Point"
            mapView.addAnnotation(annotation2)
        }
        
        let viewRegion = MKCoordinateRegion(center: annotation1.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        self.mapView.setRegion(viewRegion, animated: true)
        
        mapView.register(ShippingBoxAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Shipping Box")
        
        mapView.isUserInteractionEnabled = false
    }
    
    // MARK: - Adding Subviews
    
    private func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(tableView)
        view.addSubview(textField)
        view.addSubview(nextButton)
        view.addSubview(spinner)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1 / 5),
                
                tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.heightAnchor.constraint(equalToConstant: 76 * 3),
                
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textField.heightAnchor.constraint(equalToConstant: 40),
                textField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
                
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
        
        let request = RequestOrder(requestId: Singletion.entity.requestID, iin:  Singletion.entity.iin, branch: "", deliveryService: informationModels[0].text, firstName: userName.firstName.capitalized, lastName: userName.lastName.capitalized, middleName: userName.middleName.capitalized, address: informationModels[1].text, phone: Singletion.entity.phone, additionalData: textField.text ?? "", trustedFaceIin: informationModels[2].details)
        spinner.startAnimating()
        networkingService.createOrder(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let responce):
                self.navigationController?.pushViewController(PaymentVC(order: responce,
                                                                        networkingService: self.networkingService,
                                                                        userName: self.userName), animated: true)
            case .failure:
                self.authAlert(title: "Что-то пошло не так. Напишите всю информацию")
            }
            spinner.stopAnimating()
        }
        
    }
    
    private func askWhoIsReceiver() {
        let userName = "\(userName.lastName) \(userName.firstName) \(userName.middleName)".capitalized
        let receiverVC = ReceiverVC(name: userName)
        receiverVC.delegate = self
        
        if let sheet = receiverVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(receiverVC, animated: true)
    }
    
    // MARK: - Alert
    
    private func authAlert(title: String = "Неверный ИИН") {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Попробуйте снова", style: UIAlertAction.Style.default, handler: nil))
        
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension DeliveryInformationVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let id = "Shipping Box"
        
        if annotation.title == "Delivery Point" {
            return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKPinAnnotationView
        } else {
            return mapView.dequeueReusableAnnotationView(withIdentifier: id) as? ShippingBoxAnnotationView
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DeliveryInformationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
        var title: String
        
        switch indexPath.row {
        case 0:
            title = "Выбрать курьерскую службу"
        case 1:
            title = "Выбрать адрес доставки"
        default:
            askWhoIsReceiver()
            return
        }
        let infoInsertVC = InformationInsertVC(title: title)
        infoInsertVC.delegate = self

        if let sheet = infoInsertVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(infoInsertVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension DeliveryInformationVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.endEditing(true)
        
        let infoInsertVC = InformationInsertVC(title: "Добавить заметку для курьера")
        infoInsertVC.delegate = self
        
        if let sheet = infoInsertVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(infoInsertVC, animated: true)
    }
    
}

// MARK: - InformationGetterProtocol

extension DeliveryInformationVC: InformationGetterProtocol {
    func getAddress(_ address: String) {
        informationModels[1] = InformationModel(text: address,
                                                  details: "Адрес",
                                                  image: "location.circle.fill")
        
//        "Kazakhstan, Astana, Qabanbay Batyr 53"
        networkingService.getLocation(at: address) { [weak self] result in
            switch result {
            case .success(let location):
                self?.setupMapView(location: location)
            case .failure:
                self?.authAlert(title: "Не удалось найти адрес")
            }
        }
        
        tableView.reloadData()
    }
    
    func getMessageForCourier(_ message: String) {
        textField.text = message
    }
    
    func getDeliveryService(_ message: String) {
        informationModels[0] = InformationModel(text: message,
                                                  details: "Курьерская служба",
                                                  image: "shippingbox")
        tableView.reloadData()
    }
    
}

// MARK: - IINGetterProtocol

extension DeliveryInformationVC: IINGetterProtocol {
    func getIIN(_ iin: String?) {
        if let iin {
            informationModels[2] = InformationModel(text: "Представитель",
                                                    details: iin,
                                                   image: "person.circle")
        } else {
            informationModels[2] = InformationModel(text: "Представитель",
                                                    details: Singletion.entity.iin,
                                                   image: "person.circle")
        }
        tableView.reloadData()
    }
    
}
