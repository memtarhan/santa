//
//  Data+.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation

extension Data {
    private var prettyJSON: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .withoutEscapingSlashes]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }

    func printPrettied() {
        print(prettyJSON ?? "None")
    }
}
