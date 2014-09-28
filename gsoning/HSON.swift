//
//  HSON.swift
//  gsoning
//
//  Created by Highlight on 9/26/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import Foundation

class Box<T> {
  let v: T

  init(_ v: T) {
    self.v = v
  }
}

class HSON {
  typealias S = String
  typealias Instruction = (String, Any, AnyObject?, Typ)

  private let hson: _HSON

  enum Typ {
    case Bool
    case NSString(S)
    case Int
    case Double
    case Float
    case ArrayBool
    case ArrayString
    case ArrayInt
    case ArrayDouble
    case ArrayFloat
    case JsonicArray(S)
    case Jsonic(BaseJsonic.Type)
  }

  let clses: [String: BaseJsonic.Type]

  // clses a name->type pair for any JSON dicts
  // ex: ["Thing": Thing.self, "Dog": Dog.self]
  init(clses: [String: BaseJsonic.Type]) {
    self.hson = _HSON()
    self.clses = clses
  }

  func typeToTyp(name: String, val: Any, type: Any.Type, classString: String?) -> Typ? {
    switch type {
    case _ where type is Bool.Type:
      return .Bool
    case _ where type is Int.Type:
      return .Int
    case _ where type is Double.Type:
      return .Double
    case _ where type is Float.Type:
      return .Float
    case _ where type is Array<Bool>.Type:
      return .ArrayBool
    case _ where type is Array<Int>.Type:
      return .ArrayInt
    case _ where type is Array<Double>.Type:
      return .ArrayDouble
    case _ where type is Array<Float>.Type:
      return .ArrayFloat
    case _ where type is Array<String>.Type:
      return .ArrayString
    default:
      break
    }

    if let clazz = classString {
      if clazz == "NSArray" {
        return .JsonicArray(name)
      } else if clazz == "NSString" {
        return .NSString(name)
      }
    }
    return nil
  }

  func inflateJsonicArray(propName: String, rawVal: AnyObject, propTypeMap: [String: String]) -> NSArray {
    let arrayElementTypePropName = "_type_\(propName)"
    let arrayElementClassString = propTypeMap[arrayElementTypePropName]!
    let arrayElementType = clses[arrayElementClassString]!

    let arrayElement = arrayElementType.`new`()
    // TODO: recurse
    return [arrayElement, arrayElement] as NSArray
  }

  func inflate(typ: Typ, rawVal: AnyObject, propTypeMap: [String: String]) -> (Any?, AnyObject?) {
    switch typ {
    case .ArrayBool:
      return (rawVal as? [Bool], nil)
    case .ArrayInt:
      return (rawVal as? [Int], nil)
    case .ArrayDouble:
      return (rawVal as? [Double], nil)
    case .ArrayFloat:
      return (rawVal as? [Float], nil)
    case .ArrayString:
      return (rawVal as? [String], nil)
    case .NSString(let name):
      let str = rawVal as? NSString
      return (str, str)
    case .JsonicArray(let name):
      let arr = inflateJsonicArray(name, rawVal: rawVal, propTypeMap: propTypeMap)
      return (arr, arr)
    default:
      return (nil, nil)
    }
  }

  func strOfClass(obj: BaseJsonic, forProp propName: String) -> String? {
    let uglyStrOpt: String? = hson.strOfClass(obj, forProp: propName)

    if let uglyStr = uglyStrOpt {
      let s = uglyStr
      if s.hasPrefix("T@") && s.utf16Count > 4 {
        return (s as NSString).substringWithRange(NSMakeRange(3, s.utf16Count-4))
      }
    }
    return nil
  }

