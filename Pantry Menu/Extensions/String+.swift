//
//  String+.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/27/24.
//

extension String {
    func titlecased() -> String {
        let withSpaces = self.replacingOccurrences(
            of: "([A-Z])",
            with: " $1",
            options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        return withSpaces.capitalized
    }
}
