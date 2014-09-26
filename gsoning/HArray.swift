//
//  HArray.swift
//  gsoning
//
//  Created by Highlight on 9/26/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import Foundation

@objc class HArray<T: BaseJsonic>: NSArray, SequenceType {

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  typealias Generator = HArrayGenerator<T>

  func asArray() -> Array<T> {
    return (self as Array<AnyObject>) as Array<T>
  }

  func generate() -> Generator {
    return HArrayGenerator(arr: asArray())
  }
}

class HArrayGenerator<T: BaseJsonic>: GeneratorType {
  typealias Element = T

  var arr: Array<T>
  var i: Int

  init(arr: Array<T>) {
    self.arr = arr
    self.i = 0
  }

  func next() -> Element? {
    if i < arr.count {
      return self.arr[i++]
    } else {
      return nil
    }
  }
}
