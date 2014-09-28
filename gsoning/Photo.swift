//
//  Photo.swift
//  gsoning
//
//  Created by Highlight on 9/26/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import Foundation

@objc(Photo) public class Photo: BaseJsonic {
  public dynamic var size: Int = 0
  public dynamic var name: String! = nil

  public dynamic var some_array: Array<String>! = nil

  // private dynamic let _type_complicated_array: Metadata! = nil
  public dynamic var complicated_array: NSArray! = nil
  // etc.
}