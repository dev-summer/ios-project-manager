//
//  MainViewController.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/12.
//

import UIKit

final class MainViewController: UIViewController {
    private enum Constant {
        enum Layout {
            static let mainStackViewMargin = CGFloat(8)
            static let columnSpacing = CGFloat(16)
        }
        
        enum Namespace {
            static let navigationTitle = "Project Manager"
            static let plusImage = "plus"
        }
    }
        
    private let todoListViewController: IssueListViewController = {
        let viewModel = IssueListViewModel(status: .todo)
        let viewController = IssueListViewController(viewModel: viewModel)
        return viewController
    }()
    
    private let doingListViewController: IssueListViewController = {
        let viewModel = IssueListViewModel(status: .doing)
        let viewController = IssueListViewController(viewModel: viewModel)
        return viewController
    }()
    
    private let doneListViewController: IssueListViewController = {
        let viewModel = IssueListViewModel(status: .done)
        let viewController = IssueListViewController(viewModel: viewModel)
        return viewController
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constant.Layout.columnSpacing
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: Constant.Layout.mainStackViewMargin,
                                                                 leading: Constant.Layout.mainStackViewMargin,
                                                                 bottom: Constant.Layout.mainStackViewMargin,
                                                                 trailing: Constant.Layout.mainStackViewMargin)
        
        return stack
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureMainStackView()
        configureChildViewControllers()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        title = Constant.Namespace.navigationTitle
        let plusButton = UIBarButtonItem(image: UIImage(systemName: Constant.Namespace.plusImage),
                                         primaryAction: UIAction { _ in
            let issueViewModel: IssueViewModel = IssueViewModel(isEditable: true)
            let issueViewcontroller = IssueViewController(viewModel: issueViewModel)
            issueViewcontroller.delegate = self.todoListViewController
            let navigationViewController = UINavigationController(rootViewController: issueViewcontroller)
            self.present(navigationViewController, animated: true)
        })
        navigationItem.rightBarButtonItem = plusButton
    }
    
    private func configureMainStackView() {
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func configureChildViewControllers() {
        [todoListViewController, doingListViewController, doneListViewController].forEach {
            addChild($0)
            $0.deliveryHandler = deliver
            mainStackView.addArrangedSubview($0.view)
            $0.didMove(toParent: self)
        }
    }
    
    func deliver(issue: Issue, to status: Status) {
        switch issue.status {
        case .todo:
            todoListViewController.shouldAdd(issue: issue)
        case .doing:
            doingListViewController.shouldAdd(issue: issue)
        case .done:
            doneListViewController.shouldAdd(issue: issue)
        }
    }
}
