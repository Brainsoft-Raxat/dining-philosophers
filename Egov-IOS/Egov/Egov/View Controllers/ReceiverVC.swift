//
//  ReceiverVC.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import UIKit

protocol IINGetterProtocol: AnyObject {
    func getIIN(_ iin: String?)
}

final class ReceiverVC: UIViewController {
    
    weak var delegate: IINGetterProtocol?
    
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
        label.text = "Кто возьмет этот документ?"
        label.numberOfLines = 2
        
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
        textView.isHidden = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.textContainerInset.left = 33
        textView.textContainerInset.right = 33
        textView.attributedText = NSAttributedString(string: "ИИН представителя")
            .textStyle(size: 17, color: UIColor.lightGray)
        
        return textView
    }()
    
    private lazy var textViewImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "doc.text")
        imageView.isHidden = true
        
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 23)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var myselfButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Сам(-а)", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(myselfButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var addReceiverButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Ввести ИИН получателя", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(addReceiverPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.addArrangedSubview(myselfButton)
        stack.addArrangedSubview(addReceiverButton)
        stack.spacing = 2
        
        return stack
    }()
    
    // MARK: - Lifecycle
    
    init(name: String) {
        super.init(nibName: nil, bundle: nil)
        
        textLabel.text = "Добро пожаловать, \(name)!\nЕсли вы не сами принимаете документ, введите ИИН вашего представителя."
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
        view.addSubview(textLabel)
        view.addSubview(textViewImage)
        view.addSubview(stackView)
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
                
                textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
                textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                stackView.heightAnchor.constraint(equalToConstant: 40)
            ]
        )
    }
    
    // MARK: - Button Actions
    
    @objc
    private func doneButtonPressed() {
        delegate?.getIIN(textView.text)
        dismiss(animated: true)
    }
    
    @objc
    private func myselfButtonPressed() {
        delegate?.getIIN(nil)
        dismiss(animated: true)
    }
    
    @objc
    private func addReceiverPressed() {
        addReceiverButton.isHidden = true
        myselfButton.isHidden = true
        textView.isHidden = false
        textLabel.isHidden = true
        textViewImage.isHidden = false
    }
}


// MARK: - UITextViewDelegate

extension ReceiverVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "ИИН представителя"
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
