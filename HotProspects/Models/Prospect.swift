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
    @Published var prospects: [Prospect]
    
    init(){
        self.prospects = []
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
    }
}