  // TODO: Make this a generator
  // from: https://gist.github.com/mchambers/67640d9c3e2bcffbb1e2
  // Returns instructions and propName->propType map
  func inflateValuesForProps(obj: BaseJsonic, mirror: MirrorType, dict: NSDictionary, build: [Instruction], propType: [String: String]) -> ([Instruction], [String: String])
  {
    var mutableBuild = build
    var mutablePropType = propType
    for (var i=0;i<mirror.count;i++) {
      if (mirror[i].0 == "super") {
        let t = inflateValuesForProps(obj, mirror: mirror[i].1, dict: dict, build: mutableBuild, propType: mutablePropType)
        mutableBuild = t.0
        mutablePropType = t.1
      } else {
        let (name, child) = mirror[i]

        let classString: String? = strOfClass(obj, forProp: name)
        if let str = classString {
          mutablePropType[name] = str
          println("Got classString: \(str)")
        }

        if (!name.hasPrefix("__")) {
          println("trying: \(name), val: \(child.value)")
          if let typ: Typ = typeToTyp(name, val: child.value, type: child.valueType, classString: classString) {
            println("success typing: \(name)")
            if let rawVal: AnyObject = dict[name] {
              let inflation = inflate(typ, rawVal: rawVal, propTypeMap: mutablePropType)
              let anyOpt = inflation.0
              let anyObjOpt: AnyObject? = inflation.1
              if let any = anyOpt {
                mutableBuild += [(name, any, inflation.1, typ)]
              }
            }
          }
        }
      }
    }
    return (mutableBuild, mutablePropType)
  }

  func setProp<T>(obj: BaseJsonic, withName propName: String, andValue value: Any) -> UnsafeMutablePointer<T> {
    let p = UnsafeMutablePointer<T>.alloc(1)
    p.initialize(value as T)
    hson.setProp(obj as AnyObject, propName, p)
    return p
  }

  func unsafePointerWith(value: Any, ofType typ: Typ, objToSet obj: BaseJsonic, propName: String) -> COpaquePointer? {
    switch typ {
    case .ArrayBool:
      let p: UnsafeMutablePointer<[Bool]> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .ArrayInt:
      let p: UnsafeMutablePointer<[Int]> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .ArrayDouble:
      let p: UnsafeMutablePointer<[Double]> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .ArrayFloat:
      let p: UnsafeMutablePointer<[Float]> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .ArrayString:
      let p: UnsafeMutablePointer<[String]> =
          setProp(obj, withName: propName, andValue: value)
      p.initialize(value as [String])
      return COpaquePointer(p)
    default:
      return nil
    }
  }

  func storeNSObject(value: AnyObject?, ofType typ: Typ, objToSet obj: BaseJsonic, propName: String, propTypeMap: [String: String]) -> Bool {
    if let v: AnyObject = value {
      switch typ {
      case .NSString(let name):
        Unmanaged.passRetained(v)
        hson.setProp(obj, name, withNSObject: v)
      case .JsonicArray(let name):
        Unmanaged.passRetained(v)
        println("Setting name: \(name), v: \(v), toobj: \(obj)")
        hson.setProp(obj, name, withNSObject: v)
        return true
      default:
        return false
      }
    }
    return false
  }

  // commit the instruction to the object
  func persist(obj: BaseJsonic, instruction: Instruction, propTypeMap: [String: String]) {
    let (propName, propValue, propObjValue: AnyObject?, propTyp) = instruction
    if let p = unsafePointerWith(propValue, ofType: propTyp, objToSet: obj, propName: propName) {
      obj.registerProp(p, ofType: propTyp)
    } else if storeNSObject(propObjValue, ofType: propTyp, objToSet: obj, propName: propName, propTypeMap: propTypeMap) {
      println("Persisted NSObject")
    }
  }

  func make(rawDict: NSDictionary, cls: BaseJsonic.Type) -> BaseJsonic {
    let obj: BaseJsonic = cls.`new`()

    let reflectable = cls.alloc()
    let t = inflateValuesForProps(obj, mirror: reflect(reflectable), dict: rawDict, build: [], propType: [:])
    let instrs = t.0
    let propType = t.1

    println(instrs)
    for instruction in instrs {
      persist(obj, instruction: instruction, propTypeMap: propType)
    }

    println(obj)

    return obj
  }
}