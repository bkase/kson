//
//  Jsonic.swift
//  gsoning
//
//  Created by Highlight on 9/25/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import Foundation

@objc protocol JsonicProtocol {
}

public class BaseJsonic: NSObject, JsonicProtocol {
  private var __registeredProps: [(COpaquePointer, HSON.Typ)] = []

  deinit {
    for prop in __registeredProps {
      let (ptr, typ) = prop
      switch typ {
      case .ArrayBool:
        UnsafeMutablePointer<[Bool]>(ptr).dealloc(1)
      case .ArrayInt:
        UnsafeMutablePointer<[Int]>(ptr).dealloc(1)
      case .ArrayDouble:
        UnsafeMutablePointer<[Double]>(ptr).dealloc(1)
      case .ArrayFloat:
        UnsafeMutablePointer<[Float]>(ptr).dealloc(1)
      case .ArrayString:
        UnsafeMutablePointer<[String]>(ptr).dealloc(1)
      default:
        break
      }
      println("Dealloced registered prop")
    }
  }

  func registerProp(ptr: COpaquePointer, ofType typ: HSON.Typ) {
    __registeredProps += [(ptr, typ)]
  }
}
