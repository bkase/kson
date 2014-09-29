//
//  Thing.swift
//  gsoning
//
//  Created by Highlight on 9/25/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import Foundation

@objc(Thang) public class Thang: BaseJsonic {
  public dynamic var x: Int = 0
  public dynamic var y: Int = 0

  lazy var string: String = {
    return "Thang{x:\(self.x), y:\(self.y)}"
  }()
}

@objc(Thing) public class Thing: BaseJsonic {
  public dynamic var i: Int = 0
  public dynamic var f: Float = 0
  public dynamic var d: Double = 0
  public dynamic var s: NSString! = nil

  private dynamic let _type_multi: Thang! = nil
  public dynamic var multi: NSArray! = nil

  public dynamic var b: Bool = false
  public dynamic var arri: [Int]! = nil
  public dynamic var arrs: [String]! = nil
  public dynamic var thang: Thang! = nil

  lazy var string: String = {
    let arr = self.multi as Array<Thang>
    return "i:\(self.i), f:\(self.f), d:\(self.d), s:\(self.s), b:\(self.b), arri:\(self.arri), arrs:\(self.arrs), thang: \(self.thang.string), multi:\(arr.map{ t in t.string })"
  }()
}
