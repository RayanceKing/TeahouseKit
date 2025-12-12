//
//  TeahouseKit.swift
//  TeahouseKit
//
//  Created by rayanceking on 2025/12/11.
//

import Foundation

// MARK: - Models

public struct TeahouseFeedPost: Identifiable, Hashable, Codable, Sendable {
	public let id: String
	public let category: String
	public let title: String
	public let content: String?
	public let user: String
	public let isAnonymous: Bool
	public let timeString: String?
	public let images: [URL]
	public let likes: Int
	public let comments: Int
	public let tags: [String]
	public let price: String?

	public var createdAt: Date? {
		TeahouseDateParser.parse(timeString)
	}

	public init(
		id: String,
		category: String,
		title: String,
		content: String?,
		user: String,
		isAnonymous: Bool,
		timeString: String?,
		images: [URL],
		likes: Int,
		comments: Int,
		tags: [String],
		price: String?
	) {
		self.id = id
		self.category = category
		self.title = title
		self.content = content
		self.user = user
		self.isAnonymous = isAnonymous
		self.timeString = timeString
		self.images = images
		self.likes = likes
		self.comments = comments
		self.tags = tags
		self.price = price
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let stringId = try? container.decode(String.self, forKey: .id) {
			id = stringId
		} else if let intId = try? container.decode(Int.self, forKey: .id) {
			id = String(intId)
		} else {
			id = UUID().uuidString
		}

		category = (try? container.decode(String.self, forKey: .category)) ?? ""
		title = (try? container.decode(String.self, forKey: .title)) ?? ""
		content = try? container.decode(String.self, forKey: .content)
		user = (try? container.decode(String.self, forKey: .user)) ?? "匿名"
		isAnonymous = (try? container.decode(Bool.self, forKey: .isAnonymous)) ?? false
		timeString = try? container.decode(String.self, forKey: .time)
		tags = (try? container.decode([String].self, forKey: .tags)) ?? []
		price = try? container.decode(String.self, forKey: .price)

		likes = (try? container.decode(Int.self, forKey: .likes)) ?? 0
		comments = (try? container.decode(Int.self, forKey: .comments)) ?? 0

		let imageStrings = (try? container.decode([String].self, forKey: .images)) ?? []
		images = imageStrings.compactMap { URL(string: $0) }
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(category, forKey: .category)
		try container.encode(title, forKey: .title)
		try container.encodeIfPresent(content, forKey: .content)
		try container.encode(user, forKey: .user)
		try container.encode(isAnonymous, forKey: .isAnonymous)
		try container.encodeIfPresent(timeString, forKey: .time)
		let imageStrings = images.map { $0.absoluteString }
		try container.encode(imageStrings, forKey: .images)
		try container.encode(likes, forKey: .likes)
		try container.encode(comments, forKey: .comments)
		try container.encode(tags, forKey: .tags)
		try container.encodeIfPresent(price, forKey: .price)
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case category
		case title
		case content
		case user
		case isAnonymous = "is_anonymous"
		case time
		case images
		case likes
		case comments
		case tags
		case price
	}
}

public struct TeahouseBanner: Identifiable, Hashable, Codable, Sendable {
	public let id: String
	public let title: String
	public let content: String
	public let colorHex: String
	public let startDate: Date?
	public let endDate: Date?

	public init(
		id: String,
		title: String,
		content: String,
		colorHex: String,
		startDate: Date?,
		endDate: Date?
	) {
		self.id = id
		self.title = title
		self.content = content
		self.colorHex = colorHex
		self.startDate = startDate
		self.endDate = endDate
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let stringId = try? container.decode(String.self, forKey: .id) {
			id = stringId
		} else if let intId = try? container.decode(Int.self, forKey: .id) {
			id = String(intId)
		} else {
			id = UUID().uuidString
		}

		title = (try? container.decode(String.self, forKey: .title)) ?? ""
		content = (try? container.decode(String.self, forKey: .content)) ?? ""
		colorHex = (try? container.decode(String.self, forKey: .color)) ?? "#4ECDC4"

		if let startString = try? container.decode(String.self, forKey: .startDate) {
			startDate = TeahouseDateParser.parse(startString)
		} else {
			startDate = nil
		}

		if let endString = try? container.decode(String.self, forKey: .endDate) {
			endDate = TeahouseDateParser.parse(endString)
		} else {
			endDate = nil
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(content, forKey: .content)
		try container.encode(colorHex, forKey: .color)
		if let startDate {
			// encode as ISO8601 string to match decoding style
			let str = TeahouseDateParser.isoString(from: startDate)
			try container.encode(str, forKey: .startDate)
		}
		if let endDate {
			let str = TeahouseDateParser.isoString(from: endDate)
			try container.encode(str, forKey: .endDate)
		}
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case title
		case content
		case color
		case startDate = "start_date"
		case endDate = "end_date"
	}
}

public struct TeahousePage: Hashable, Codable, Sendable {
	public let page: Int
	public let total: Int
	public let hasMore: Bool
	public let posts: [TeahouseFeedPost]

