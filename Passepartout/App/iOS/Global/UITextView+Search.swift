//
//  UITextView+Search.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/1/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

extension UITextView {
    func firstVisibleIndex() -> Int {
        let endOffset = contentOffset
        let end = closestPosition(to: endOffset) ?? beginningOfDocument
        return offset(from: beginningOfDocument, to: end)
    }
    
    func lastVisibleIndex() -> Int {
        let startOffset = CGPoint(
            x: contentOffset.x + frame.size.width,
            y: contentOffset.y + frame.size.height
        )
        let start = closestPosition(to: startOffset) ?? endOfDocument
        return offset(from: beginningOfDocument, to: start)
    }
    
    func findPrevious(string: String) {
        let last = text.index(text.startIndex, offsetBy: firstVisibleIndex())
        let context = text.startIndex..<last
        guard let found = text.range(of: string, options: .backwards, range: context) else {
            scrollToBegin()
            return
        }
        let nsRange = text.nsRange(from: found)
//        log.debug(">>> found: \(nsRange)")
        scrollRangeToVisible(nsRange)
//        scrollRangeToTop(nsRange)
    }
    
    func findNext(string: String) {
        let first = text.index(text.startIndex, offsetBy: lastVisibleIndex())
        let context = first..<text.endIndex
        guard let found = text.range(of: string, range: context) else {
            scrollToEnd()
            return
        }
        let nsRange = text.nsRange(from: found)
//        log.debug(">>> found: \(nsRange)")
        scrollRangeToVisible(nsRange)
//        scrollRangeToTop(nsRange)
    }
    
    func scrollRangeToTop(_ nsRange: NSRange) {
        let start = position(from: beginningOfDocument, offset: nsRange.location) ?? beginningOfDocument
        let end = position(from: start, offset: nsRange.length) ?? endOfDocument
        guard let range = textRange(from: start, to: end) else {
            return
        }
        let target = convert(firstRect(for: range), to: textInputView)
        setContentOffset(target.origin, animated: true)
    }
    
//    func scrollRangeToTop(_ range: NSRange) {
//        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//        let topTextInset = textContainerInset.top
//        let target = CGPoint(x: 0, y: topTextInset + rect.origin.y)
//        setContentOffset(target, animated: true)
//        log.debug(">>> target: \(target)")
//    }
    
    func scrollToBegin() {
        scrollRangeToVisible(NSMakeRange(0, 1))
    }
    
    func scrollToEnd() {
        scrollRangeToVisible(NSMakeRange(text.count - 1, 1))
    }
}
