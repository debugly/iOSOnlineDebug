//
//  QLHTMLFileHandler.h
//  Secret
//
//  Created by qianlongxu on 15/12/3.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "HVBaseRequestHandler.h"

@interface QLHTMLFileHandler : HVBaseRequestHandler

+ (instancetype)handler:(NSString*)html;

@end
