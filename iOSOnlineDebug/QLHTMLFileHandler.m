//
//  QLHTMLFileHandler.m
//  Secret
//
//  Created by qianlongxu on 15/12/3.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "QLHTMLFileHandler.h"
#import "SandBoxCommHeader.h"

@implementation QLHTMLFileHandler
{
    NSString *html;
    NSData *cachedResp;
}

+ (instancetype)handler:(NSString *)html
{
    return [[self alloc]initWithHtml:html];
}

- (instancetype)initWithHtml:(NSString *)ahtml
{
    self = [super init];
    if (self) {
        html = ahtml;
    }
    return self;
}

- (BOOL)handleRequest:(NSString *)url withHeaders:(NSDictionary *)headers query:(NSDictionary *)query address:(NSString *)address onSocket:(int)socket
{
    if (!cachedResp) {
        NSString *path = OnlineDebugBundleSource_Path(html); //[[NSBundle mainBundle]pathForResource:[html stringByDeletingPathExtension] ofType:[html pathExtension]];
        cachedResp = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:NULL];
    }
    
    if ([super handleRequest:url withHeaders:headers query:query address:address onSocket:socket]) {
        return [self writeData:cachedResp toSocket:socket];
    }
    return NO;
}

@end
