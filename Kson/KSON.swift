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

public class KSON2 {
  typealias Name = String
  typealias Metatype = BaseJsonic.Type
  typealias Instruction = (String, Any, AnyObject?, Typ)

  private let kson: _KSON

  enum Typ {
    case Bool
    case NSString(Name)
    case Int
    case Double
    case Float
    case ArrayBool
    case ArrayString
    case ArrayInt
    case ArrayDouble
    case ArrayFloat
    case JsonicArray(Name)
    case Jsonic(Name, Metatype)
    case NSDictionary(Name)
  }

  let types: [String: Metatype]

  // types a name->type pair for any JSON dicts
  // ex: ["Thing": Thing.self, "Dog": Dog.self]
  init(types: [String: Metatype]) {
    self.kson = _KSON()
    self.types = types
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
      } else if clazz == "NSDictionary" {
        return .NSDictionary(name)
      }
      if let type = types[clazz] {
        return .Jsonic(name, type)
      }
    }
    return nil
  }

  func arrayType(propName: String, propTypeMap: [String: String]) -> Box<Metatype>? {
    let arrayElementTypePropName = "_type_\(propName)"
    if let arrayElementClassString = propTypeMap[arrayElementTypePropName] {
      if let arrayElementType = types[arrayElementClassString] {
        return Box(arrayElementType)
      } else {
        println("WARNING: \(propName) does is not included in types map from KSON constructor, skipping")
        return nil
      }
    } else {
      println("WARNING: \(propName) does not include _type_\(propName) field just before its definition, skipping")
      return nil
    }
  }

  func inflateJsonicArray(propName: String, rawVal: AnyObject, propTypeMap: [String: String]) -> NSArray? {
    if let arrayElementTypeBox = arrayType(propName, propTypeMap: propTypeMap) {
      if let arr = rawVal as? Array<AnyObject> {
        var build: [AnyObject] = []
        for obj in arr {
          if let dict = obj as? NSDictionary {
            let arrayElement = self.make(dict, type: arrayElementTypeBox.v)
            build += [arrayElement]
          }
        }
        return build
      }
    }
    return nil
  }

  func inflate(typ: Typ, rawVal: AnyObject, propTypeMap: [String: String]) -> (Any?, AnyObject?) {
    switch typ {
    case .Bool:
      return (rawVal as? Bool, nil)
    case .Int:
      return (rawVal as? Int, nil)
    case .Double:
      if let nsnumber = rawVal as? NSNumber {
        return (nsnumber.doubleValue, nil)
      } else {
        return (nil, nil)
      }
    case .Float:
      return (rawVal as? Float, nil)
    case .ArrayBool:
      return (rawVal as? [Bool], nil)
    case .ArrayInt:
      return (rawVal as? [Int], nil)
    case .ArrayDouble:
      if let nsnumbers = rawVal as? [NSNumber] {
        return (nsnumbers.map({ x in x.doubleValue }), nil)
      } else {
        return (nil, nil)
      }
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
    case .Jsonic(let name, let type):
      if let rawDict = rawVal as? NSDictionary {
        let jsonic = self.make(rawDict, type: type)
        return (jsonic, jsonic)
      } else {
        return (nil, nil)
      }
    case .NSDictionary(let name):
      if let rawDict = rawVal as? NSDictionary {
        return (rawDict, rawDict)
      } else {
        return (nil, nil)
      }
    }
  }

  func strOfClass(obj: BaseJsonic, forProp propName: String) -> String? {
    let uglyStrOpt: String? = kson.strOfClass(obj, forProp: propName)

    if let uglyStr = uglyStrOpt {
      let s = uglyStr
      if s.hasPrefix("T@") && s.utf16Count > 4 {
        return (s as NSString).substringWithRange(NSMakeRange(3, s.utf16Count-4))
      }
    }
    return nil
  }

  func inflateValuesForProps(obj: BaseJsonic, mirror: MirrorType, dict: NSDictionary) -> [Instruction] {
    let t = inflateValuesForProps(obj, mirror: mirror, dict: dict, build: [], propType: [:])
    return t.0
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
        }

        if (!name.hasPrefix("__")) {
          if let typ: Typ = typeToTyp(name, val: child.value, type: child.valueType, classString: classString) {
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
    kson.setProp(obj as AnyObject, propName, p)
    return p
  }

  func unsafePointerWith(value: Any, ofType typ: Typ, objToSet obj: BaseJsonic, propName: String) -> COpaquePointer? {
    switch typ {
    case .Bool:
      let p: UnsafeMutablePointer<Bool> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .Int:
      let p: UnsafeMutablePointer<Int> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .Double:
      let p: UnsafeMutablePointer<Double> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
    case .Float:
      let p: UnsafeMutablePointer<Float> =
          setProp(obj, withName: propName, andValue: value)
      return COpaquePointer(p)
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

  func setProp(obj: AnyObject, withName name: Name, andNSObject value: AnyObject) {
    Unmanaged.passRetained(value)
    kson.setProp(obj, name, withNSObject: value)
  }

  func storeNSObject(value: AnyObject?, ofType typ: Typ, objToSet obj: BaseJsonic, propName: String) -> Bool {
    if let v: AnyObject = value {
      switch typ {
      case .NSString(let name):
        setProp(obj, withName: name, andNSObject: v)
        return true
      case .JsonicArray(let name):
        setProp(obj, withName: name, andNSObject: v)
        return true
      case .Jsonic(let name, let _):
        setProp(obj, withName: name, andNSObject: v)
        return true
      case .NSDictionary(let name):
        setProp(obj, withName: name, andNSObject: v)
        return true
      default:
        return false
      }
    }
    return false
  }

  // commit the instruction to the object
  func persist(obj: BaseJsonic, instruction: Instruction) {
    let (propName, propValue, propObjValue: AnyObject?, propTyp) = instruction
    if let p = unsafePointerWith(propValue, ofType: propTyp, objToSet: obj, propName: propName) {
      obj.registerProp(p, ofType: propTyp)
    } else if storeNSObject(propObjValue, ofType: propTyp, objToSet: obj, propName: propName) {
    }
  }

  func make(rawDict: NSDictionary, type: Metatype) -> BaseJsonic {
    let obj: BaseJsonic = type.`new`()

    let reflectable = type.alloc()
    let instrs: [Instruction] =
        inflateValuesForProps(obj, mirror: reflect(reflectable), dict: rawDict)

    for instruction in instrs {
      persist(obj, instruction: instruction)
    }

    return obj
  }

  // from: https://gist.github.com/mchambers/67640d9c3e2bcffbb1e2
  func deflate(typ: Typ, swiftVal val: Any) -> NSObject {
    switch typ {
    case .Bool:
      return (val as Bool) as NSObject
    case .Int:
      return NSNumber(int: CInt(val as Int))
    case .Double:
      return NSNumber(double: CDouble(val as Double))
    case .Float:
      return NSNumber(float: CFloat(val as Float))
    case .Jsonic(let _, let _):
      println("Jsonic at: \(val)")
      return toJson(val as BaseJsonic)
    case .ArrayBool, .ArrayInt, .ArrayDouble, .ArrayFloat, .ArrayString:
      return val as NSArray
    case .NSString(let _):
      return val as NSString
    case .NSDictionary(let _):
      return val as NSDictionary
    case .JsonicArray(let name):
      let arr = val as NSArray
      var build = NSMutableArray(capacity: arr.count)
      arr.enumerateObjectsUsingBlock { obj, idx, stop in
        build.addObject(self.toJson(obj as BaseJsonic))
      }
      return build as NSArray
    }
  }

  // TODO: DRYify this and inflateValuesForProps
  func deflateValuesForProps(obj: BaseJsonic, mirror: MirrorType, build: NSMutableDictionary) -> NSMutableDictionary
  {
    var mutableBuild = build
    for (var i=0;i<mirror.count;i++) {
      if (mirror[i].0 == "super") {
        mutableBuild = deflateValuesForProps(obj, mirror: mirror[i].1, build: mutableBuild)
      } else {
        let (name, child) = mirror[i]

        let classString: String? = strOfClass(obj, forProp: name)

        if (!name.hasPrefix("__") && !name.hasPrefix("_type_")) {
          if let typ: Typ = typeToTyp(name, val: child.value, type: child.valueType, classString: classString) {
            println("Looking at: \(name): \(child.value)")
            if (child.value as Any!) == nil {
              mutableBuild[name] = NSNull()
            } else {
              mutableBuild[name] = deflate(typ, swiftVal: child.value)
            }
          }
        }
      }
    }
    return mutableBuild
  }

  func toJson(obj: BaseJsonic) -> NSDictionary {
    return deflateValuesForProps(obj, mirror: reflect(obj), build: NSMutableDictionary())
  }
}
