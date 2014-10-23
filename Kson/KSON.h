//
//  HSON.h
//  gsoning
//
//  Created by Highlight on 9/25/14.
//  Copyright (c) 2014 Highlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "aqtoolkit/NSObject+Properties.h"

static int test = 3;

@interface _KSON : NSObject

- (void) dumpInfo:(id)obj :(id)thang;
- (void) setProp:(id)obj :(NSString*)prop :(void*)value;
- (void) setProp:(id)obj :(NSString*)prop withNSObject:(id)value;
- (NSString*) strOfClass:(id)obj forProp:(NSString*)prop;

@end
