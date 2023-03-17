//
//  FetchedValueHolder.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/8/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import CoreData
import Combine

public class FetchedValueHolder<V>: NSObject, ValueHolder, NSFetchedResultsControllerDelegate {
    @Published public var value: V

    private let controller: NSFetchedResultsController<NSFetchRequestResult>

    private let mapping: ([NSFetchRequestResult]) -> V?

    public convenience init(
        context: NSManagedObjectContext,
        request: NSFetchRequest<NSFetchRequestResult>,
        mapping: @escaping ([NSFetchRequestResult]) -> V?,
        initial: V
    ) {
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(controller: controller, mapping: mapping, initial: initial)
    }

    public init(
        controller: NSFetchedResultsController<NSFetchRequestResult>,
        mapping: @escaping ([NSFetchRequestResult]) -> V?,
        initial: V
    ) {
        self.controller = controller
        self.mapping = mapping
        value = initial
        super.init()

        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            pp_log.error("Unable to perform initial fetch: \(error)")
        }
        mapResults()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mapResults()
    }

    private func mapResults() {
        guard let results = controller.fetchedObjects else {
            return
        }
        pp_log.verbose("Results: \(results)")
        guard let newValue = mapping(results) else {
            return
        }
        value = newValue
    }
}
