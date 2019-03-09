//
//  TableModel.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/25/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

import Foundation

protocol TableModelHost {
    associatedtype S: Hashable
    
    associatedtype R: Equatable
    
    var model: TableModel<S, R> { get }
    
    func reloadModel()
}

class TableModel<S: Hashable, R: Equatable> {
    private var sections: [S]
    
    private var headerBySection: [S: String]
    
    private var footerBySection: [S: String]
    
    private var rowsBySection: [S: [R]]
    
    init() {
        sections = []
        headerBySection = [:]
        footerBySection = [:]
        rowsBySection = [:]
    }
    
    func clear() {
        sections = []
        headerBySection = [:]
        footerBySection = [:]
        rowsBySection = [:]
    }

    // MARK: Access
    
    var count: Int {
        return sections.count
    }

    func section(for sectionIndex: Int) -> S {
        return sections[sectionIndex]
    }
    
    func index(ofSection sectionObject: S) -> Int {
        guard let sectionIndex = sections.index(of: sectionObject) else {
            fatalError("Missing section: \(sectionObject)")
        }
        return sectionIndex
    }

    func rows(for sectionIndex: Int) -> [R] {
        let sectionObject = sections[sectionIndex]
        guard let rows = rowsBySection[sectionObject] else {
            fatalError("Missing section: \(sectionObject)")
        }
        return rows
    }
    
    func row(at indexPath: IndexPath) -> R {
        return rows(for: indexPath.section)[indexPath.row]
    }
    
    func count(for sectionIndex: Int) -> Int {
        return rows(for: sectionIndex).count
    }
    
    func indexPath(row rowObject: R, section sectionObject: S) -> IndexPath? {
        guard let sectionIndex = sections.index(of: sectionObject) else {
            fatalError("Missing section: \(sectionObject)")
        }
        guard let row = rowsBySection[sectionObject]?.index(of: rowObject) else {
            return nil
        }
        return IndexPath(row: row, section: sectionIndex)
    }
    
    func header(for sectionIndex: Int) -> String? {
        let sectionObject = sections[sectionIndex]
        return headerBySection[sectionObject]
    }

    func header(for sectionObject: S) -> String? {
        return headerBySection[sectionObject]
    }

    func footer(for sectionIndex: Int) -> String? {
        let sectionObject = sections[sectionIndex]
        return footerBySection[sectionObject]
    }

    func footer(for sectionObject: S) -> String? {
        return footerBySection[sectionObject]
    }

    // MARK: Modification
    
    func add(_ section: S) {
        sections.append(section)
    }

    func setHeader(_ header: String, for sectionObject: S) {
        headerBySection[sectionObject] = header
    }
    
    func removeHeader(for sectionObject: S) {
        headerBySection.removeValue(forKey: sectionObject)
    }
    
    func setFooter(_ footer: String, for sectionObject: S) {
        footerBySection[sectionObject] = footer
    }
    
    func removeFooter(for sectionObject: S) {
        footerBySection.removeValue(forKey: sectionObject)
    }

    func set(_ rows: [R], in sectionObject: S) {
        rowsBySection[sectionObject] = rows
    }

    func set(_ row: R, count: Int, in sectionObject: S) {
        rowsBySection[sectionObject] = [R](repeating: row, count: count)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        deleteRow(in: section(for: indexPath.section), at: indexPath.row)
    }

    func deleteRow(in sectionObject: S, at rowIndex: Int) {
        rowsBySection[sectionObject]?.remove(at: rowIndex)
    }
}
