//
//  HVBaseRequestHandler.h
//
//  Copyright (c) 2015 Damian Kolakowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HVHTTPServer.h"

@interface HVBaseRequestHandler : NSObject <HVRequestHandler>

+ (instancetype)handler;

- (BOOL)writeData:(NSData*)data toSocket:(int)socket;

- (BOOL)writeJSONResponse:(id)object toSocket:(int)socket;

- (BOOL)writeJSONErrorResponse:(NSString*)error toSocket:(int)socket;

- (BOOL)writeText:(NSString *)text toSocket:(int)socket;

@end
