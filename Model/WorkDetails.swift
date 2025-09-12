//
//  WorkDetails.swift
//  Book Finder
//
//  Created by Admin on 12/09/25.
//

import Foundation

//MARK: Work Details
struct WorkDetails: Codable {
    let title: String?
    let description: DescriptionField?
    let subjects: [String]?

    struct DescriptionField: Codable {
        let value: String?
    }
}

