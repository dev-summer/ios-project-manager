//
//  Issue.swift
//  ProjectManager
//
//  Created by summercat on 2023/01/12.
//

import Foundation

struct Issue: Hashable {
    let id: UUID
    var status: Status
    var title: String
    var body: String
    var deadline: Date
}
