//
//  KsonPerformance.swift
//  KsonPerformance
//
//  Created by Highlight on 9/28/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import UIKit
import XCTest
import Kson

class KsonPerformance: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock() {
      /*let kson = KSON2(types: [
      "Thing": Thing.self,
      "Thang": Thang.self
      /* other types deserialized by HSON (recursively) */
      ])

    let thang: AnyObject = ["x": 1, "y": 9] as AnyObject
    let thing: Thing = kson.make([
      "b": true,
      "i": 40,
      "d": 23.5,
      "f": 12.3,
      "s": "hello",
      "thang": ["x": 3, "y": 8] as AnyObject,
      "arrs": ["a", "b", "c"] as AnyObject,
      "arri": [1, 2, 3] as AnyObject,
      "multi": [thang, thang] as AnyObject
    ], type: Thing.self) as Thing*/
      // Put the code you want to measure the time of here.
    }
  }
  
}
