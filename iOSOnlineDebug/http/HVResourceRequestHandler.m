//
//  HVResourceRequestHandler.m
//  Secret
//
//  Created by qianlongxu on 15/12/3.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "HVResourceRequestHandler.h"
#import "SandBoxCommHeader.h"

@implementation HVResourceRequestHandler

- (BOOL)handleRequest:(NSString *)url withHeaders:(NSDictionary *)headers query:(NSDictionary *)query address:(NSString *)address onSocket:(int)socket
{
    NSString *path = OnlineDebugBundleSource_Path(url); //[[NSBundle mainBundle]pathForResource:[url stringByDeletingPathExtension] ofType:[url pathExtension]];
    if ([super handleRequest:url withHeaders:headers query:query address:address onSocket:socket]) {
        if(path){
            NSData *cachedResp = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:NULL];
            return [self writeData:cachedResp toSocket:socket];
        }else{
            return [self writeJSONErrorResponse:@"404" toSocket:socket];
        }
    }
    return NO;
}

@end
