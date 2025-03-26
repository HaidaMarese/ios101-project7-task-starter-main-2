//
//  Task.swift
//

import UIKit

import Foundation

// The Task model
struct Task: Codable {

    // An id (Universal Unique Identifier) used to identify a task.
    var id: String = UUID().uuidString
    
    
    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    
    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(id: String = UUID().uuidString, title: String, note: String? = nil, dueDate: Date = Date()) {
        
        self.title = title
        self.note = note
        self.dueDate = dueDate
        self.id = id
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    let createdDate: Date = Date()

    
    mutating func toggleCompletion() {
            self.isComplete.toggle()
            self.save()
        }
}

// MARK: - Task + UserDefaults
extension Task {
    private static let tasksKey = "savedTasks"

    static func save(_ tasks: [Task]) {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: tasksKey)
        }
    }

    static func getTasks() -> [Task] {
        guard let savedData = UserDefaults.standard.data(forKey: tasksKey),
              let savedTasks = try? JSONDecoder().decode([Task].self, from: savedData) else {
            return []
        }
        return savedTasks.sorted { $0.dueDate < $1.dueDate }
    }


    func save() {
        var allTasks = Task.getTasks()
        print("Before Saving:", allTasks.map { "\($0.id) - \($0.isComplete)" })

        if let index = allTasks.firstIndex(where: { $0.id == self.id }) {
            allTasks[index] = self
        } else {
            allTasks.append(self)
        }

        print("After Saving:", allTasks.map { "\($0.id) - \($0.isComplete)" })
        Task.save(allTasks)
    }

}
