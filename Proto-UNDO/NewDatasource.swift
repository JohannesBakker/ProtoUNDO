//
//  NewDatasource.swift
//  Proto-UNDO
//
//  Created by Yury on 20/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import Foundation

//////////////////////////////////////////////
protocol CSVExport
{
    func toCSVFieldArray() ->[String]
}
//////////////////////////////////////////////

class Section {
    var name: String = ""
    var type: String {
        get {
            return name.lowercaseString
        }
    }
    var items: [EventItem] = []
    init(name: String) {
        self.name = name
    }
}

class Action : CSVExport {
    var actionID: String
    var name: String
    init(actionID: String, name: String) {
        self.actionID = actionID
        self.name = name
    }
    
    func toCSVFieldArray() ->[String]
    {
        let csvArray = [actionID, name]
        return csvArray
    }
}

class EventItem: CSVExport {
    let type: String
    var name: String
    var actions: [Action] = []
    var selectedActionIndex: Int? = nil
    
    init(type: String, name: String, actions: [Action]) {
        self.type = type
        self.name = name
        self.actions = actions
    }
    
    convenience init(type: String, name: String, actions: [[String]]) {
        let a = actions.map{ Action(actionID: $0[0], name: $0[1]) }
        self.init(type: type, name: name, actions: a)
    }
    
    func toCSVFieldArray() ->[String]
    {
        var csvArray = [type, name, actions.count.description]
        
        for action in actions
        {
            csvArray.appendContentsOf(action.toCSVFieldArray())
        }
        
        return csvArray
        
    }
}

class SliderEventItem : EventItem {
    var buttonText: String
    var infoText: String
    init(type: String, name: String, buttonText: String, infoText: String, actions: [Action]) {
        self.buttonText = buttonText
        self.infoText = infoText
        super.init(type: type, name: name, actions: actions)
    }
    
    convenience init(type: String, name: String, buttonText: String, infoText: String, actions: [[String]]) {
        let a = actions.map{ Action(actionID: $0[0], name: $0[1]) }
        self.init(type: type, name: name, buttonText: buttonText, infoText: infoText, actions: a)
    }
    
    override func toCSVFieldArray() -> [String] {
        var csvArray = super.toCSVFieldArray()
        csvArray.appendContentsOf([buttonText, infoText])
        return csvArray
    }
}


class NewDatasource {
    static let sections: [Section] = NewDatasource.getDatasource()
    static var items: [EventItem] {
        get {
            return sections.flatMap{$0.items}
        }
    }
    static var activeSections: [Section] {
        get {
            return sections.filter{
                let ovalue = NSUserDefaults.standardUserDefaults().objectForKey("NoEvent_\($0.type)") as? NSNumber
                return ovalue?.boolValue ?? true
            }
        }
    }
    class func setCustomNames() {
        let actions: [Action] = sections.flatMap{$0.items}.flatMap{$0.actions}
        for action in actions {
            action.name = LogEvent.customLabels[action.actionID] ?? action.name
        }
    }
    
    private class func getDatasource() -> [Section]{
        let breastLeft = EventItem(type: "breast", name: "Breast", actions: [["left", "Left"]])
        let breastRight = EventItem(type: "breast", name: "Breast", actions: [["right", "Right"]])
        let breastBoth = EventItem(type: "breast", name: "Breast", actions: [["both", "Both"]])
        let sectionBreast = Section(name: "Breast")
        sectionBreast.items = [breastLeft, breastRight, breastBoth]
        
        let bottle = SliderEventItem(type: "bottle", name: "Bottle", buttonText: "bottle", infoText: "%i oz", actions: [["bottle", ""]])
        let sectionBottle = Section(name: "Bottle")
        sectionBottle.items = [bottle]
        
        let pumpLeft = SliderEventItem(type: "pump", name: "Pump", buttonText: "pump", infoText: "%i oz", actions: [["left", "Left"]])
        let pumpRight = SliderEventItem(type: "pump", name: "Pump", buttonText: "pump", infoText: "%i oz", actions: [["right", "Right"]])
        let sectionPump = Section(name: "Pump")
        sectionPump.items = [pumpLeft, pumpRight]
        
        let sleep = EventItem(type: "sleep", name: "Sleep", actions: [["wokeup", "Woke Up"], ["asleep", "Fell Asleep"]])
        let sleepSection = Section(name: "Sleep")
        sleepSection.items = [sleep]

        let poop = EventItem(type: "poop", name: "Poop", actions: [["poop", "Poop"], ["diarrhea", "Diarrhea"]])
        let poopSection = Section(name: "Poop")
        poopSection.items = [poop]
        
        let pee = EventItem(type: "pee", name: "Pee", actions: [["pee", "Pee"]])
        let peeSection = Section(name: "Pee")
        peeSection.items = [pee]
        
        let medicine1 = EventItem(type: "medicine", name: "Medicine", actions: [["Medicine1", "Medicine_1"]])
        let medicine2 = EventItem(type: "medicine", name: "Medicine", actions: [["Medicine2", "Medicine_2"]])
        let medicine3 = EventItem(type: "medicine", name: "Medicine", actions: [["Medicine3", "Medicine_3"]])
        let medicineSection = Section(name: "Medicine")
        medicineSection.items = [medicine1, medicine2, medicine3]
        
        let memo = EventItem(type: "note", name: "Note", actions: [["note", "Note"]])
        let memoSection = Section(name: "Note")
        memoSection.items = [memo]

        return [sectionBreast, sectionBottle, sectionPump, sleepSection, poopSection, peeSection, medicineSection, memoSection]
    }
}