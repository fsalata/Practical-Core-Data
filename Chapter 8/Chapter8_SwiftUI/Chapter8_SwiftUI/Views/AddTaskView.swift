//
//  AddTaskView.swift
//  Chapter8_SwiftUI
//
//  Created by Donny Wals on 06/12/2020.
//

import Foundation
import SwiftUI
import StorageProvider

struct AddTaskView: View {
  @State var taskName = ""
  @State var taskDescription = ""
  @State var firstOccurrence = Date()
  @State var frequency = 0
  @State var frequencyType = HouseHoldTask.FrequencyType.day
  
  @Binding var isPresented: Bool
  
  let storageProvider: StorageProvider
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Name")) {
          TextField("Task name", text: $taskName)
        }
        
        Section(header: Text("Description")) {
          TextField("More information", text: $taskDescription)
        }
        
        Section(header: Text("Fequency")) {
          Text("This task should be done every:")
          Stepper("\(frequency)", value: $frequency, in: 1...99)
          Picker("", selection: $frequencyType) {
            ForEach(HouseHoldTask.FrequencyType.allCases, id: \.self) { intervalType in
              Text("\(intervalType.description)")
            }
          }.pickerStyle(SegmentedPickerStyle())
        }
        
        Section(header: Text("First task occurrence")) {
          DatePicker("First due date", selection: $firstOccurrence, displayedComponents: [.date])
        }
      }
      .navigationTitle("Add Task")
      .navigationBarItems(leading: Button("Cancel") {
        isPresented = false
      }, trailing: Button("Save") {
        storageProvider.addTask(name: taskName, description: taskDescription,
                                nextDueDate: firstOccurrence, frequency: frequency,
                                frequencyType: frequencyType)
        isPresented = false
      })
    }
  }
}
