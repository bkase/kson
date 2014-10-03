//
//  HSON.m
//  gsoning
//
//  Created by Highlight on 9/25/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "KSON.h"
#import "Kson-Swift.h"

@implementation _KSON: NSObject

- (void) setProp:(id)obj :(NSString*)prop :(void *)value {
  object_setInstanceVariable(obj, [prop UTF8String], *(int **)value);
}

- (NSString*) strOfClass:(id)obj forProp:(NSString*)prop {
  @try {
    return [NSString stringWithUTF8String:[obj typeOfPropertyNamed:prop]];
  }
  @catch (NSException *e) {
    return nil;
  }
}

- (void) setProp:(id)obj :(NSString*)prop withNSObject:(id)value {
  unsigned int varCount;

  // Thing* thing = [[Thing alloc] init];

  Ivar *vars = class_copyIvarList([obj class], &varCount);

  for (int i = 0; i < varCount; i++) {
    Ivar var = vars[i];

    const char* name = ivar_getName(var);

    if (strcmp(name, [prop UTF8String]) == 0) {
      object_setIvar(obj, var, value);
      return;
    }
  }

  free(vars);
}

- (void) dumpInfo:(id)obj :(id)thang {
  unsigned int varCount;

  // Thing* thing = [[Thing alloc] init];

  Ivar *vars = class_copyIvarList([obj class], &varCount);

  for (int i = 0; i < varCount; i++) {
    Ivar var = vars[i];

    const char* name = ivar_getName(var);
    NSLog(@"%s", name);
  }

  /*for (NSString* prop in [obj propertyNames]) {
    NSString* typ = [NSString stringWithUTF8String:[(Thing*)obj typeOfPropertyNamed:prop]];
    NSLog(@"%@", typ);
  }*/

  free(vars);

  /*for (NSString* prop in [obj propertyNames]) {
    NSString* typ = [NSString stringWithUTF8String:[obj typeOfPropertyNamed:prop]];
    if ([typ isEqualToString:@"Tq"]) {
      SEL intSetter = [obj setterForPropertyNamed:prop];
      NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: [[obj class] instanceMethodSignatureForSelector:intSetter]];
      [invocation setTarget:obj];
      [invocation setArgument:(void *)3 atIndex:0];
      [invocation invoke];
    }
  }*/
}

@end
