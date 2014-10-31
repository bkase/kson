//
//  Jsonic.swift
//  gsoning
//
//  Created by Highlight on 9/25/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import Foundation

public class BaseJsonic: NSObject {
  private var __registeredProps: [(COpaquePointer, KSON2.Typ)] = []

  override init() {
    
  }

  func complete(dict: NSDictionary) {
    // override this to finish anything KSON misses
  }

  deinit {
    for prop in __registeredProps {
      let (ptr, typ) = prop
      switch typ {
      case .Bool:
        UnsafeMutablePointer<Bool>(ptr).dealloc(1)
      case .NSString(let _):
        break
      case .Int:
        UnsafeMutablePointer<Int>(ptr).dealloc(1)
      case .Double:
        UnsafeMutablePointer<Double>(ptr).dealloc(1)
      case .Float:
        UnsafeMutablePointer<Float>(ptr).dealloc(1)
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
      case .JsonicArray(let _):
        break
      case .Jsonic(let _):
        break
      case .NSDictionary(let _):
        break
      }
    }
  }

  func registerProp(ptr: COpaquePointer, ofType typ: KSON2.Typ) {
    __registeredProps += [(ptr, typ)]
  }
}
