import XCTest
@testable import RadioBrowserKit

final class RadioBrowserKitTests: XCTestCase {
    
    func testBuildQueryItems() {
        let client = RadioBrowserClient()
        let items = client.buildQuery(
            limit:   10,
            offset:  5,
            order:   "votes",
            reverse: true,
            hideBroken: true
        )
        
        let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) })
        XCTAssertEqual(dict["limit"],      "10")
        XCTAssertEqual(dict["offset"],     "5")
        XCTAssertEqual(dict["order"],      "votes")
        XCTAssertEqual(dict["reverse"],    "true")
        XCTAssertEqual(dict["hidebroken"], "true")
    }
    
    func testStationURLConstruction() {
        let client = RadioBrowserClient()
        
        let host = "https://server1.api.radio-browser.info"
        var components = URLComponents(string: host)!
        components.path = "/json/stations"
        components.queryItems = client.buildQuery(
            limit: 20,
            offset: 0,
            order: "clickcount",
            reverse: false,
            hideBroken: false
        )
        
        let url = components.url!.absoluteString
        XCTAssertEqual(
            url,
            "https://server1.api.radio-browser.info/json/stations?limit=20&offset=0&order=clickcount&reverse=false&hidebroken=false"
        )
    }
    
    func testServerInfoDecoding() throws {
        // sample JSON for one server
        let json = """
        [{
          "changeuuid":"abc-123",
          "stationuuid":"def-456",
          "name":"Test Radio",
          "url":"http://test.example.com/stream",
          "homepage":"http://test.example.com",
          "favicon":"http://test.example.com/favicon.ico",
          "tags":"pop rock",
          "country":"Nowhere",
          "countrycode":"NW",
          "state":"State",
          "language":"en",
          "votes":100,
          "lastcheckok":true,
          "lastchecktime":1620000000.0,
          "clicktimestamp":1620000000.0,
          "clickcount":42,
          "codec":"mp3",
          "bitrate":128
        }]
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let servers = try decoder.decode([ServerInfo].self, from: json)
        XCTAssertEqual(servers.count, 1)
        
        let s = servers[0]
        XCTAssertEqual(s.name,       "Test Radio")
        XCTAssertEqual(s.url,        "http://test.example.com/stream")
        XCTAssertEqual(s.bitrate,    128)
        XCTAssertTrue(s.lastcheckok ?? false)
    }
}
