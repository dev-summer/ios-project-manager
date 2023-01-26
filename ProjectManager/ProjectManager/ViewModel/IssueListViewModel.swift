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
        case showPopOver(index: IndexPath?)
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
        case let .showPopOver(index):
            statusHandler?(status, index)
        case let .move(issue, to):
            issues = issues.filter { $0.id != issue.id }
            var modifiedIssue = issue
            modifiedIssue.status = to
            issueDeliveryHandler?(modifiedIssue)
        case let .add(issue):
            self.issues.append(issue)
        case let .update(issue):
            issues = issues.map {
                guard $0.id != issue.id else { return issue }
                return $0
            }
            // 아래 코드가 속도는 더 빠를 수도 있음
//            guard let index = issues.firstIndex(where: {$0.id == issue.id}) else { return }
//            issues[index] = issue
        case let .delete(issue):
            issues = issues.filter { $0.id != issue.id }
            deleteHandler?(issue)
        }
    }
    
    func configureInitialStatus() {
        issues = []
    }
}

// 지우는 동작 0
// listVC에서 -> listVM에게 지워달라고 함 0
// 지운걸 보여준다 0
// listVM -> listVC에게 보여줌 (bindIssues) 0

// 다른 listVC에게 보여줘야 한다

// listVC -> mainVC에게 우선 전달한다
// mainVC -> 받을 listVC에게 전달한다
// 받는 listVC는 -> 받는 listVM 에게 전달해서 추가(하라는 액션 호출)
// listVM이 보여주면 끝
