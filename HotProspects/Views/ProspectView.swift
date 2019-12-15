//
//  ProspectView.swift
//  HotProspects
//
//  Created by Levit Kanner on 14/12/2019.
//  Copyright © 2019 Levit Kanner. All rights reserved.
//

import SwiftUI
import CodeScanner

struct ProspectView: View {
    
    ///Properties
    enum FilterType {
        case none , contacted , uncontacted
    }
    
    let filter : FilterType
    
    ///Computes  a title for the navigation bar using the filter property
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
    
    ///Filters prospects based on their isContacted property
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
    
    ///Reads prospects data placed in the environment in the content view
    @EnvironmentObject var prospects: Prospects
    
    ///Shows the scanner view when flipped
    @State private var showingScanner = false
    
    
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
                    .contextMenu {
                        Button(action: {
                            self.prospects.toggle(prospect)
                        }){
                            Text(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: "levit kaner\n lkanner21@gmail.com", completion: self.handleScan)
            })
                .navigationBarTitle(title)
                .navigationBarItems(trailing: Button(action:{
                    self.showingScanner = true
                }){
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
        }
    }
    
    
    ///Handles when a QR code has been scanned
    func handleScan(result: Result<String , CodeScannerView.ScanError>){
        ///Dismisses the scanner view 
        self.showingScanner = false
        
        ///Fetches data from the Result tyoe
        switch result{
        case .success(let code ):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            let newProspect = Prospect()
            newProspect.name = details.first ?? "Anonymous"
            newProspect.email = details.last ?? "noemail"
            self.prospects.prospects.append(newProspect)
            
        case .failure(let error):
            print("An error occurred while scanning code \(error)")
        }
    }
}

struct ProspectView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectView(filter: .none)
    }
}
