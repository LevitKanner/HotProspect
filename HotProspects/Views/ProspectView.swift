//
//  ProspectView.swift
//  HotProspects
//
//  Created by Levit Kanner on 14/12/2019.
//  Copyright © 2019 Levit Kanner. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

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
    
    ///Tracks the state of actionSheet
    @State private var showingActionSheet = false
    
    
    
    var body: some View {
        NavigationView{
            List{
                ForEach(self.filteredProspects){prospect in
                    HStack{
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.custom("optima", size: 20))
                            Text(prospect.email)
                                .font(.custom("Monaco", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if self.filter == .none{
                                Image(systemName: prospect.isContacted ? "phone" : "phone.down")
                                    .imageScale(.medium)
                                    .foregroundColor(.blue)
                        }
                    }
                        ///Adds a context menu
                    .contextMenu {
                        Button(action: {
                            self.prospects.toggle(prospect)
                        }){
                            Text(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted")
                        }
                        
                        if !prospect.isContacted{
                            Button(action: {
                                self.addNotificaton(for: prospect)
                            }){
                                Image(systemName: "bell")
                                Text("Remind me")
                            }
                        }
                    }
                }
            }
                
                ///Presents the scanner view
            .sheet(isPresented: $showingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: "levit kaner\n lkanner21@gmail.com", completion: self.handleScan)
            })
                
                ///Adds an action sheet for users to sort contact list
                .actionSheet(isPresented: $showingActionSheet, content: { () -> ActionSheet in
                    ActionSheet(title: Text("Sort contacts by"), message: nil, buttons:
                        [
                            .default(Text("Name"), action: {
                                self.prospects.sort()
                            }),
                            .default(Text("Recent"), action: {
                                self.prospects.sortByRecent()
                            }),
                        .cancel()
                    ])
                })
                
                .navigationBarTitle(title)
                .navigationBarItems(leading: Button(action: {self.showingActionSheet = true }){Text("Sort list")}  , trailing: Button(action:{
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
            self.prospects.add(newProspect)
            
            
        case .failure(let error):
            print("An error occurred while scanning code \(error)")
        }
    }
    
    
    func addNotificaton(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            ///Defines the notification content
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
            ///Creates a notification trigger
            /// let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
            
            ///Creates a notification request with the defined trigger and content
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized{
                addRequest()
            }else{
                center.requestAuthorization(options: [.alert , .badge , .sound]) { (success, error) in
                    if let error = error {
                        print("Oops! \(error)")
                        return
                    }
                    addRequest()
                    
                }
            }
        }
        
    }
}

struct ProspectView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectView(filter: .none)
    }
}
