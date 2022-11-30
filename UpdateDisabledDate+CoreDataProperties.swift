//
//  UpdateDisabledDate+CoreDataProperties.swift
//  
//
//  Created by 안용우 on 2022/11/28.
//
//

import Foundation
import CoreData


extension UpdateDisabledDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UpdateDisabledDate> {
        return NSFetchRequest<UpdateDisabledDate>(entityName: "UpdateDisabledDate")
    }

    @NSManaged public var id: Int64
    @NSManaged public var date: Date?

}
