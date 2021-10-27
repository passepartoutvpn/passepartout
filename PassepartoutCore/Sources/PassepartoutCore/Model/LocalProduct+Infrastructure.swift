//
//  File.swift
//  
//
//  Created by Davide De Rosa on 04/11/21.
//

import Foundation
import PassepartoutConstants

public extension LocalProduct {
//    public static var allProviders: [LocalProduct] {
//        return InfrastructureFactory.shared.allMetadata.map {
//            return LocalProduct(providerMetadata: $0)
//        }
//    }
    
    fileprivate init(providerMetadata: Infrastructure.Metadata) {
        self.init(rawValue: "\(LocalProduct.providersBundle).\(providerMetadata.inApp ?? providerMetadata.name)")!
    }
}

public extension Infrastructure.Metadata {
    var product: LocalProduct {
        return LocalProduct(providerMetadata: self)
    }
}
