//
//  IssueListViewModel.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/25.
//

import Foundation

final class IssueListViewModel {
    enum Action {
        case onAppear
        case longPress(index: IndexPath?)
        case move(issue: Issue, to: Status)
        case add(issue: Issue)
        case update(issue: Issue)
        case delete(issue: Issue)
    }
    
    let status: Status
    private var issues: [Issue] = [] {
        didSet {
            issuesHandler?(issues)
        }
    }
    
    private var statusHandler: ((Status, IndexPath?) -> Void)?
    private var issuesHandler: (([Issue]) -> Void)?
    private var issueDeliveryHandler: ((Issue) -> Void)?
    private var deleteHandler: ((Issue) -> Void)?
    
    init(status: Status) {
        self.status = status
    }
    
    func bindStatus(closure: @escaping ((Status, IndexPath?) -> Void)) {
        self.statusHandler = closure
    }
    
    func bindIssues(closure: @escaping (([Issue]) -> Void)) {
        self.issuesHandler = closure
    }
    
    func bindIssueDeliveryHandler(closure: @escaping ((Issue) -> Void)) {
        self.issueDeliveryHandler = closure
    }
    
    func bindDeleteHandler(closure: @escaping ((Issue) -> Void)) {
        self.deleteHandler = closure
    }
    
    func action(action: IssueListViewModel.Action) {
        switch action {
        case .onAppear:
            break
        case let .longPress(index):
            statusHandler?(status, index)
        case let .move(issue, to):
            issues = issues.filter { $0.id != issue.id }
            var modifiedIssue = issue
            modifiedIssue.status = to
            issueDeliveryHandler?(modifiedIssue)
        case let .add(issue):
            self.issues.append(issue)
        case let .update(issue):
            guard let index = issues.firstIndex(where: {$0.id == issue.id}) else { return }
            issues[index] = issue
        case let .delete(issue):
            issues = issues.filter { $0.id != issue.id }
            deleteHandler?(issue)
        }
    }
    
    func configureInitialStatus() {
        issues = []
    }
}
