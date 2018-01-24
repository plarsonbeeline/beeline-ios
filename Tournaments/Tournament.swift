//
//  Tournament.swift
//  Tournaments
//
//  Created by Phil Larson on 1/23/18.
//  Copyright © 2018 Phil Larson. All rights reserved.
//

import Foundation

class Tournament: Decodable {

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(String.self, forKey: .identifier)
        self.type = try values.decode(String.self, forKey: .type)
        self.links = try values.decode([String:URL].self, forKey: .links)

        let attributes = try values.decode(Attributes.self, forKey: .attributes)
        self.name = attributes.name
        self.date = attributes.date
        self.entryMessage = attributes.entryMessage
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case links
        case attributes
    }

    struct Attributes: Decodable {
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try values.decode(String.self, forKey: .name)
            self.date = try values.decode(Date.self, forKey: .date)
            self.entryMessage = try? values.decode(String.self, forKey: .entryMessage)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case date = "created_at"
            case entryMessage = "entry_message"
        }

        let name: String
        let date: Date
        let entryMessage: String?
    }

    // MARK: - Accessing

    let identifier: String
    let type: String
    let links: [String:URL]
    let name: String
    let date: Date
    let entryMessage: String?

    var participation: Participation?
}
