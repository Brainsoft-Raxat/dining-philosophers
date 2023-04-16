//
//  InformationCell.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 31.03.2023.
//

import UIKit

// - MARK: - protocol ConfigurableViewProtocol
protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    
    func configure(with model: ConfigurationModel)
}

final class InformationCell: UITableViewCell {
    
    // - MARK: - Constants
    private struct Constants {
        static let verticalPadding: CGFloat = 17
        static let horizontalPadding: CGFloat = 16
        
        static let avatarHorizontalPadding: CGFloat = 15.5
        static let avatarVerticalPadding: CGFloat = 12
        static let avatarImageHeight: CGFloat = 45
        static let avatarImageWidth: CGFloat = 45
        static let avatarImageDefault = UIImage(systemName: "person.crop.circle.fill")
        static let avatarImagePlaceholder = UIImage(systemName: "photo.circle.fill")
        
        static let nameLabelFontSize: CGFloat = 17
        static let messageFontSize: CGFloat = 15
        static let nameLabelTrailingDistance: CGFloat = 4
        
        static let disclosureIndicatorImageName: String = "chevron.right"
        static let disclosureIndicatorHeight: CGFloat = 11
        static let disclosureIndicatorWidth: CGFloat = 6.42
        static let disclosureIndicatorBottomPadding: CGFloat = 5.5
        
        static let onlineIndicatorWidthHeight: CGFloat = 16
        static let onlineIndicatorY: CGFloat = -1.3
        static let onlineIndicatorX: CGFloat = 31
        
        static let messageHorizontalPadding: CGFloat = 14
        static let messageVerticalPadding: CGFloat = 1
        
        static let separatorLineHeight: CGFloat = 0.5
    }
    
    // MARK: - UI
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Constants.nameLabelFontSize)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Constants.messageFontSize)
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var disclosureIndicatorImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Constants.disclosureIndicatorImageName)
        imageView.tintColor = .black
        
        return imageView
    }()
    
    private lazy var userAvatarImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.avatarImageWidth / 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
//        imageView.tintColor = .lightGray
        
        return imageView
    }()
    
    private lazy var separatorLine: UIView = {
        let separatorLine = UIView()
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        return separatorLine
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userAvatarImage.image = nil
        [nameLabel, messageLabel, priceLabel, disclosureIndicatorImage, userAvatarImage, separatorLine].forEach({
            $0.removeFromSuperview()
        })
    }
    
    // MARK: - Adding Subviews
    
    private func addSubviews() {
        [nameLabel, messageLabel, priceLabel, disclosureIndicatorImage, userAvatarImage, separatorLine].forEach({
            contentView.addSubview($0)
        })
    }
    
    // MARK: - Setting Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                userAvatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
                userAvatarImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.avatarHorizontalPadding),
                userAvatarImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.avatarHorizontalPadding),
                userAvatarImage.heightAnchor.constraint(equalToConstant: Constants.avatarImageHeight),
                userAvatarImage.widthAnchor.constraint(equalToConstant: Constants.avatarImageWidth),
                
                messageLabel.leadingAnchor.constraint(equalTo: userAvatarImage.trailingAnchor, constant: Constants.avatarVerticalPadding),
                messageLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
                messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
                
                disclosureIndicatorImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
                disclosureIndicatorImage.heightAnchor.constraint(equalToConstant: Constants.disclosureIndicatorHeight),
                disclosureIndicatorImage.widthAnchor.constraint(equalToConstant: Constants.disclosureIndicatorWidth),
                disclosureIndicatorImage.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -Constants.disclosureIndicatorBottomPadding),
                
                nameLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.verticalPadding),
                nameLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: userAvatarImage.trailingAnchor, constant: Constants.avatarVerticalPadding),
                nameLabel.trailingAnchor.constraint(equalTo: disclosureIndicatorImage.leadingAnchor, constant: -Constants.nameLabelTrailingDistance),
                
                separatorLine.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: Constants.separatorLineHeight),
                separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                 
                priceLabel.trailingAnchor.constraint(equalTo: disclosureIndicatorImage.leadingAnchor, constant: -Constants.messageHorizontalPadding),
                priceLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -Constants.messageVerticalPadding),
            ]
        )
    }
    
    // - MARK: - Setup Colors
    
    private func setupColors() {
        contentView.backgroundColor = .white
        nameLabel.textColor = .black
        messageLabel.textColor = .gray
        separatorLine.backgroundColor = .gray
        disclosureIndicatorImage.tintColor = .black
    }
}

// MARK: - ConfigurableViewProtocol

extension InformationCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = InformationModel
    
    func configure(with model: ConfigurationModel) {
        nameLabel.text = model.text
        messageLabel.text = model.details
        if model.details.isEmpty {
            messageLabel.text = "Не указана"
        }
        userAvatarImage.image = UIImage(systemName: model.image)
        if model.image == "mappin.and.ellipse" || model.text == "Jusan" {
            userAvatarImage.layer.cornerRadius = 0
            disclosureIndicatorImage.isHidden = true
        }
        if let price = model.price {
            if price == -1 {
                disclosureIndicatorImage.isHidden = true
            } else {
                priceLabel.text = "\(price) KZT"
            }
        }
        
        setupColors()
        addSubviews()
        setupConstraints()
    }
}
