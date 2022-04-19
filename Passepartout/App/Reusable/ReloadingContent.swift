//
//  ReloadingContent.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/4/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import SwiftUI

struct ReloadingContent<O: ObservableObject, T: Equatable, Content: View>: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject private var object: O
    
    private let keyPath: KeyPath<O, [T]>
    
    private var elements: [T] {
        object[keyPath: keyPath]
    }
    
    private let equality: ([T], [T]) -> Bool
    
    private let reload: (() -> Void)?
    
    @ViewBuilder private let content: ([T]) -> Content
    
    @State private var localElements: [T] = []
    
    init(
        observing object: O,
        on keyPath: KeyPath<O, [T]>,
        equality: @escaping ([T], [T]) -> Bool = { $0 == $1 },
        reload: (() -> Void)? = nil,
        @ViewBuilder content: @escaping ([T]) -> Content
    ) {
        self.object = object
        self.keyPath = keyPath
        self.equality = equality
        self.reload = reload
        self.content = content

        // XXX: not sure about this, but if content() is empty .onAppear() will
        // never trigger, thus never setting initial elements
        //
        // BEWARE: localElements will not be automatically bound to changes
        // in elements (use a Binding for that), but this is actually intended
        _localElements = State(initialValue: elements)
        if elements.isEmpty {
            reload?()
        }
    }
    
    var body: some View {
        debugChanges()
        return Group {
            content(localElements)
//        }.onAppear {
//            localElements = elements
//            if localElements.isEmpty {
//                reload?()
//            }
        }.onChange(of: elements) { newElements in
            guard !equality(localElements, newElements) else {
                return
            }
            withAnimation {
                localElements = newElements
            }
        }.onChange(of: scenePhase) {
            if $0 == .active {
                reload?()
            }
        }
    }
}
