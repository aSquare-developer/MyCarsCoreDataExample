//
//  Car+CoreDataProperties.swift
//  MyCars
//
//  Created by Artur Anissimov on 15.02.2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var rating: Double
    @NSManaged public var timesDriven: Int16
    @NSManaged public var lastStarted: Date?
    @NSManaged public var myChoice: Bool
    @NSManaged public var imagesData: Data?
    @NSManaged public var tintColor: NSObject?

}
