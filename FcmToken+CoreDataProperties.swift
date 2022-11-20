//
//  FcmToken+CoreDataProperties.swift
//  
//
//  Created by 안용우 on 2022/11/11.
//
//

import Foundation
import CoreData


extension FcmToken {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FcmToken> {
        return NSFetchRequest<FcmToken>(entityName: "FcmToken")
    }

    @NSManaged public var id: Int64
    @NSManaged public var value: String?

}
