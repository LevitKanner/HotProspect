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
        if let data = UserDefaults.standard.data(forKey: Self.saveKey){
            if let decodedData = try? JSONDecoder().decode([Prospect].self, from: data){
            self.prospects = decodedData
                return
            }
        }
         self.prospects = []
    }
    
    //Methods
   private func save(){
        if let encoded = try? JSONEncoder().encode(prospects){
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
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
}
