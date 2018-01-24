//
//  API.swift
//  Tournaments
//
//  Created by Phil Larson on 1/23/18.
//  Copyright © 2018 Phil Larson. All rights reserved.
//

import Foundation

class API {

    // MARK: - Initialize

    static let shared: API = API()

    // MARK: - Types

    enum Error: Swift.Error {
        case unauthorized
        case decodeError
    }

    // MARK: - Authentication

    func loadAccessToken(with completionHandler: ((Swift.Error?)->Void)? = nil) {
        let url = URL(string: "authentications/tokens", relativeTo: self.baseUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil, let data = data else {
                debugPrint("\(String(describing: error))")
                completionHandler?(error)
                return
            }

            guard let accessToken = String(data: data, encoding: .utf8) else {
                debugPrint("Invalid response")
                completionHandler?(error)
                return
            }

            DispatchQueue.main.async {
                self?.accessToken = accessToken
                completionHandler?(nil)
            }
        }
        dataTask.resume()
    }


    // MARK: - Tournaments

    struct TournamentsResponse: Decodable {
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let subvalues = try values.decode([Tournament].self, forKey: .data)
            self.tournaments = subvalues
        }

        enum CodingKeys: String, CodingKey {
            case data
        }

        let tournaments: [Tournament]
    }

    func loadTournaments(with completionHandler: (([Tournament]?, Swift.Error?)->Void)? = nil) {
        guard let accessToken = self.accessToken else {
            self.loadAccessToken { error in
                guard error == nil else {
                    completionHandler?(nil, error)
                    return
                }

                self.loadTournaments(with: completionHandler)
            }
            return
        }

        let url = URL(string: "tournaments", relativeTo: self.baseUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "X-Acme-Authentication-Token": accessToken
        ]

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if error == nil {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                    let response = try decoder.decode(TournamentsResponse.self, from: data!)
                    DispatchQueue.main.async {
                        completionHandler?(response.tournaments, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, error)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    completionHandler?(nil, error)
                }
            }
        }
        dataTask.resume()
    }

    // MARK: - Participation

    struct ParticipationResponse: Decodable {
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let subvalues = try values.decode(Participation.self, forKey: .data)
            self.participation = subvalues
        }

        enum CodingKeys: String, CodingKey {
            case data
        }

        let participation: Participation
    }

    func addParticipiation(to tournamentIdentifier: String, with completionHandler: ((Participation?, Swift.Error?)->Void)? = nil) {
        guard let accessToken = self.accessToken else {
            completionHandler?(nil, Error.unauthorized)
            return
        }

        let url = URL(string: "tournaments/\(tournamentIdentifier)/participation", relativeTo: self.baseUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = [
            "X-Acme-Authentication-Token": accessToken
        ]

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if error == nil {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                    let response = try decoder.decode(ParticipationResponse.self, from: data!)
                    DispatchQueue.main.async {
                        completionHandler?(response.participation, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, error)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    completionHandler?(nil, error)
                }
            }
        }
        dataTask.resume()
    }

    // MARK: - Accessing

    fileprivate let baseUrl: URL = URL(string: "https://damp-chamber-22487.herokuapp.com/api/v1/")!
    fileprivate var accessToken: String?
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
