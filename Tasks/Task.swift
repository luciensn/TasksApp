//
//  Task.swift
//  Tasks
//

import Foundation
import os.log

class Task: NSObject, NSCoding {
    
    
    // MARK: Properties
    
    var text:String
    
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks")
    
    
    // MARK: Types
    
    struct PropertyKey {
        static let text = "text"
    }
    
    
    init?(text:String) {
        self.text = text
    }
    
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: PropertyKey.text)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // Text required
        guard let text = aDecoder.decodeObject(forKey: PropertyKey.text) as? String else {
            os_log("Unable to decode the text for a Task object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(text: text)
    }
    
    
    // MARK: Sample Tasks

    static func sampleTasks() -> [Task] {
        
        guard let task1 = Task(text: "Welcome to Tasks!") else {
            fatalError("Unable to instantiate task1")
        }
        
        guard let task2 = Task(text: "Pull down to create new") else {
            fatalError("Unable to instantiate task2")
        }
        
        guard let task3 = Task(text: "Double tap to edit") else {
            fatalError("Unable to instantiate task3")
        }
        
        guard let task4 = Task(text: "Tap and hold to rearrange") else {
            fatalError("Unable to instantiate task4")
        }
        
        guard let task5 = Task(text: "Swipe left to delete") else {
            fatalError("Unable to instantiate task5")
        }
        
        return [task1, task2, task3, task4, task5]
    }
    
}
