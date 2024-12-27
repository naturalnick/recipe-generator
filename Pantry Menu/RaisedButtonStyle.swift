//
//  RaisedButtonStyle.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/26/24.
//

import SwiftUI

struct RaisedButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.blue)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.black)
                            .offset(y: configuration.isPressed ? 0 : 5)
                    )
                
            )
            .offset(y: configuration.isPressed ? 4 : 0)
    }
    
}
