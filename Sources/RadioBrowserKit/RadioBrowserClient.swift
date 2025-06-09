import Foundation

/// Client for querying the Radio Browser API
public class RadioBrowserClient {
    private let session: URLSession
    private let serversURL = URL(string: "https://all.api.radio-browser.info/json/servers")!

    public init(userAgent: String = "RadioBrowserKit/1.0") {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": userAgent]
        self.session = URLSession(configuration: config)
    }

    // MARK: - Asynchronous

    /// Fetch station list with parameters asynchronously
    public func fetchServerList(
        limit: Int? = nil,
        offset: Int? = nil,
        order: String? = nil,
        reverse: Bool? = nil,
        hideBroken: Bool? = nil,
        completion: @escaping (Result<[ServerInfo], RadioBrowserError>) -> Void
    ) {
        getServers { [weak self] result in
            switch result {
            case .success(let hosts):
                self?.requestStations(
                    hosts: hosts,
                    limit: limit,
                    offset: offset,
                    order: order,
                    reverse: reverse,
                    hideBroken: hideBroken,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Synchronous

    /// Blocking fetch variant (not recommended on main thread)
    public func fetchServerListSync(
        limit: Int? = nil,
        offset: Int? = nil,
        order: String? = nil,
        reverse: Bool? = nil,
        hideBroken: Bool? = nil
    ) throws -> [ServerInfo] {
        let sem = DispatchSemaphore(value: 0)
        var result: Result<[ServerInfo], RadioBrowserError>!

        fetchServerList(
            limit: limit,
            offset: offset,
            order: order,
            reverse: reverse,
            hideBroken: hideBroken
        ) { res in
            result = res
            sem.signal()
        }
        sem.wait()

        switch result! {
        case .success(let servers):
            return servers
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Private Helpers

    private func getServers(
        completion: @escaping (Result<[String], RadioBrowserError>) -> Void
    ) {
        session.dataTask(with: serversURL) { data, response, error in
            if let err = error {
                completion(.failure(.networkError(err)))
                return
            }
            guard let data = data else {
                completion(.failure(.noServerAvailable))
                return
            }
            do {
                let hosts = try JSONDecoder().decode([String].self, from: data)
                completion(.success(hosts))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

    private func requestStations(
        hosts: [String],
        limit: Int?,
        offset: Int?,
        order: String?,
        reverse: Bool?,
        hideBroken: Bool?,
        completion: @escaping (Result<[ServerInfo], RadioBrowserError>) -> Void
    ) {
        let path = "/json/stations"
        let queryItems = buildQuery(
            limit: limit,
            offset: offset,
            order: order,
            reverse: reverse,
            hideBroken: hideBroken
        )

        for host in hosts.shuffled() {
            guard var components = URLComponents(string: host) else { continue }
            components.path = path
            components.queryItems = queryItems
            guard let url = components.url else { continue }

            session.dataTask(with: url) { data, response, error in
                if let err = error {
                    // Try next host on error
                    return
                }
                if let http = response as? HTTPURLResponse,
                   http.statusCode != 200 {
                    // Try next host on bad status
                    return
                }
                guard let data = data else {
                    return
                }
                do {
                    let list = try JSONDecoder().decode([ServerInfo].self, from: data)
                    completion(.success(list))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }.resume()

            return // only first reachable attempt
        }
        completion(.failure(.noServerAvailable))
    }

    func buildQuery(
        limit: Int?,
        offset: Int?,
        order: String?,
        reverse: Bool?,
        hideBroken: Bool?
    ) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let l = limit         { items.append(.init(name: "limit", value: "\(l)")) }
        if let o = offset        { items.append(.init(name: "offset", value: "\(o)")) }
        if let ord = order       { items.append(.init(name: "order", value: ord)) }
        if let rev = reverse     { items.append(.init(name: "reverse", value: rev ? "true" : "false")) }
        if let hb = hideBroken   { items.append(.init(name: "hidebroken", value: hb ? "true" : "false")) }
        return items
    }
}
