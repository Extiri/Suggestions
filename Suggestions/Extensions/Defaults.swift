//
//  Defaults.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 25/05/2024.
//

import Defaults

extension Defaults.Keys {
  static let codeMenuProviderIsEnabled = Defaults.Key("codeMenuProviderIsEnabled", default: true)
  static let codeMenuProviderKey = Defaults.Key("codeMenuProviderKey", default: "")
  static let codeMenuProviderPort = Defaults.Key("codeMenuProviderPort", default: 1300)
}
