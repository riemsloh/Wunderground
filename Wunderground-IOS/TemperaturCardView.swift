//
//  TemperaturCardView.swift
//  Wunderground
//
//  Created by Olaf Lueg on 03.07.25.
//
import SwiftUI

struct TemperaturCardView: View{
    
    var body: some View{
        VStack{
          Image("29")
        }
        .frame(width: 700, height: 200)
        .background(.black)
        .cardBackground()
    }
}
