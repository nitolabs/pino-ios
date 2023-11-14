//
//  CDInvestActivity+CoreDataProperties.swift
//  
//
//  Created by Amir hossein kazemi seresht on 11/14/23.
//
//

import Foundation
import CoreData


extension CDInvestActivity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInvestActivity> {
        return NSFetchRequest<CDInvestActivity>(entityName: "CDInvestActivity")
    }

    @NSManaged public var details: CDInvestActivityDetails

}
