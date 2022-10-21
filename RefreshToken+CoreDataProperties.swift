//
//  RefreshToken+CoreDataProperties.swift
//  
//
//  Created by 안용우 on 2022/10/20.
//
//

import Foundation
import CoreData


extension RefreshToken {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RefreshToken> {
        return NSFetchRequest<RefreshToken>(entityName: "RefreshToken")
    }

    @NSManaged public var id: Int64
    @NSManaged public var value: String?

}
