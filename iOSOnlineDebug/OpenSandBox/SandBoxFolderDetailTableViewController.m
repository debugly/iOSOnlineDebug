//
//  SandBoxFolderDetailTableViewController.m
//  Secret
//
//  Created by qianlongxu on 15/11/27.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "SandBoxFolderDetailTableViewController.h"
#import "SandBoxCommHeader.h"

typedef NS_ENUM(NSUInteger, DetailSections) {
    DetailSection_Files,
    DetailSection_Folders,
    DetailSectionCount,
};

@interface SandBoxFolderDetailTableViewController()

@property (nonatomic, strong) NSArray *subFiles;
@property (nonatomic, strong) NSArray *subFolders;

@end

@implementation SandBoxFolderDetailTableViewController

- (void)setContentModel:(FileItemModel *)contentModel{
    if (_contentModel != contentModel) {
        _contentModel = contentModel;
        self.subFiles = contentModel.subFiles;
        self.subFolders = contentModel.subFolder;
        [self reloadContent];
    }
}

- (void)reloadContent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSArray *models = self.contentModel.subFolder;
        for (FileItemModel *model in models) {
            
            [QLFileManagerTool itemsForPath:model.absPath completion:^(NSArray *files, NSArray *folders) {
                model.subFiles = [FileItemModel fileItemsWithPathArr:files];
                model.subFolder = [FileItemModel fileItemsWithPathArr:folders];
            }];
        }
        
        if(self.isViewLoaded && self.view.window){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:DetailSection_Folders] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
    });

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DetailSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case DetailSection_Files:
            return self.subFiles.count;
        case DetailSection_Folders:
            return self.subFolders.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case DetailSection_Files:
            return @"所有文件";
        case DetailSection_Folders:
            return @"所有子目录";
        default:
            return nil;
    }
}

- (FileItemModel *)modelForIndexPath:(NSIndexPath *)idx
{
    if (DetailSection_Files == idx.section) {
        return self.subFiles[idx.row];
    }else if (DetailSection_Folders == idx.section){
        return [self.subFolders objectAtIndex:idx.row];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    }
    
    FileItemModel *model = [self modelForIndexPath:indexPath];
    cell.textLabel.text = model.title;
    
    cell.detailTextLabel.text = [model formatterInfo];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileItemModel *model = [self modelForIndexPath:indexPath];
    
    if ([QLFileManagerTool isFolder:model.absPath]) {
        SandBoxFolderDetailTableViewController *vc = [SandBoxFolderDetailTableViewController new];
        vc.contentModel = model;
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}

@end
