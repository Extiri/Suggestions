import Cocoa
import RealmSwift

extension Array {
  func safely(_ index: Int) -> ArrayLiteralElement? {
    if index >= 0 && index < endIndex {
      return self[0]
    } else {
      return nil
    }
  }
}

public class Snippets: Object {
  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var snippets: List<Snippet>
}


public class Snippet: Object, Codable, Identifiable {
  public static func == (lhs: Snippet, rhs: Snippet) -> Bool {
    return lhs.id.uuidString == rhs.id.uuidString
  }
  
  @Persisted(primaryKey: true) public var id: UUID
  
  @Persisted var title: String
  @Persisted var code: String
  @Persisted var desc: String
  @Persisted var lang: String
  @Persisted var tagIDs: List<UUID>
  @Persisted var groupID: UUID?
  
  var isEmpty = false
  
  func fullfills(_ query: String) -> Bool {
    return title.lowercased().contains(query) || code.lowercased().contains(query) || desc.lowercased().contains(query)
  }
}

public class Tag: Codable, Identifiable, Equatable {
  public static func == (lhs: Tag, rhs: Tag) -> Bool {
    return lhs.uuid.uuidString == rhs.uuid.uuidString
  }
  
  public var id: UUID {
    get {
      return uuid
    }
  }
  
  public var uuid: UUID = UUID()
  public var name: String = ""
  public var colorPersisted: CodableColor? = nil
  
  public var color: CodableColor {
    get {
      return colorPersisted ?? .create(red: 1.0, green: 1.0, blue: 1.0)
    }
    
    set {
      colorPersisted = newValue
    }
  }
  
  static func create(uuid: UUID, name: String) -> Tag {
    let tag = Tag()
    
    tag.uuid = uuid
    tag.name = name
    tag.color = .create(red: 1.0, green: 1.0, blue: 1.0)
    
    return tag
  }
  
  static func create(name: String) -> Tag {
    let tag = Tag()
    
    tag.name = name
    tag.color = .create(red: 1.0, green: 1.0, blue: 1.0)
    
    return tag
  }
}

public class CodableColor: Object, Codable, Identifiable {
  public static func == (lhs: CodableColor, rhs: CodableColor) -> Bool {
    return lhs.id.uuidString == rhs.id.uuidString
  }
  
  public var id: UUID = UUID()
  
  @Persisted public var red: Float = 0.0
  @Persisted public var green: Float = 0.0
  @Persisted public var blue: Float = 0.0
  
  @Persisted public var alpha: Float = 1.0
  
  public func cgColor() -> CGColor {
    return CGColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
  }
  
  static func create(red: Float, green: Float, blue: Float, alpha: Float = 1.0) -> CodableColor {
    let codableColor = CodableColor()
    
    codableColor.red = red
    codableColor.green = green
    codableColor.blue = blue
    codableColor.alpha = alpha
    
    return codableColor
  }
  
  static func create(cgColor: CGColor) -> CodableColor {
    let codableColor = CodableColor()
    
    codableColor.red = Float(cgColor.components!.safely(0) ?? 0.0)
    codableColor.green = Float(cgColor.components!.safely(1) ?? 0.0)
    codableColor.blue = Float(cgColor.components!.safely(2) ?? 0.0)
    codableColor.alpha = Float(cgColor.components!.safely(3) ?? 1.0)
    
    return codableColor
  }
}
