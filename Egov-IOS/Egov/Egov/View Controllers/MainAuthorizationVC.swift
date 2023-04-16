//
//  MainVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import UIKit

final class MainAuthorizationVC: UIViewController {
    
    // MARK: - Services without DI(((
    
    private lazy var networkingService = NetworkingService()
    
    // MARK: - UI
    
    private lazy var clipboardListImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "doc.text")
        
        return imageView
    }()
    
    private lazy var requestNumberLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "№ заявки 00000000"
//        label.backgroundColor = .systemBlue
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        label.layer.cornerRadius = 10
        
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Введите ИИН"
        label.font = UIFont.systemFont(ofSize: 20)
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.placeholder = "ИИН"
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 40))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setAttributedTitle(NSAttributedString(string: "Проверить")
            .textStyle(size: 20, color: .white), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(checkIIN), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()

    // MARK: - Lifecycle
    
    init(requestNumber: String) {
        super.init(nibName: nil, bundle: nil)
        
        if requestNumber.isEmpty {
            requestNumberLabel.isHidden = true
        }
        requestNumberLabel.text = "№ заявки " + requestNumber
        Singletion.entity.requestID = requestNumber
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
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Adding Subviews
    
    private func addSubviews() {
        view.addSubview(textField)
        view.addSubview(clipboardListImage)
        view.addSubview(requestNumberLabel)
        view.addSubview(nameLabel)
        view.addSubview(checkButton)
        view.addSubview(spinner)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                clipboardListImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
                clipboardListImage.heightAnchor.constraint(equalToConstant: 29),
                clipboardListImage.widthAnchor.constraint(equalToConstant: 30),
                clipboardListImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
                
                requestNumberLabel.leadingAnchor.constraint(equalTo: clipboardListImage.trailingAnchor, constant: 10),
                requestNumberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                requestNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
                requestNumberLabel.heightAnchor.constraint(equalToConstant: 40),
                
                textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                textField.heightAnchor.constraint(equalToConstant: 40),
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 65),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -65),
                
                checkButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
                checkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 65),
                checkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -65),
                checkButton.heightAnchor.constraint(equalToConstant: 40),
                
                nameLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -12),
                nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 65),
                nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -65),
                nameLabel.heightAnchor.constraint(equalToConstant: 33),
                
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
                spinner.widthAnchor.constraint(equalToConstant: 300),
                spinner.heightAnchor.constraint(equalToConstant: 300)
            ]
        )
    }

    // MARK: - Keyboard Setup
    
    private func hideKeyboardWhenTappedAround() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        viewTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(viewTap)
    }
    
    @objc func dismissKeyboard() {
        textField.endEditing(false)
    }
    
    // MARK: - Button Action
    
    @objc
    private func checkIIN() {
        guard let text = textField.text else {
            textField.placeholder = "Напишите ИИН"
            return
        }
        guard !text.isEmpty else {
            textField.placeholder = "Напишите ИИН"
            return
        }
        
        spinner.startAnimating()
        networkingService.isValidIIN(iin: text) { [weak self] result in
            switch result {
            case .success(let isExists):
                if isExists {
                    Singletion.entity.iin = text
                    self?.getUserName(iin: text)
                } else {
                    self?.authAlert()
                    self?.spinner.stopAnimating()
                }
            case .failure:
                self?.authAlert()
                self?.spinner.stopAnimating()
            }
        }
    }
    
    private func getUserName(iin: String) {
        networkingService.getUserName(iin: iin) { [weak self] nameResult in
            guard let self else { return }
            switch nameResult {
            case .success(let userName):
                Singletion.entity.phone = userName.phone
                let vc = (requestNumberLabel.isHidden ? CourierVC(networkingService: self.networkingService, userName: userName): DeliveryInformationVC(networkingService: self.networkingService,
                                               userName: userName))
                self.spinner.stopAnimating()
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure:
                self.authAlert(title: "Не удалось найти имя")
                self.spinner.stopAnimating()
            }
        }
    }
    
    // MARK: - Alert
    
    private func authAlert(title: String = "Неверный ИИН") {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Попробуйте снова", style: UIAlertAction.Style.default, handler: nil))
        
        present(alert, animated: true)
    }
}



