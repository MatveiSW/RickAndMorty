//
//  NetworkManager.swift
//  RickAndMorty
//
//  Created by Матвей Авдеев on 10.10.2023.
//

import Kingfisher
import UIKit

enum Link {
    case rickAndMorty
    
    var url: URL {
        switch self {
        case .rickAndMorty:
            return URL(string: "https://rickandmortyapi.com/api/character")!
        }
    }
}

enum NetworkError: Error {
    case noData
    case decodingError
}

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchRickAndMorty<T: Decodable>(_ type: T.Type, withUrl url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let rickAndMorty = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(rickAndMorty))
                }
            } catch {
                completion(.failure(.decodingError))
                
            }
            
        }.resume()
    }
    
    func fetchCharacterImage(withUrl url: URL, image: UIImageView) {
        image.kf.setImage(with: url)
    }
    
    private init() {}
}
