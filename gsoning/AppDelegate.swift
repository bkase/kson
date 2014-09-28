//
//  AppDelegate.swift
//  gsoning
//
//  Created by Highlight on 9/25/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  let hackQ: dispatch_queue_t = dispatch_queue_create("hackq", DISPATCH_QUEUE_SERIAL)

  var window: UIWindow?

  func makeIt() -> [String] {
    var strArr = ["hello", "there", "child", "lots of bytes", "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"]
    /*for i in 0..<1000 {
      strArr += ["\(i)"]
    }*/
    return strArr
  }

  func setString(obj: BaseJsonic, prop: String, val: String) {
    let sel = obj.setterForPropertyNamed(prop)
    dispatch_sync(hackQ) {
      NSThread.detachNewThreadSelector(sel, toTarget: obj, withObject: val)
    }
  }

  func makeAndPrintArr<T: BaseJsonic>(t: T) {
    let arr: Array<T> = [t]
    println("NAME class: \(nameOfClass(T.self))")
  }

  func theFunc() {
    var p = UnsafeMutablePointer<[String]>.alloc(1)
    p.initialize(makeIt())

    let hson = _HSON()
    var thing: Thing? = Thing()
    // thing?.arrs = []
    //let xp = UnsafeMutablePointer<Int>.alloc(sizeof(Int))
    //xp.initialize(4)
    // hson.setProp(thing, "i64", xp)
    hson.setProp(thing, "arrs", p)
    // setString(thing!, prop: "s", val: "hello")
    thing!.registerProp(COpaquePointer(p), ofType: .ArrayString)
    /*if let _ = thing!.multi as? NSArray {
      println("hello world")
    }*/
    let thang = Thang()
    Unmanaged<Thang>.passRetained(thang)
    thang.x = 4
    thang.y = 2

    makeAndPrintArr(thang)
    hson.dumpInfo(thing, thang)
    //println("Thing is now: \(thing!.string)")
    println("Thing is thing: \(thing!.string)")
    //xp.destroy()

    thing = nil
    // p.destroy()
    // p.dealloc(sizeof([String].self))
    println("Thing destroyed win")
  }

  func yo<T: BaseJsonic>(input: Any) -> Bool {
    if let _ = input as? Array<T> {
      return true
    } else {
      return false
    }
  }

  /*func arrays() {
    let x: Any = [Thing(), Thing()]
    println(reflect(x).disposition)
    if let _ = (x as? NSArray) as? Array<BaseJsonic> {
      println("YES")
    } else {
      println("no")
    }

    /*if let _ = x as? (Array<T> where T: BaseJsonic) {
      println("YES typed")
    } else {
      println("no typed")
    }*/
  }*/

  func arrays2() {
    let x: Any = NSArray()
    if let _ = x as? NSArray {
      println("yes)")
    } else {
      println("no")
    }
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    arrays2()

    let hson = HSON(clses: [
      "Thing": Thing.self,
      "Thang": Thang.self,
      /* other types deserialized by HSON (recursively) */
    ])

    let thang: AnyObject = ["recurse": "todo"] as AnyObject
    let thing: Thing = hson.make([
      "b": true,
      "i": 40,
      "d": 23.5,
      "f": 12.3,
      "s": "hello",
      "thang": ["x": 3, "y": 8] as AnyObject,
      "arrs": ["a", "b", "c"] as AnyObject,
      "arri": [1, 2, 3] as AnyObject,
      "multi": [thang, thang] as AnyObject
    ], cls: Thing.self) as Thing


    println()
    println("let thang: AnyObject = [\"recurse\": \"todo\"] as AnyObject\n" +
      "let thing: Thing = hson.make([\"s\": \"hello\", \"arrs\": [\"a\", \"b\", \"c\"] as AnyObject, \"multi\": [thang, thang] as AnyObject], cls: Thing.self) as Thing")
    println()
    println()
    println(thing.string)

    // theFunc()
    // Override point for customization after application launch.
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

