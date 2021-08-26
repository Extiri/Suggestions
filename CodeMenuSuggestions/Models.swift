//
//  Models.swift
//  CodeMenuSuggestions
//
//  Created by Wiktor Wójcik on 26/08/2021.
//

import Cocoa

//
//  CardObject.swift
//  CodeMenu
//
//  Created by Wiktor Wójcik on 23/05/2021.
//

extension Array {
	func safely(_ index: Int) -> ArrayLiteralElement? {
		if index >= 0 && index < endIndex {
			return self[0]
		} else {
			return nil
		}
	}
}

public class CardObject: Codable, Identifiable, Hashable {
	public static func == (lhs: CardObject, rhs: CardObject) -> Bool {
		return lhs.uuid.uuidString == rhs.uuid.uuidString
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
	
	enum Kind: String, Codable, Hashable {
		case Snippet = "Snippet"
		case Group = "Group"
		case None = "None"
	}
	
	public let id: UUID
	let uuid: UUID
	
	var type: Kind
	var title: String
	var snippets: [Snippet]
	
	init() {
		self.type = .Snippet
		self.title = ""
		self.snippets = []
		self.uuid = UUID()
		self.id = uuid
	}
	
	init(type: Kind, title: String = "", snippets: [Snippet]) {
		self.type = type
		self.title = title
		self.snippets = snippets
		self.uuid = UUID()
		self.id = uuid
	}
	
	init(_ uuid: UUID, type: Kind, title: String = "", snippets: [Snippet]) {
		self.type = type
		self.title = title
		self.snippets = snippets
		self.uuid = uuid
		self.id = uuid
	}
	
	public convenience init?(coder aDecoder: NSCoder) {
		let uuid = aDecoder.decodeObject(forKey: "uuid") as! UUID
		let type = aDecoder.decodeObject(forKey: "type") as! String
		let title = aDecoder.decodeObject(forKey: "title") as! String
		let snippets = aDecoder.decodeObject(forKey: "snippets") as! [Snippet]
		self.init(uuid, type: Kind(rawValue: type)!, title: title, snippets: snippets)
	}
	
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(uuid, forKey: "uuid")
		aCoder.encode(type.rawValue, forKey: "type")
		aCoder.encode(title, forKey: "title")
		aCoder.encode(snippets, forKey: "snippets")
	}
}

//
//  Snippet.swift
//  CodeMenu
//
//  Created by Wiktor Wójcik on 23/05/2021.
//

public struct Snippet: Codable, Hashable {
	public static func == (lhs: Snippet, rhs: Snippet) -> Bool {
		return lhs.uuid.uuidString == rhs.uuid.uuidString
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
	
	let uuid: UUID
	
	var title: String
	var code: String
	var desc: String
	var tags: [Tag]
	var lang: String
	
	init(title: String, code: String, desc: String = "", tags: [Tag] = [], lang: String = "Swift") {
		self.uuid = UUID()
		self.title = title
		self.code = code
		self.desc = desc
		self.tags = tags
		self.lang = lang
	}
	
	init(_ uuid: UUID, title: String, code: String, desc: String = "", tags: [Tag] = [], lang: String = "Swift") {
		self.uuid = uuid
		self.title = title
		self.code = code
		self.desc = desc
		self.tags = tags
		self.lang = lang
	}
	
	public init?(coder aDecoder: NSCoder) {
		let uuid = aDecoder.decodeObject(forKey: "uuid") as! UUID
		let code = aDecoder.decodeObject(forKey: "code") as! String
		let title = aDecoder.decodeObject(forKey: "title") as! String
		let desc = aDecoder.decodeObject(forKey: "desc") as! String
		let tags = aDecoder.decodeObject(forKey: "tags") as! [Tag]
		let lang = aDecoder.decodeObject(forKey: "lang") as! String
		self.init(uuid, title: title, code: code, desc: desc, tags: tags, lang: lang)
	}
	
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(uuid, forKey: "uuid")
		aCoder.encode(code, forKey: "code")
		aCoder.encode(title, forKey: "title")
		aCoder.encode(desc, forKey: "desc")
		aCoder.encode(tags, forKey: "tags")
		aCoder.encode(lang, forKey: "lang")
	}
}

//
//  Tag.swift
//  CodeMenu
//
//  Created by Wiktor Wójcik on 23/05/2021.
//

public struct Tag: Equatable, Codable, Hashable, Identifiable {
	public static func == (lhs: Tag, rhs: Tag) -> Bool {
		return lhs.uuid.uuidString == rhs.uuid.uuidString
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
	
	public var id: UUID {
		get {
			return uuid
		}
	}
	
	public var uuid: UUID = UUID()
	public var name: String = ""
	public var color: CodableColor = .init(red: 1.0, green: 1.0, blue: 1.0)
	
	public init(uuid: UUID, name: String) {
		self.uuid = uuid
		self.name = name
	}
	
	public init(name: String) {
		self.name = name
	}
	
	public init?(coder aDecoder: NSCoder) {
		let uuid = aDecoder.decodeObject(forKey: "uuid") as! UUID
		let name = aDecoder.decodeObject(forKey: "name") as! String
		self.init(uuid: uuid, name: name)
	}
	
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(uuid, forKey: "uuid")
		aCoder.encode(name, forKey: "name")
	}
}

//
//  CodableColor.swift
//  CodeMenu
//
//  Created by Wiktor Wójcik on 29/05/2021.
//

public struct CodableColor: Equatable, Codable, Hashable, Identifiable {
	public static func == (lhs: CodableColor, rhs: CodableColor) -> Bool {
		return lhs.id.uuidString == rhs.id.uuidString
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public var id: UUID = UUID()
	
	public var red: CGFloat = 0.0
	public var green: CGFloat = 0.0
	public var blue: CGFloat = 0.0
	
	public var alpha: CGFloat = 1.0
	
	public func cgColor() -> CGColor {
		return CGColor(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
	
	public init(cgColor: CGColor) {
		self.red = cgColor.components!.safely(0) ?? 0.0
		self.green = cgColor.components!.safely(1) ?? 0.0
		self.blue = cgColor.components!.safely(2) ?? 0.0
		self.alpha = cgColor.components!.safely(3) ?? 1.0
	}
}
