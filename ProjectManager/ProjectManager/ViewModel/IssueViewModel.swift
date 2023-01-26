//
//  IssueViewModel.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/25.
//

import Foundation

protocol IssueViewModelDelegate: AnyObject {
    func configureContents(with issue: Issue?)
    func configureNewIssueNavigationBar()
    func configureExistingIssueNavigationBar(title: String)
    func configureEditablity(_ isEditable: Bool)
    func dismissModal()
    func deleteLastCharacter()
    func add(issue: Issue)
    func update(issue: Issue)
}

final class IssueViewModel {
    enum Action {
        case tapDoneButton(title: String, body: String, date: Date)
        case onAppear
        case tapEditButton
        case tapCancelButton
        case enterText(textCount: Int)
        case dismissModal
    }
    
    enum Constant {
        enum Namespace {
            static let maxBodyTextCount = 1000
        }
    }

    weak var vcDelegate: IssueViewModelDelegate?
    private var issue: Issue?
    private var isEditable: Bool

    init(issue: Issue? = nil, isEditable: Bool) {
        self.issue = issue
        self.isEditable = isEditable
    }
    
    func action(action: IssueViewModel.Action) {
        switch action {
        case let .tapDoneButton(title, body, date):
            addOrUpdate(title: title, body: body, date: date)
        case .onAppear:
            issue.flatMap { issue in
                self.vcDelegate?.configureContents(with: issue)
            }
            configureNavigationBar()
            vcDelegate?.configureEditablity(isEditable)
        case .tapEditButton:
            isEditable.toggle()
            vcDelegate?.configureEditablity(isEditable)
        case .tapCancelButton:
            vcDelegate?.dismissModal()
        case let .enterText(textCount):
            if textCount > Constant.Namespace.maxBodyTextCount { vcDelegate?.deleteLastCharacter() }
        case .dismissModal:
            vcDelegate?.dismissModal()
        }
    }

    private func addOrUpdate(title: String, body: String, date: Date) {
        if issue == nil {
            let newIssue = Issue(id: UUID(),
                          status: .todo,
                          title: title,
                          body: body,
                          deadline: date)
            vcDelegate?.add(issue: newIssue)
        } else {
            updateIssue(title: title, body: body, date: date)
            issue.flatMap { vcDelegate?.update(issue: $0) }
        }
    }
    
    private func updateIssue(title: String, body: String, date: Date) {
        issue?.title = title
        issue?.body = body
        issue?.deadline = date
    }
    
    private func configureNavigationBar() {
        if isEditable {
            vcDelegate?.configureNewIssueNavigationBar()
        } else {
            vcDelegate?.configureExistingIssueNavigationBar(title: String(describing: issue?.status ?? .todo))
        }
    }
}
