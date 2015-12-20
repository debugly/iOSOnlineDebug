//
//  HVTinyHTTPServer.h
//
//  Copyright (c) 2015 Damian Kolakowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HVRequestHandler <NSObject>
@required

- (BOOL)handleRequest:(NSString *)url withHeaders:(NSDictionary *)headers query:(NSDictionary *)query address:(NSString *)address onSocket:(int)socket;

@end

@interface HVHTTPServer : NSObject {
  int listenPort;
  int listenSocket;
  BOOL done;
  NSMutableDictionary *handlers;
  NSMutableArray *resourceHandlers;
}

+ (HVHTTPServer*) server;

- (void)registerHandler:(NSObject <HVRequestHandler> *)handler forUrl:(NSString *)url;
- (void)registerResourceHandler:(NSObject <HVRequestHandler> *)handler;

- (void)registerHandler:(NSObject <HVRequestHandler> *)handler forUrls:(NSArray *)urls;

- (BOOL)start:(int)port;

- (void)stop;

@end
