//
//  IssueListViewController.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/17.
//

import UIKit

final class IssueListViewController: UIViewController {
    private enum Constant {
        enum Layout {
            static let spacing = CGFloat(8)
            static let margin = CGFloat(12)
        }
        
        enum Namespace {
            static let delete = "Delete"
            static let minimumPressDuration = 0.5
            static let alertActionText = "Move to "
        }
        
        enum Section {
            case main
        }
    }
    
    private var viewModel: IssueListViewModel
    var deliveryHandler: ((Issue, Status) -> Void)?
    private var dataSource: UICollectionViewDiffableDataSource<Constant.Section, Issue>?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constant.Layout.spacing
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
    
    private let headerView = HeaderView()
    private var collectionView: UICollectionView?
    
    init(frame: CGRect = .zero, viewModel: IssueListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        setLongPressGestureRecognizer()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.configureInitialStatus()
    }
    
    private func configureUI() {
        configureCollectionView()
        configureStackView()
    }
    
    private func configureStackView() {
        guard let collectionView = collectionView else { return }
        
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(collectionView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    private func configureCollectionView() {
        let listLayout = configureListLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView?.delegate = self
    }
    
    private func configureListLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.separatorConfiguration.topSeparatorVisibility = .hidden
        listConfiguration.separatorConfiguration.bottomSeparatorVisibility = .hidden
        listConfiguration.trailingSwipeActionsConfigurationProvider = { indexPath in
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: Constant.Namespace.delete
            ) { _, _, _  in
                guard let issue = self.dataSource?.itemIdentifier(for: indexPath) else { return }
                self.viewModel.action(action: .delete(issue: issue))
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }
        
        let cellRegistration = UICollectionView.CellRegistration<CustomListCell, Issue> { (cell, indexPath, item) in
            cell.item = item
        }
        
        dataSource = UICollectionViewDiffableDataSource<Constant.Section, Issue>(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
            return cell
        }
    }
    
    private func bind() {
        viewModel.showPopover { [weak self] (status, indexPath) in
            let options = Status.allCases.filter { $0 != status }
            self?.showPopover(with: options, at: indexPath)
        }
        
        viewModel.bindIssues { [weak self] issues in
            guard let self = self else { return }
            self.applySnapshot(issues: issues)
            self.headerView.configureContent(
                title: String(describing: self.viewModel.status),
                count: issues.count
            )
        }
        
        viewModel.bindIssueDeliveryHandler { [weak self] issue in
            self?.deliveryHandler?(issue, issue.status)
        }
        
        viewModel.deleteIssue { [weak self] issue in
            self?.deleteIssue(issue: issue)
        }
    }
    
    private func applySnapshot(issues: [Issue]) {
        var snapshot = NSDiffableDataSourceSnapshot<Constant.Section, Issue>()
        snapshot.appendSections([.main])
        snapshot.appendItems(issues, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func deleteIssue(issue: Issue) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.deleteItems([issue])
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setLongPressGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(gestureRecognizer: ))
        )
        gestureRecognizer.minimumPressDuration = Constant.Namespace.minimumPressDuration
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state != .recognized else { return }
        
        let point = gestureRecognizer.location(in: collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: point)
        
        viewModel.action(action: .longPress(index: indexPath))
    }
    
    private func showPopover(with options: [Status], at indexPath: IndexPath?) {
        guard let indexPath = indexPath,
              let selectedCell = collectionView?.cellForItem(at: indexPath) as? CustomListCell,
              let issue = selectedCell.item else { return }
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        options.map { createAlertAction(issue: issue, to: $0) }
            .forEach { alertController.addAction($0) }
        alertController.popoverPresentationController?.sourceView = collectionView
        alertController.popoverPresentationController?.sourceRect = selectedCell.frame
        alertController.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        
        present(alertController, animated: true)
    }
    
    private func createAlertAction(issue: Issue, to status: Status) -> UIAlertAction {
        let action = UIAlertAction(
            title: Constant.Namespace.alertActionText + String(describing: status),
            style: .default
        ) { _ in
            self.viewModel.action(action: .move(issue: issue, to: status))
        }
        return action
    }
}

extension IssueListViewController: IssueDelegate {
    func shouldAdd(issue: Issue) {
        viewModel.action(action: .add(issue: issue))
    }
    
    func shouldUpdate(issue: Issue) {
        viewModel.action(action: .update(issue: issue))
    }
}

extension IssueListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let issue = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        let issueViewModel: IssueViewModel = IssueViewModel(issue: issue, isEditable: false)
        let issueViewcontroller = IssueViewController(viewModel: issueViewModel)
        issueViewcontroller.delegate = self
        let navigationViewController = UINavigationController(rootViewController: issueViewcontroller)
        self.present(navigationViewController, animated: true)
    }
}
