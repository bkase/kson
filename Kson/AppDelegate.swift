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

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    let start = NSDate()
    let kson = KSON2(types: [
      "Thing": Thing.self,
      "Thang": Thang.self,
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
      "multi": [thang, thang] as AnyObject,
      "skip": ["x": 1, "y": "str", "z": true] as AnyObject
    ], type: Thing.self) as Thing
    let elapsed = NSDate().timeIntervalSince1970 - start.timeIntervalSince1970
    println(elapsed)

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

