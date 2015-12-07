//
//  DVTableViewController.m
//  DVMobile
//
//  Created by pan Shiyu on 14/11/1.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import "BYTbVC.h"

@interface BYTbVC ()

@end

@implementation BYTbVC

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (id)initWithStyle:(UITableViewStyle)tableStyle
{
    self = [super init];
    self.tableStyle = tableStyle;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _items = [NSMutableArray array];
    //    [self.tableView addHeaderWithTarget:self action:@selector(refreshData)];
    //    [self.tableView addFooterWithTarget:self action:@selector(loadMore)];
}

- (void)setItems:(NSMutableArray*)items
{
    _items = items;
    [self.tableView reloadData];
}

- (UITableView*)tableView
{
    if (_tableView == nil) {
        _tableView = [UITableView tableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 20) delegete:self];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (_sections) {
        return _items.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sections) {
        NSArray* aSection = [_items objectAtIndex:section];
        return aSection.count;
    }
    return _items.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    BYTableItem* item = nil;
    if (_sections) {
        item = _items[indexPath.section][indexPath.row];
    }
    else {
        if (indexPath.row >= _items.count) {
            //这里为了解决在data被清空之后，系统去更新visibleCell的时候，直接调用cellForRowAtIndexPath数组越界的问题
            static NSString* tmpVisibleCellId = @"tmpVisibleCell";
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tmpVisibleCellId];
        }
        item = [_items objectAtIndex:indexPath.row];
    }

    BYTableCell* cell;
    if (item.cellClassName) {
        cell = [tableView dequeueReusableCellWithIdentifier:item.cellClassName];
        if (!cell) {
            cell = [[NSClassFromString(item.cellClassName) alloc] init];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:item.cellNibName];
        if (!cell) {
            UINib* nib = [UINib nibWithNibName:item.cellNibName bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:item.cellNibName];
            cell = [tableView dequeueReusableCellWithIdentifier:item.cellNibName];
        }
    }

    if (![cell isKindOfClass:[BYTableCell class]]) {
        BYLog(@"");
    }

    NSCAssert([cell isKindOfClass:[BYTableCell class]], @"cell 必须是 DVTableCell的子类");
    //for setitem method

    [cell setItem:item];
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_sections.count > section) {
        return _sections[section];
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    BYTableItem* item = nil;
    if (_sections) {
        item = _items[indexPath.section][indexPath.row];
    }
    else {
        if (indexPath.row >= _items.count) {
            return 0;
        }
        item = [_items objectAtIndex:indexPath.row];
    }
    if (item.cellHeightBlock) {
        return item.cellHeightBlock(item);
    }
    return item.cellHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

    BYTableItem* item = nil;
    if (_sections) {
        item = _items[indexPath.section][indexPath.row];
    }
    else {
        item = [_items objectAtIndex:indexPath.row];
    }

    // cellForRowAtIndexPath 已经保证了cell一定是DVTableCell 格式 ,so 强转之
    BYTableCell* selectedCell = (BYTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (item.tapBlock) {
        item.tapBlock(tableView, indexPath, item, selectedCell);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end

