//
//  HouseHoldTask.swift
//  StorageProvider
//
//  Created by Donny Wals on 06/12/2020.
//

import Foundation
import CoreData

public extension HouseHoldTask {
  static var sortedByNextDueDate: NSFetchRequest<HouseHoldTask> {
    let request: NSFetchRequest<HouseHoldTask> = HouseHoldTask.fetchRequest()
    request.predicate = versionPredicate
    request.sortDescriptors = [NSSortDescriptor(keyPath: \HouseHoldTask.nextDueDate, ascending: true)]
    return request
  }

  static var overDueTasks: NSFetchRequest<HouseHoldTask> {
    let request: NSFetchRequest<HouseHoldTask> = HouseHoldTask.fetchRequest()
    let overDuePredicate = NSPredicate(format: "%K < %@",
                                       #keyPath(HouseHoldTask.nextDueDate),
                                       Date() as NSDate)

    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [overDuePredicate, versionPredicate])
    request.sortDescriptors = [NSSortDescriptor(keyPath: \HouseHoldTask.nextDueDate, ascending: true)]
    return request
  }

  @NSManaged var notes: [Notes]
}

extension HouseHoldTask {
  enum ValidationError: Error {
    case invalidName(String)
  }

  public override func validateForInsert() throws {
    try super.validateForInsert()

    guard let name = name, !name.isEmpty else {
      throw ValidationError.invalidName("Name should be a non-empty string")
    }
  }

  public override func validateForUpdate() throws {
    try super.validateForUpdate()

    guard let name = name, !name.isEmpty else {
      throw ValidationError.invalidName("Name should be a non-empty string")
    }
  }
}

public extension HouseHoldTask {
  enum FrequencyType: Int, CaseIterable, CustomStringConvertible {
    case day = 0, week, month, year
    
    public var description: String {
      switch self {
      case .day: return "day"
      case .week: return "week"
      case .month: return "month"
      case .year: return "year"
      }
    }
  }
}

public extension StorageProvider {
  func addTask(name: String, description: String,
               nextDueDate: Date, frequency: Int,
               frequencyType: HouseHoldTask.FrequencyType) {
    let context = persistentContainer.viewContext

    context.perform {
      let task = HouseHoldTask(context: context)
      task.identifier = UUID()
      task.name = name
      task.taskDescription = description
      task.nextDueDate = nextDueDate
      task.frequency = Int64(frequency)
      task.frequencyType = Int64(frequencyType.rawValue)

      do {
        try context.save()
      } catch {
        print("Something went wrong: \(error)")
        context.rollback()
      }
    }
  }

  func updateNote(for task: HouseHoldTask, content: String) {
    let context = persistentContainer.viewContext
    context.perform {
      if task.notes.isEmpty {
        let notes = Notes(context: context)
        notes.taskIdentifier = task.identifier
        notes.contents = content
      } else if let notes = task.notes.first {
        notes.contents = content
      }

      do {
        try context.save()
        context.refresh(task, mergeChanges: true)
      } catch {
        print("Something went wrong: \(error)")
        context.rollback()
      }
    }
  }
}
