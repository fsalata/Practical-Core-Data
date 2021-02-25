//
//  TaskCompletion.swift
//  StorageProvider
//
//  Created by Donny Wals on 06/12/2020.
//

import Foundation
import CoreData



public extension StorageProvider {
  func addTaskCompletion(for task: HouseHoldTask) {
    let context = task.managedObjectContext ?? persistentContainer.newBackgroundContext()
    context.perform {
      let completion = TaskCompletion(context: context)
      completion.task = task
      completion.completedOn = Date()
      
      do {
        try context.save()
      } catch {
        print("Adding completion failed: \(error)")
        context.rollback()
      }
    }
  }
}
