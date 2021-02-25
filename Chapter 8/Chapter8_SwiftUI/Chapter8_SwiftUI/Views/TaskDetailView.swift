//
//  TaskDetailView.swift
//  Chapter8_SwiftUI
//
//  Created by Donny Wals on 06/12/2020.
//

import Foundation
import SwiftUI
import StorageProvider

struct TaskDetailView: View {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }()
  
  @ObservedObject var task: HouseHoldTask
  
  let storageProvider: StorageProvider
  
  var completions: Array<TaskCompletion> {
    guard let completions = task.completions as? Set<TaskCompletion> else {
      return []
    }
    
    return Array(completions).sorted { lhs, rhs in
      lhs.completedOn ?? Date() > rhs.completedOn ?? Date()
    }
  }
  
  var body: some View {
    VStack {
      Text(task.name ?? "Task")
      Text(task.notes.first?.contents ?? "no notes")
      List(completions) { completion in
        Text("\(completion.completedOn ?? Date(), formatter: Self.dateFormatter)")
      }
    }
    .navigationTitle("Task: \(task.name ?? "--")")
    .navigationBarItems(leading: Button("Update note"){
      self.storageProvider.updateNote(for: task, content: "Note version \(UUID().uuidString)")
    }, trailing: Button("Mark done") {
      self.storageProvider.addTaskCompletion(for: task)
    })
  }
}
