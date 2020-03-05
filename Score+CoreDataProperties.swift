//
//  Score+CoreDataProperties.swift
//  Mastermind
//
//  Created by Platt, Daniel on 01/11/2019.
//  Copyright © 2019 Platt, Daniel. All rights reserved.
//
//

import Foundation
import CoreData


extension Score {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Score> {
        return NSFetchRequest<Score>(entityName: "Score")
    }

    @NSManaged public var wins: Int16
    @NSManaged public var loses: Int16

}
