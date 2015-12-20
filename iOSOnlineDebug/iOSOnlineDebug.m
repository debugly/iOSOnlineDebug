//
//  iOSOnlineDebug.m
//  iOSOnlineDebug
//
//  Created by xuqianlong on 15/12/19.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "iOSOnlineDebug.h"
#import "HVHTTPServer.h"
#import "QLSandboxRequestHandler.h"
#import "QLHTMLFileHandler.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "HVBase64StaticFile.h"
#import "HVResourceRequestHandler.h"
#import "HVHierarchyHandler.h"
#import "HVPreviewHandler.h"
#import "HVPropertyEditorHandler.h"

#define IOS_HIERARCHY_Sandbox_PORT 9449

@implementation iOSOnlineDebug

static HVHTTPServer *server = nil;

+ (void)logServiceAdresses
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSLog(@"#### QL Sandbox Hierarchy: %@ ####", @(IOS_HIERARCHY_Sandbox_PORT));
    if (getifaddrs(&interfaces) == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                NSLog(@"(%@): %@",
                      [NSString stringWithUTF8String:temp_addr->ifa_name],
                      [NSString stringWithFormat:@"http://%@:%d", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)], IOS_HIERARCHY_Sandbox_PORT]);
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    NSLog(@"#######################################");
    freeifaddrs(interfaces);
}


+ (BOOL)startService
{
    if (server) {
        return YES;
    }
    
    server = [HVHTTPServer server];
    
    [server registerHandler:[QLSandboxRequestHandler handler] forUrls:@[@"/sandboxDirectory",@"/sandboxDeviceName",@"/sandboxResource"]];
    [server registerHandler:[QLHTMLFileHandler handler:@"index.html"] forUrl:@"/"];
    [server registerHandler:[QLHTMLFileHandler handler:@"index_sandbox.html"] forUrl:@"/index_sandbox.html"];
    [server registerHandler:[QLHTMLFileHandler handler:@"index_viewer.html"] forUrl:@"/index_viewer.html"];
    [server registerResourceHandler:[HVResourceRequestHandler handler]];
    
    [server registerHandler:[HVHierarchyHandler handler] forUrl:@"/snapshot"];
    [server registerHandler:[HVPreviewHandler handler] forUrl:@"/preview"];
    [server registerHandler:[HVPropertyEditorHandler handler] forUrl:@"/update"];
    
    if ([server start:IOS_HIERARCHY_Sandbox_PORT]) {
        [self logServiceAdresses];
        return YES;
    }
    return NO;
}

+ (void)stopService
{
    if (server) {
        [server stop];
        server = nil;
    }
}

@end
