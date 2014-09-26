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
      case .String:
        UnsafeMutablePointer<[UInt8]>(ptr).dealloc(1)
      case .Array(let box):
        // TODO: Handle int array
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
