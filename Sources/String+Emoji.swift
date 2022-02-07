//
//  String+Emoji.swift
//  LimitedInput
//
//  Created by jun on 2022/01/30.
//

import Foundation

/// https://betterprogramming.pub/understanding-swift-strings-characters-and-scalars-a4b82f2d8fde
/// https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
extension String {
    /// 字符串是否包含表情
    internal var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }
    
    /// 字符串是否只有表情
    internal var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }
    
    /// 筛选出字符串中表情，并组成一个新的表情字符串
    internal var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }
    
    /// 筛选出字符串中表情集合
    internal var emojis: [Character] {
        return filter { $0.isEmoji }
    }
    
//    /// 筛选出字符串中表情标量集合
//    internal var emojiScalars: [UnicodeScalar] {
//        return emojis.flatMap { $0.unicodeScalars }
//    }
}

extension Character {
    internal var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    internal var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false
    }
    
    internal var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}