	public init(page: Int, total: Int, hasMore: Bool, posts: [TeahouseFeedPost]) {
		self.page = page
		self.total = total
		self.hasMore = hasMore
		self.posts = posts
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		page = (try? container.decode(Int.self, forKey: .page)) ?? 1
		total = (try? container.decode(Int.self, forKey: .total)) ?? 0
		hasMore = (try? container.decode(Bool.self, forKey: .hasMoreFlag)) ?? false
		posts = (try? container.decode([TeahouseFeedPost].self, forKey: .list)) ?? []
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(page, forKey: .page)
		try container.encode(total, forKey: .total)
		try container.encode(hasMore, forKey: .hasMoreFlag)
		try container.encode(posts, forKey: .list)
	}

	private enum CodingKeys: String, CodingKey {
		case page
		case total
		case hasMoreFlag = "has_more"
		case list
	}
}

private struct TeahouseEnvelope<T: Decodable>: Decodable {
	let code: Int
	let message: String
	let data: T
}

// MARK: - Client

public enum TeahouseClientError: LocalizedError {
	case invalidURL
	case badStatus(Int)
	case decodingFailed

	public var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid Teahouse endpoint"
		case .badStatus(let code):
			return "Unexpected status code: \(code)"
		case .decodingFailed:
			return "Unable to decode response"
		}
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public actor TeahouseClient {
	private let baseURL: URL
	private let session: URLSession
	private let decoder: JSONDecoder

	public init(baseURL: URL? = URL(string: "https://teahouse.czumc.vip/api"), session: URLSession = .shared) {
		self.baseURL = baseURL ?? URL(string: "https://teahouse.czumc.vip/api")!
		self.session = session
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .useDefaultKeys
		self.decoder = decoder
	}

	public func fetchPosts(page: Int = 1) async throws -> TeahousePage {
		let url = try makeURL(path: "posts.json", queryItems: [
			URLQueryItem(name: "page", value: String(page))
		])
		let data = try await request(url)
		do {
			let envelope = try decoder.decode(TeahouseEnvelope<TeahousePage>.self, from: data)
			return envelope.data
		} catch {
			throw TeahouseClientError.decodingFailed
		}
	}

	public func fetchBanners() async throws -> [TeahouseBanner] {
		let url = try makeURL(path: "banners.json")
		let data = try await request(url)
		do {
			let envelope = try decoder.decode(TeahouseEnvelope<[TeahouseBanner]>.self, from: data)
			return envelope.data
		} catch {
			throw TeahouseClientError.decodingFailed
		}
	}

	private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
		let url = baseURL.appendingPathComponent(path)
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw TeahouseClientError.invalidURL
		}
		if !queryItems.isEmpty {
			components.queryItems = queryItems
		}
		guard let finalURL = components.url else {
			throw TeahouseClientError.invalidURL
		}
		return finalURL
	}

	private func request(_ url: URL) async throws -> Data {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
			let (data, response) = try await session.data(for: request)
			guard let httpResponse = response as? HTTPURLResponse else {
				throw TeahouseClientError.invalidURL
			}
			guard 200..<300 ~= httpResponse.statusCode else {
				throw TeahouseClientError.badStatus(httpResponse.statusCode)
			}
			return data
		} else {
			// Fallback for older OS versions using continuation
			let (data, response) = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
				let task = session.dataTask(with: request) { data, response, error in
					if let error {
						continuation.resume(throwing: error)
						return
					}
					guard let data = data, let response = response else {
						continuation.resume(throwing: TeahouseClientError.invalidURL)
						return
					}
					continuation.resume(returning: (data, response))
				}
				task.resume()
			}
			guard let httpResponse = response as? HTTPURLResponse else {
				throw TeahouseClientError.invalidURL
			}
			guard 200..<300 ~= httpResponse.statusCode else {
				throw TeahouseClientError.badStatus(httpResponse.statusCode)
			}
			return data
		}
	}
}

// MARK: - Helpers

enum TeahouseDateParser {
	static func parse(_ string: String?) -> Date? {
		guard let string else { return nil }
		// Try ISO8601 with fractional seconds first
		let iso = ISO8601DateFormatter()
		iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		if let date = iso.date(from: string) { return date }
		// Try without fractional seconds
		let isoNoFrac = ISO8601DateFormatter()
		isoNoFrac.formatOptions = [.withInternetDateTime]
		if let date = isoNoFrac.date(from: string) { return date }
		// Try custom short format
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter.date(from: string)
	}

	static func isoString(from date: Date) -> String {
		let iso = ISO8601DateFormatter()
		iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return iso.string(from: date)
	}
}
