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
    
    // +를 누르면 -> 버튼 눌렸다! 하고 MainVC에서 알려줌
    // issueId가 nil로 초기화
    
    // 기존의 셀을 누르면 -> 셀 데이터를 알려조야함
    // 셀 데이터는 Issue인데, 꼭 그 전체를 알아야 하나? 만약 id만 알려준다면?
    // id를 기준으로 issues 배열에서 issue를 찾아온다.

    weak var vcDelegate: IssueViewModelDelegate?
    private var issue: Issue?
    private let isExistingIssue: Bool
    private var isEditable: Bool
    
    // 이니셜라이저가 너무 길다...
    // 분기처리를 하기 위해 다 변수로 만들어주고, 그걸 init할 때 받도록 했기 때문...
    init(issue: Issue? = nil, isExistingIssue: Bool, isEditable: Bool) {
        self.issue = issue
        self.isExistingIssue = isExistingIssue
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
