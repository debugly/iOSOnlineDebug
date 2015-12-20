//
//  QLSandboxRequestHandler.m
//  QLSandboxHierarchy
//
//  Created by qianlongxu on 15/12/2.
//  Copyright © 2015年 qianlongxu. All rights reserved.
//

#import "QLSandboxRequestHandler.h"
#import "SandBoxCommHeader.h"
#import <UIKit/UIKit.h>

@implementation QLSandboxRequestHandler

- (BOOL)handleRequest:(NSString *)url withHeaders:(NSDictionary *)headers query:(NSDictionary *)query address:(NSString *)address onSocket:(int)socket
{
    if ([url containsString:@"sandboxResource"]){
        NSString* path = [query objectForKey:@"path"];
        path = [ApplicationHomePath() stringByAppendingPathComponent:path];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSLog(@"--path-%@",path);
        
        NSString *fileName = [path lastPathComponent];
        NSString *respHeader = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Disposition:attachment;filename=%@\r\n",fileName];
        
        if([self writeText:respHeader toSocket:socket]){
            return [self writeData:data toSocket:socket];
        }
    }
    
    if ([super handleRequest:url withHeaders:headers query:query address:address onSocket:socket]) {
        if ([url containsString:@"sandboxDeviceName"]) {
            NSString *name = [[UIDevice currentDevice]name];
            NSString *model = [[UIDevice currentDevice]model];
            NSString *systemVersion = [[UIDevice currentDevice]systemVersion];
            NSString *text = [NSString stringWithFormat:@"%@-%@-%@",name,model,systemVersion];
            return [self writeJSONResponse:@{@"device":text} toSocket:socket];
        }else{
            if ( query && [query count] > 0 ) {
                return [self handleFetchRequest:socket query:query];
            } else {
                return [self handleSchemeRequest:socket];
            }
        }
    }
    return NO;
}

- (BOOL) handleSchemeRequest:(int)socket
{
    NSArray *homeSubItems = [QLFileManagerTool modelsForPath:ApplicationHomePath()];
    
    return [self writeJSONResponse:homeSubItems toSocket:socket];
}

- (BOOL) handleFetchRequest:(int)socket query:(NSDictionary *)query
{
    NSString* path = [query objectForKey:@"path"];
    if(!path)return NO;
    
    path = [ApplicationHomePath() stringByAppendingPathComponent:path];
    NSArray *homeSubPaths = [QLFileManagerTool jsonModelsForPath:path];
    return [self writeJSONResponse:homeSubPaths toSocket:socket];
}

@end
