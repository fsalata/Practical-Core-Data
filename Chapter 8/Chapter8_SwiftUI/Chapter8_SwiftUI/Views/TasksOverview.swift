//
//  TasksOverview.swift
//  Chapter8_SwiftUI
//
//  Created by Donny Wals on 06/12/2020.
//

import Foundation
import SwiftUI
import StorageProvider
import Combine

struct TasksOverview: View {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }()
  
  @FetchRequest(fetchRequest: HouseHoldTask.sortedByNextDueDate)
  var tasks: FetchedResults<HouseHoldTask>
  
  @State var addTaskPresented = false
  
  let storageProvider: StorageProvider
  
  var body: some View {
    NavigationView {
      List(tasks) { (task: HouseHoldTask) in
        NavigationLink(destination: TaskDetailView(task: task, storageProvider: storageProvider)) {
          VStack(alignment: .leading) {
            Text(task.name ?? "--")
            if let dueDate = task.nextDueDate {
              Text("\(dueDate, formatter: Self.dateFormatter)")
            }
          }
        }
      }
      .listStyle(PlainListStyle())
      .navigationBarItems(trailing: Button("Add new") {
        addTaskPresented = true
      })
      .navigationBarTitle("Tasks")
      .sheet(isPresented: $addTaskPresented, content: {
        AddTaskView(isPresented: $addTaskPresented, storageProvider: storageProvider)
      })
    }
  }
}
