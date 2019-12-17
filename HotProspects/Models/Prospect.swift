//
//  Prospect.swift
//  HotProspects
//
//  Created by Levit Kanner on 14/12/2019.
//  Copyright © 2019 Levit Kanner. All rights reserved.
//

import Foundation
import Combine

class Prospect: Codable , Identifiable{
    let id = UUID()
    var name = "Anonymous"
    var email = ""
    fileprivate(set) var isContacted = false
    
}

class Prospects: ObservableObject{
    //Properties
    @Published private(set) var prospects: [Prospect]
    static let saveKey = "savedContacts"
    
    
    //Initialization
    init(){
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = path.appendingPathComponent(Self.saveKey)
        if let data = try?  Data(contentsOf: url){
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data){
                self.prospects = decoded
                return
            }
        }
        self.prospects = []
    }
    
    
    
    //Methods
    private func save(){
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Self.saveKey)
        if let data = try? JSONEncoder().encode(prospects){
            try? data.write(to: url)
        }
        
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect){
        self.prospects.append(prospect)
        self.save()
    }
    
    
    
    
    
    
    func saveToDirectory(){
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Self.saveKey)
        if let data = try? JSONEncoder().encode(prospects){
            try? data.write(to: url)
        }
    }
    

    func getFileDirectory()-> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func loadFromDirectory(){
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = path.appendingPathComponent(Self.saveKey)
        if let data = try?  Data(contentsOf: url){
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data){
                self.prospects = decoded
                return
            }
        }
        self.prospects = []
    }
}
