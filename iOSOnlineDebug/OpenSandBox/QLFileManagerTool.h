//
//  QLFileManagerTool.h
//  Secret
//
//  Created by qianlongxu on 15/11/27.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLFileManagerTool : NSObject

+ (BOOL)isFolder:(NSString *)path;

///指定路径下的item；结果是路径数组
+ (NSArray *)itemsForPath:(NSString *)path;
///指定路径下的item；结果是model数组
+ (NSArray *)modelsForPath:(NSString *)path;
///指定路径下的item；结果是json数组
+ (NSArray *)jsonModelsForPath:(NSString *)path;

+ (void)itemsForPath:(NSString *)path completion:(void(^)(NSArray *files,NSArray *folders))comp;

///获取文件和文件夹
+ (void)asyncItemsForPath:(NSString *)path completion:(void(^)(NSArray *files,NSArray *folders))comp;


@end
