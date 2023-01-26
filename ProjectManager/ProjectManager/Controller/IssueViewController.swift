//
//  IssueViewController.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/16.
//

import UIKit

final class IssueViewController: UIViewController {
    private enum Constant {
        enum Layout {
            static let stackViewSpacing = CGFloat(8)
            static let margin = CGFloat(20)
            static let titleTextFieldPadding = CGFloat(12)
            static let shadowRadius = CGFloat(4)
        }
        
        enum Namespace {
            static let maxBodyTextCount = 1000
            static let done = "Done"
            static let edit = "Edit"
            static let cancel = "Cancel"
            static let title = "Title"
        }
    }
    
    private var viewModel: IssueViewModel
    weak var delegate: IssueDelegate?
    
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constant.Layout.stackViewSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Constant.Layout.margin,
            leading: Constant.Layout.margin,
            bottom: Constant.Layout.margin,
            trailing: Constant.Layout.margin
        )
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private var titleTextField: PaddedTextField = {
        let padding = UIEdgeInsets(
            top: Constant.Layout.titleTextFieldPadding,
            left: Constant.Layout.titleTextFieldPadding,
            bottom: Constant.Layout.titleTextFieldPadding,
            right: Constant.Layout.titleTextFieldPadding
        )
        let textField = PaddedTextField(padding: padding)
        textField.backgroundColor = .systemBackground
        textField.placeholder = Constant.Namespace.title
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.addShadow(radius: Constant.Layout.shadowRadius)
        
        return textField
    }()
    
    private var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = .current
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    private var bodyTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemBackground
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.addShadow(radius: Constant.Layout.shadowRadius)
        
        return textView
    }()
    
    init(viewModel: IssueViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.delegate = self
        viewModel.action(action: .onAppear)
    }
    
    private func configureUI() {
        view.addSubview(stackView)
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureStackView()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Constant.Namespace.done,
            primaryAction: UIAction { _ in
                self.viewModel.action(action: .tapDoneButton(
                    title: self.titleTextField.text ?? String.init(),
                    body: self.bodyTextView.text,
                    date: self.datePicker.date
                ))
            })
    }
    
    private func configureStackView() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        [titleTextField, datePicker, bodyTextView].forEach(stackView.addArrangedSubview(_:))
    }
}

extension IssueViewController: IssueViewModelDelegate {
    func configureContents(with issue: Issue?) {
        titleTextField.text = issue?.title
        datePicker.date = issue?.deadline ?? Date()
        bodyTextView.text = issue?.body
    }
    
    func configureNewIssueNavigationBar() {
        title = String(describing: Status.todo)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Constant.Namespace.cancel,
            primaryAction: UIAction { _ in
                self.viewModel.action(action: .tapCancelButton)
            })
    }
    
    func configureExistingIssueNavigationBar(title: String) {
        self.title = title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Constant.Namespace.edit,
            primaryAction: UIAction { _ in
                self.viewModel.action(action: .tapEditButton)
            })
    }
    
    func configureEditablity(_ isEditable: Bool) {
        titleTextField.isEnabled = isEditable
        datePicker.isEnabled = isEditable
        bodyTextView.isEditable = isEditable
    }
    
    func dismissModal() {
        self.dismiss(animated: true)
    }
    
    func deleteLastCharacter() {
        bodyTextView.deleteBackward()
    }
    
    func add(issue: Issue) {
        delegate?.shouldAdd(issue: issue)
        viewModel.action(action: .dismissModal)
    }
    
    func update(issue: Issue) {
        delegate?.shouldUpdate(issue: issue)
        viewModel.action(action: .dismissModal)
    }
}

extension IssueViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.action(action: .enterText(textCount: textView.text.count))
    }
}
