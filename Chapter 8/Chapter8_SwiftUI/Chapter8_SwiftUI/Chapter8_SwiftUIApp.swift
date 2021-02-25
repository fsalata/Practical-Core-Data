//
//  Chapter8_SwiftUIApp.swift
//  Chapter8_SwiftUI
//
//  Created by Donny Wals on 06/12/2020.
//

import SwiftUI
import StorageProvider

@main
struct Chapter8_SwiftUIApp: App {
  let storage = StorageProvider()
  
  var body: some Scene {
    WindowGroup {
      TasksOverview(storageProvider: storage)
        .environment(\.managedObjectContext, storage.persistentContainer.viewContext)
    }
  }
}
