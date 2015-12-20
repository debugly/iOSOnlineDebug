//
//  HVTinyHTTPServer.m
//
//  Copyright (c) 2015 Damian Kolakowski. All rights reserved.
//

#import <assert.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <Foundation/NSURL.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#import "HVHTTPServer.h"

@implementation HVHTTPServer

+ (HVHTTPServer*) server
{
  return [[HVHTTPServer alloc] init];
}

- (id)init
{
  self = [super init];
  if (self) {
    handlers = [[NSMutableDictionary alloc] initWithCapacity:10];
    resourceHandlers = [[NSMutableArray alloc] initWithCapacity:2];
  }
  return self;
}

- (void)dealloc
{
    [self stop];
    handlers = nil;
    resourceHandlers = nil;
}

- (void)cleanSocket:(int)socket
{
  shutdown(socket, 2);
  close(socket);
}

- (NSData *)line:(int)socket
{
  NSMutableData *lineData = [[NSMutableData alloc] initWithCapacity:100];
  char buff[1];
  ssize_t r = 0;
  do {
    r = recv(socket, buff, 1, 0);
    if (r > 0 && buff[0] > '\r') {
      [lineData appendBytes:buff length:1];
    }
  } while (r > 0 && buff[0] != '\n');
  if (r == -1) {
    return nil;
  }
  return lineData;
}

