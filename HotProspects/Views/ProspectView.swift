//
//  ProspectView.swift
//  HotProspects
//
//  Created by Levit Kanner on 14/12/2019.
//  Copyright © 2019 Levit Kanner. All rights reserved.
//

import SwiftUI

struct ProspectView: View {
    enum FilterType {
        case none , contacted , uncontacted
    }
    
    let filter : FilterType
    
    var title: String{
        switch filter {
        case .none:
            return "Contacts"
        case .contacted:
            return "Contacted"
        case  .uncontacted:
            return "Uncontacted"
        }
    }
    
    var filteredProspects: [Prospect]{
        switch filter{
        case .contacted:
            return prospects.prospects.filter { (prospect) -> Bool in
                prospect.isContacted
                
            }
        case .none:
            return prospects.prospects
        case .uncontacted:
            return prospects.prospects.filter { (prospect) -> Bool in
                !prospect.isContacted
            }
        }
    }
    @EnvironmentObject var prospects: Prospects
    
    
    var body: some View {
        NavigationView{
            List{
                ForEach(self.filteredProspects){prospect in
                    VStack(alignment: .leading){
                        Text(prospect.name)
                            .font(.custom("optima", size: 20))
                        Text(prospect.email)
                            .font(.custom("Monaco", size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(trailing: Button(action:{
                let paul = Prospect()
                paul.email = "Paulhudson@gmail.com"
                paul.name = "Paul Hudson"
                
                self.prospects.prospects.append(paul)
            }){
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            })
        }
    }
}

struct ProspectView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectView(filter: .none)
    }
}
