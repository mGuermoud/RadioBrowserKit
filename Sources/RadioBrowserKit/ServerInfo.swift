//
//  File.swift
//  RadioBrowserKit
//
//  Created by Simo on 9/6/2025.
//

import Foundation

/// Represents a radio station entry returned by the API
public struct ServerInfo: Codable {
    public let changeuuid: String?
    public let stationuuid: String?
    public let name: String
    public let url: String
    public let homepage: String?
    public let favicon: String?
    public let tags: String?
    public let country: String?
    public let countrycode: String?
    public let state: String?
    public let language: String?
    public let votes: Int?
    public let lastcheckok: Bool?
    public let lastchecktime: TimeInterval?
    public let clicktimestamp: TimeInterval?
    public let clickcount: Int?
    public let codec: String?
    public let bitrate: Int?
}