- (NSDictionary *)queryParameters:(NSURL *)url
{
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:10];
  NSString *urlQuery = [url query];
  if (urlQuery) {
    NSArray *tokens = [urlQuery componentsSeparatedByString:@"&"];
    if (tokens) {
      for (int i = 0; i < [tokens count]; ++i) {
        NSString *parameter = [tokens objectAtIndex:i];
        if (parameter) {
          NSArray *paramTokens = [parameter componentsSeparatedByString:@"="];
          if ([paramTokens count] >= 2) {
            NSString *paramName = [paramTokens objectAtIndex:0];
            NSString *paramValue = [paramTokens objectAtIndex:1];
            if (paramValue && paramName) {
              NSString *escapedName = [paramName stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
              NSString *escapedValue = [paramValue stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
              if (escapedName && escapedValue) {
                [parameters setObject:escapedValue forKey:escapedName];
              }
            }
          }
        }
      }
    }
  }
  return parameters;
}

- (NSDictionary *)headers:(int)socket
{
  NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
  NSData *tmpLine = nil;

  do {
    tmpLine = [self line:socket];
    if (tmpLine) {
      NSUInteger lineLength = [tmpLine length];
      if (lineLength > 0) {
          NSString *tmpLineString = [[NSString alloc] initWithData:tmpLine encoding:NSASCIIStringEncoding];
        NSArray *headerTokens = [tmpLineString componentsSeparatedByString:@":"];
        if (headerTokens && [headerTokens count] >= 2) {
          NSString *headerName = [headerTokens objectAtIndex:0];
          NSString *headerValue = [headerTokens objectAtIndex:1];
          if (headerName && headerValue) {
            [headersDictionary setObject:headerValue forKey:headerName];
          }
        }
      }
      if (lineLength == 0) {
        break;
      }
    }
  } while (tmpLine);

  return headersDictionary;
}

- (void)handleClientConnection:(id)data
{
  NSArray *args = (NSArray *)data;

  NSString *address = [args objectAtIndex:0];
  int socket = [(NSNumber *)[args objectAtIndex:1] intValue];

    @autoreleasepool {
        NSData *httpInitLine = [self line:socket];
        if (httpInitLine) {
            NSString *httpInitLineString = [[NSString alloc] initWithData:httpInitLine encoding:NSASCIIStringEncoding];
            NSLog(@"REQUEST HTTP INIT LINE: %@", httpInitLineString);
            
//            GET / HTTP/1.1
            
            NSArray *initLineTokens = [httpInitLineString componentsSeparatedByString:@" "];
            
            NSString *requestMethod = nil;
            NSURL *requestUrl = nil;
            
            if ([initLineTokens count] >= 3) {
                requestMethod = [initLineTokens objectAtIndex:0];
                NSString *requestUrlString = [initLineTokens objectAtIndex:1];
                if (requestUrlString) {
                    requestUrl = [NSURL URLWithString:requestUrlString];
                }
            }
            
            NSDictionary *requestQueryParams = [self queryParameters:requestUrl];
            NSDictionary *requestHeaders = [self headers:socket];
            
            if (requestUrl) {
                NSString *relativePath = [requestUrl relativePath];
                if (relativePath) {
                    NSObject <HVRequestHandler> *handler = nil;
                    @synchronized (handlers) {
                        handler = [handlers objectForKey:relativePath];
                    }
                    if (handler) {
                        [handler handleRequest:relativePath withHeaders:requestHeaders query:requestQueryParams address:address onSocket:socket];
                    }else{
                        BOOL isHandled = NO;
                        for (NSObject <HVRequestHandler> *handler in resourceHandlers) {
                            if ([handler handleRequest:relativePath withHeaders:requestHeaders query:requestQueryParams address:address onSocket:socket]) {
                                isHandled = YES;
                                break;
                            }
                        }
                        if (!isHandled) {
                            NSLog(@"---没有返回的资源：%@",relativePath);
                        }
                    }
                }
            }
        }
        [self cleanSocket:socket];
    }
}

- (NSString *)sockaddrToNSString:(struct sockaddr *)addr
{
  char str[20];
  if (addr->sa_family == AF_INET) {
    struct sockaddr_in *v4 = (struct sockaddr_in *)addr;
    const char *result = inet_ntop(AF_INET, &(v4->sin_addr), str, 20);
    if (result == NULL) {
      return nil;
    }
  }
  if (addr->sa_family == AF_INET6) {
    struct sockaddr_in6 *v6 = (struct sockaddr_in6 *)addr;
    const char *result = inet_ntop(AF_INET6, &(v6->sin6_addr), str, 20);
    if (result == NULL) {
      return nil;
    }
  }
  return [NSString stringWithUTF8String:str];
}

- (void)acceptClientConnectionsLoop
{
    @autoreleasepool {
        while (!done) {
            struct sockaddr clientAddr;
            unsigned int addrLen = sizeof(clientAddr);
//            客户端connect();服务器监听到之后；调用accept接受连接；然后就可以开始网络I/O操作；
            const int clientSocket = accept(listenSocket, (struct sockaddr *)&clientAddr, &addrLen);
            if (clientSocket == -1) {
                done = YES;
            } else {
                int no_sig_pipe = 1;
                setsockopt(clientSocket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, sizeof no_sig_pipe);
                NSString *clientIpAddress = [self sockaddrToNSString:&clientAddr];
                NSArray *args = [NSArray arrayWithObjects:clientIpAddress, [NSNumber numberWithInt:clientSocket], nil];
                if (clientIpAddress) {
                    [self performSelectorInBackground:@selector(handleClientConnection:) withObject:args];
                }
            }
        }
        [self cleanSocket:listenSocket];
    }
}

- (void)registerHandler:(NSObject <HVRequestHandler> *)handler forUrl:(NSString *)url
{
  if (url && handler) {
    [handlers setValue:handler forKey:url];
  }
}

- (void)registerResourceHandler:(NSObject<HVRequestHandler> *)handler
{
    if(handler){
        [resourceHandlers addObject:handler];
    }
}

- (void)registerHandler:(NSObject <HVRequestHandler> *)handler forUrls:(NSArray *)urls
{
  if ( handler && urls ) {
    for ( NSString* url in urls ) {
      [self registerHandler:handler forUrl:url];
    }
  }
}

- (BOOL)start:(int)port
{
  listenPort = port;
  done = NO;
  struct sockaddr_in addr;
  memset(&addr, 0, sizeof addr);
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_port = htons(listenPort);
//    常用的协议族有，AF_INET、AF_INET6、AF_LOCAL（或称AF_UNIX，Unix域socket）、AF_ROUTE等等。协议族决定了socket的地址类型，在通信中必须采用对应的地址，如AF_INET决定了要用ipv4地址（32位的）与端口号（16位的）的组合、AF_UNIX决定了要用一个绝对路径名作为地址。
//    指定socket类型。常用的socket类型有，SOCK_STREAM、SOCK_DGRAM、SOCK_RAW、SOCK_PACKET、SOCK_SEQPACKET等等
//    当protocol为0时，会自动选择type类型对应的默认协议。
  listenSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (listenSocket == -1) {
    return NO;
  }
  int value = 1;
  if (setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(value)) == -1) {
    [self cleanSocket:listenSocket];
    return NO;
  }

  int no_sig_pipe = 1;
  setsockopt(listenSocket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, sizeof no_sig_pipe);

//    把一个ipv4或ipv6地址和端口号组合赋给socket
  if (bind(listenSocket, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
    [self cleanSocket:listenSocket];
    return NO;
  }
//    监听指定的socket地址
  if (listen(listenSocket, 150 /* max connections */) == -1) {
    [self cleanSocket:listenSocket];
    return NO;
  }

  [self performSelectorInBackground:@selector(acceptClientConnectionsLoop) withObject:nil];
  return YES;
}

- (void)stop
{
  done = YES;
  [self cleanSocket:listenSocket];
}

@end
