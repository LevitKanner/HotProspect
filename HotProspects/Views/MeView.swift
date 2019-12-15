//
//  MeView.swift
//  HotProspects
//
//  Created by Levit Kanner on 14/12/2019.
//  Copyright © 2019 Levit Kanner. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State private var name = ""
    @State private var email = ""
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    TextField("name", text: $name)
                        .textContentType(.name)
                        .font(.title)
                        .padding(.all)
                    
                    TextField("email", text: $email)
                        .textContentType(.emailAddress)
                        .font(.title)
                        .padding(.all)
                    
                }
                .frame(height: 250)
                
                Image(uiImage: generateQrCode(from: "\(name)\n\(email)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200 , height: 200)
                    .padding(.top , 90)
                
                Spacer()
            }
            .navigationBarTitle("Your code", displayMode: .inline)
        }
    }
    
    
    //Generate qrcode using core Image
    func generateQrCode(from string: String) -> UIImage{
        //converts input string into data
        let data = Data(string.utf8)
        //Sets value for filter
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage{
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
        
    }
    
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
