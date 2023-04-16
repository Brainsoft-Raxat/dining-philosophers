//
//  InformationInsertVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import UIKit

protocol InformationGetterProtocol: AnyObject {
    func getAddress(_ address: String)
    func getMessageForCourier(_ message: String)
    func getDeliveryService(_ message: String)
}


final class InformationInsertVC: UIViewController {
    
    // MARK: - Data((((
    
    private lazy var deliveryServices: [String] = ["DHL", "Pony Express", "Exline", "CDEK", "Garant Post Service", "Алем-Тат"]
    
    private var placeholderText: String = ""
    
    weak var delegate: InformationGetterProtocol?
    
    // MARK: - UI
    
    private lazy var downIndicator: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.compact.down")
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 173, green: 216, blue: 230, alpha: 0)
        button.setAttributedTitle(NSAttributedString(string: "Готово")
            .textStyle(size: 18, color: .systemBlue), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.textContainerInset.left = 33
        textView.textContainerInset.right = 33
        
        return textView
    }()
    
    private lazy var textViewImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        
        return pickerView
    }()

    
    // MARK: - Lifecycle
    
    init(title: String, placeholder: String = "Инструкции для курьера") {
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        
        switch title {
        case "Выбрать адрес доставки":
            textViewImage.image = UIImage(systemName: "house.circle.fill")
            textView.attributedText = NSAttributedString(string: "Страна, город, адрес")
                .textStyle(size: 17, color: UIColor.lightGray)
            placeholderText = "Страна, город, адрес"
        case "Выбрать курьерскую службу":
            textViewImage.image = UIImage(systemName: "shippingbox")
            textView.isHidden = true
            pickerView.isHidden = false
        default:
            textViewImage.image = UIImage(systemName: "text.bubble")
            textView.attributedText = NSAttributedString(string: placeholder)
                .textStyle(size: 17, color: UIColor.lightGray)
            placeholderText = placeholder
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
    }
    
    // MARK: - Adding Subviews
    
    private func addSubviews() {
        view.addSubview(downIndicator)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        view.addSubview(textView)
        view.addSubview(textViewImage)
        view.addSubview(pickerView)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                downIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                downIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                downIndicator.widthAnchor.constraint(equalToConstant: 40),
                downIndicator.heightAnchor.constraint(equalToConstant: 25),
                
                doneButton.topAnchor.constraint(equalTo: downIndicator.bottomAnchor, constant: 0),
                doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                doneButton.heightAnchor.constraint(equalToConstant: 40),
                
                titleLabel.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: -10),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4),
                titleLabel.heightAnchor.constraint(equalToConstant: 100),
                
                textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 170),
                textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                textView.heightAnchor.constraint(equalToConstant: 40),
                
                textViewImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                textViewImage.widthAnchor.constraint(equalToConstant: 29),
                textViewImage.heightAnchor.constraint(equalToConstant: 22),
                textViewImage.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
                
                pickerView.topAnchor.constraint(equalTo: textViewImage.bottomAnchor, constant: -85),
                pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            ]
        )
    }
    
    // MARK: - Button Actions
    
    @objc
    private func doneButtonPressed() {
        dismiss(animated: true)
        
        switch titleLabel.text {
        case "Выбрать адрес доставки":
            delegate?.getAddress(textView.text)
        case "Выбрать курьерскую службу":
            delegate?.getDeliveryService(deliveryServices[pickerView.selectedRow(inComponent: 0)])
        default:
            delegate?.getMessageForCourier(textView.text)
        }
    }
}


// MARK: - UITextViewDelegate

extension InformationInsertVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newHeight = newSize.height
        
        if newHeight > view.frame.height / 3 {
            newHeight = view.frame.height / 3
        }

        NSLayoutConstraint.deactivate(textView.constraintsAffectingLayout(for: .vertical))
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 170).isActive = true
        textView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
    }
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension InformationInsertVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return deliveryServices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return deliveryServices[row]
    }
    
}
