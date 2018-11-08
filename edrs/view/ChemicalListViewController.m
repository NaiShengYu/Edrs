//
//  ChemicalListViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "ChemicalListViewController.h"

@interface ChemicalListViewController ()

@end

@implementation ChemicalListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mPageSize = 20;
    mPageIndex = 0;
    
    //模拟数据
    //mChemicalList = [[NSMutableArray alloc]initWithArray:[CustomHttp getDataFromFile:@"chemicals"]];
    mChemicalList = [[NSMutableArray alloc]init];
    mSearchResultList = [[NSMutableArray alloc]init];
    
    //初始化数据
    [self getChemicalListDataLength];
    [self getChemicalListData];
    
    //获取数据，设置上拉加载
    [self.chemicalListTableView addPullToRefreshWithActionHandler:^{
        if (mPageIndex < ceil((float)mCount/mPageSize) - 1) {
            mPageIndex ++;
            [self getChemicalListData];
        }
    } position:SVPullToRefreshPositionBottom];
    
    //去掉空白
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"dealloc");
}

-(void)getChemicalListDataLength{
    //获取总量，对于翻页之类的处理
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETCHEMICAL_LENGTH] params:@{} success:^(id responseObj) {
        NSLog(@"get chemical list length successfully , response = %@", responseObj);
        mCount = [responseObj[@"length"] intValue];
        if (mPageIndex >= ceil((float)mCount/mPageSize) - 1) {
            [self.chemicalListTableView setShowsPullToRefresh:NO];  //总量小于显示量
        }
    } failure:^(NSError *err) {
        NSLog(@"fail to get chemical list, error = %@", err);
    }];
}
-(void)getChemicalListData{
    //获取数据
    NSString *keyword = self.chemicalListSearchBar.text;
    
    if (keyword.length > 0) {
        NSLog(@"print search list");
        [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETCHEMICAL_SEARCH]
                      params:@{@"searchkey":keyword, @"page": [NSString stringWithFormat:@"%d",mPageIndex], @"stationid":[CustomAccount sharedCustomAccount].user.stationId}
                     success:^(id responseObj) {
                         NSLog(@"get chemical search result list successfully , response = %@", responseObj);
                         for (int i = 0 ; i < [responseObj count]; i++) {
                             [mChemicalList addObject:responseObj[i]];
                         }
                         
                         if (mPageIndex >= ceil((float)mCount/mPageSize -1)) {
                             [self.chemicalListTableView setShowsPullToRefresh:NO];
                         }
                         else{
                             [self.chemicalListTableView setShowsPullToRefresh:YES];
                         }
                         
                         [self.chemicalListTableView reloadData];
                         [self.chemicalListTableView.pullToRefreshView stopAnimating];
                         [self.chemicalListSearchBar setShowsCancelButton:NO animated:YES];
                         [self.view endEditing:YES];
                     } failure:^(NSError *err) {
                         NSLog(@"fail to get chemical search result list, error = %@", err);
                     }];
    }
    else{
        NSLog(@"print all list");
        [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_GETCHEMICAL_PAGE] params:@{@"page":[NSString stringWithFormat:@"%d",mPageIndex]} success:^(id responseObj) {
            NSLog(@"get ChemicalList successfully, response = %@", responseObj);
            for (int i = 0 ; i < [responseObj count]; i++) {
                [mChemicalList addObject:responseObj[i]];
            }
            
            if (mPageIndex >= ceil((float)mCount/mPageSize -1)) {
                [self.chemicalListTableView setShowsPullToRefresh:NO];
            }
            else{
                [self.chemicalListTableView setShowsPullToRefresh:YES];
            }
            
            [self.chemicalListTableView reloadData];
            [self.chemicalListTableView.pullToRefreshView stopAnimating];
        } failure:^(NSError *err) {
            NSLog(@"fail to get chemical list , err = %@",err);
        }];
    }
}

#pragma mark - show detail
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ChemicalDetailSegue"]) {
        ChemicalDetailViewController *targetVC = segue.destinationViewController;
        targetVC.cid = sender;
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return  [mSearchResultList count];
    }
    else{
        return [mChemicalList count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"ChemicalListTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [cell.textLabel setText:mSearchResultList[indexPath.row][@"name"]];
    }
    else{
        [cell.textLabel setText:mChemicalList[indexPath.row][@"name"]];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cid = mChemicalList[indexPath.row][@"id"];
    [self performSegueWithIdentifier:@"ChemicalDetailSegue" sender:cid];
}



#pragma mark - searchbar and searchdisplay
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"search begin");
    [self.chemicalListSearchBar setShowsCancelButton:YES animated:YES];
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    NSLog(@"search end");
    return YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.chemicalListSearchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
}
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *keyword = [self.chemicalListSearchBar text];
    //搜索，初始化当前索引值和表
    mPageIndex = 0;
    [mChemicalList removeAllObjects];
    
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETCHEMICAL_SEARCHLENGTH]
                  params:@{@"searchkey":keyword, @"stationid": [CustomAccount sharedCustomAccount].user.stationId}
                 success:^(id responseObj) {
                     NSLog(@"get chemical search list length successfully ,response = %@", responseObj);
                     mCount = [responseObj[@"length"] intValue];
                     if (mPageIndex >= ceil((float)mCount/mPageSize) - 1) {
                         [self.chemicalListTableView setShowsPullToRefresh:NO];  //总量小于显示量
                     }
                     else{
                         [self.chemicalListTableView setShowsPullToRefresh:YES];
                     }
                 } failure:^(NSError *err) {
                     NSLog(@"fail to get chemical search result list length, error = %@", err);
                     
                 }];
    
    [self getChemicalListData];
    
}


//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
//    //searchDisplayController～
//    
//    return YES;
//}

@end
