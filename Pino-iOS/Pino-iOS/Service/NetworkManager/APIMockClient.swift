//
//  APIMockClient.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 1/12/23.
//

import Combine
import Foundation

final class APIMockClient: APIService {
	func transactions() -> AnyPublisher<[Transaction], APIError> {
		publisher(for: "transactions-mock")
	}
}

extension APIMockClient {
	fileprivate func publisher<T: Decodable>(for resource: String) -> AnyPublisher<T, APIError> {
		Just(stubData(for: resource))
			.setFailureType(to: APIError.self)
			.eraseToAnyPublisher()
	}

	fileprivate func stubData<T: Decodable>(for resource: String) -> T {
		guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
		      let data = try? Data(contentsOf: url),
		      let mockData = try? JSONDecoder().decode(T.self, from: data)
		else {
			fatalError("Mock data not found")
		}
		return mockData
	}
}
