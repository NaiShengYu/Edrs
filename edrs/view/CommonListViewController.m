//
//  CommonListViewController.m
//  edrs
//
//  Created by 余文君, July on 15/10/2.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "CommonListViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "CustomeSearchView.h"

@interface CommonListViewController ()
@property (nonatomic,assign)NSInteger page;//当前页数
@property (nonatomic,assign)NSInteger num;//一共多少条数据
@property (nonatomic,copy)NSString * searchKey;
@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation CommonListViewController

- (UITableView *)myTable
{
    if (!_myTable){
        _myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _myTable.delegate =self;
        _myTable.dataSource =self;
        [_myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        if(@available(iOS 11.0, *)){
            _myTable.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentNever;
            _myTable.estimatedRowHeight = 0;
            _myTable.estimatedSectionHeaderHeight = 0;
            _myTable.estimatedSectionFooterHeight = 0;
        }
        WS(blockSelf);
        MJRefreshBackNormalFooter *footer =[MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [blockSelf AddMoreMassage];
        }];
        _myTable.footer =footer;
        
    }
    return _myTable;
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.view endEditing:YES];
    [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupLeftMenuButton];
  
    //模拟数据
    //mChemicalList = [[NSMutableArray alloc]initWithArray:[CustomHttp getDataFromFile:@"chemicals"]];

    
    //初始化数据
     if ([self.listType isEqualToString:@"Chemical"]) {
        self.title = @"化学品列表";
     }else{
        self.title = @"污染源列表";
     }
    //获取数据，设置上拉加载
    
    [self.view addSubview:self.myTable];

    //去掉空白
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.page =0;
    self.dataArray =[[NSMutableArray alloc]init];
    WS(blockSelf);
    [self.myTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(blockSelf.view).insets =UIEdgeInsetsMake(14, 0, 0, 0);
    }];
    self.searchKey = @"";
    [self makeDataWithFirst:YES];
    [self creatSearchView];
    
}
- (void)creatSearchView{
    CustomeSearchView *searchView =[[CustomeSearchView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
    
    [self.view addSubview:searchView];
    
    searchView.backgroundColor =[UIColor whiteColor];
    searchView.delegate =self;
    searchView.contentInset =UIEdgeInsetsMake(5, 15, 5, 15);
    for (UIView *subView in searchView.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            for (int i =0; i <subView.subviews.count; i ++) {
                if ([subView.subviews[i] isKindOfClass:[UITextField class]]) {
                    UITextField *TX = subView.subviews[i];
                    TX.placeholder =@"关键字搜索";
                    TX.font =FontSize(19);
                    UIImageView *imgV =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25,25)];
                    imgV.image =[UIImage imageNamed:@"search"];
                    TX.leftView =imgV;
                }
            }
        }
    }
    
}

//发送搜索请求
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"] &&searchBar.returnKeyType ==UIReturnKeySearch){
        DMLog(@"搜索");
        [self makeDataWithFirst:YES];
        [self.view endEditing:YES];
        
        //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    DMLog(@"调用了");
    self.searchKey =searchText;
    if ([searchText  isEqual:@""]) {
        [self makeDataWithFirst:YES];
    }
}

- (void)AddMoreMassage{
    if (self.num ==0) {
        [self makeDataWithFirst:YES];
    }else{
        if (self.num <=self.dataArray.count) {
            [self.myTable.footer endRefreshingWithNoMoreData];
        }else{
            
            [self makeDataWithFirst:NO];
        }
        
    }
    
}

- (void)makeDataWithFirst:(BOOL) isFirst{
    
    if (isFirst ==YES) {
        self.page =0;
    }else self.page +=1;
    WS(blockSelf);
    //获取数据
    NSString *url = [NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETPOLLUTION_ALL];
    if ([self.listType isEqualToString:@"Chemical"]) {
        url = [NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETCHEMICAL_PAGE];
    }
            [CustomHttp httpPost:url
                          params:@{@"searchKey":self.searchKey, @"pageIndex": [NSString stringWithFormat:@"%ld",(long)self.page]}
                         success:^(id responseObj) {
                             NSLog(@"get chemical search result list successfully , response = %@", responseObj);
                             NSArray *Items = [responseObj valueForKey:@"Items"];
                             blockSelf.num =[[responseObj valueForKey:@"Totals"] integerValue];
                             if (isFirst==YES) {
                                 [blockSelf.dataArray removeAllObjects];
                             }
                             for (int i = 0 ; i < [Items count]; i++) {
                                 [blockSelf.dataArray addObject:Items[i]];
                             }
                             if (blockSelf.num <= blockSelf.dataArray.count) {
                                 [self.myTable.footer endRefreshingWithNoMoreData];
                             }
                             else{
                                 [self.myTable.footer endRefreshing];
                             }
                             [self.myTable reloadData];
                             [self.view endEditing:YES];
                         } failure:^(NSError *err) {
                             NSLog(@"fail to get chemical search result list, error = %@", err);
                         }];

}

#pragma mark - show detail
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([self.listType isEqualToString:@"Chemical"]) {
        if ([segue.identifier isEqualToString:@"ChemicalDetailSegue"]) {
            ChemicalDetailViewController *targetVC = segue.destinationViewController;
            targetVC.cid = sender;
        }
    }
    
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text =self.dataArray[indexPath.row][@"name"];

    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tmpid = self.dataArray[indexPath.row][@"id"];
    if ([self.listType isEqualToString:@"Chemical"]) {
        [self performSegueWithIdentifier:@"ChemicalDetailSegue" sender:tmpid];
    }
    else{
        UIStoryboard *stroy = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        PollutionDetailViewController *detail =[stroy instantiateViewControllerWithIdentifier:@"PollutionDetailViewController"];
        detail.pid = tmpid;
        [self.navigationController pushViewController:detail animated:YES];
    }
}


@end
