//
//  CustomContentView.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/13.
//

import UIKit

final class CustomContentView: UIView, UIContentView {
    private enum Constant {
        enum Layout {
            static let margin = CGFloat(8)
            static let borderWidth = CGFloat(1)
            static let cornerRadius = CGFloat(8)
            static let maxBodyLineCount = 3
        }
    }
    
    var configuration: UIContentConfiguration {
        didSet {
            configureContents(using: configuration)
        }
    }
    
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Constant.Layout.margin,
            leading: Constant.Layout.margin,
            bottom: Constant.Layout.margin,
            trailing: Constant.Layout.margin
        )
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemGray
        label.numberOfLines = Constant.Layout.maxBodyLineCount
        return label
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureViews()
        configureContents(using: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        layer.borderWidth = Constant.Layout.borderWidth
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = Constant.Layout.cornerRadius
        configureStackView()
    }
    
    private func configureStackView() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        [titleLabel, bodyLabel, dueDateLabel].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func configureContents(using configuration: UIContentConfiguration) {
        guard let configuration = configuration as? CustomContentConfiguration,
              let deadline = configuration.deadline else { return }
        
        titleLabel.text = configuration.title
        bodyLabel.text = configuration.body
        dueDateLabel.text = DateFormatterManager().formatDate(deadline)
        
        if configuration.status != .done,
           deadline.isOverdue {
            dueDateLabel.textColor = .systemRed
        } else if !deadline.isOverdue {
            dueDateLabel.textColor = .none
        }
    }
}
