//
//  CheckBoxViewController.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/23.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "CheckBoxViewController.h"
#import "SelectDataModel.h"
#import "NewAnalysistypeViewController.h"
@interface CheckBoxViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *selectArray ;
}

@end

@implementation CheckBoxViewController

-(void)dissmiss{
    if(!_fullScreen){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void)cancelButtonClicked:(id)sender{
    [self dissmiss];
}

-(void)submitButtonClicked:(id)sender{
    [self.delegate checkBoxSelect:selectArray];
    [self dissmiss];
   
}

-(void)addNewButtonAction:(id)sender{
    NewAnalysistypeViewController *newVC = [[NewAnalysistypeViewController alloc]init];
    [self.navigationController pushViewController:newVC animated:YES];
}


#pragma mark UIView

-(UIView *)footView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-40, 60)];
    UIButton *cancleBT = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, (SCREEN_WIDTH-100)/2, 36)];
    [cancleBT setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBT setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancleBT addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancleBT];
   
    
    UIButton *submitBT = [[UIButton alloc]initWithFrame:CGRectMake(40+(SCREEN_WIDTH-100)/2, 20, (SCREEN_WIDTH-100)/2, 36)];
    [submitBT setTitle:@"确定" forState:UIControlStateNormal];
    [submitBT setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [submitBT addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:submitBT];
    
    return view;
}

-(UIView *)footAddView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, 40)];
    [button setBackgroundColor:LIGHT_BLUE];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"新 增" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addNewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
}

-(UITableView *)tableView{
    if(_tableView == nil){
        
        if(_fullScreen){
            _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT-64)];
        }else{
            NSInteger height = self.dataArray.count*46+100 ;
            if(height > SCREEN_HEIGHT-200 ){
                height = SCREEN_HEIGHT-200 ;
            }
            _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH-40,height) style:UITableViewStyleGrouped];
            _tableView.center = CGPointMake(self.view.centerX, self.view.centerY-20);
             _tableView.layer.cornerRadius = 10;
        }
       
        
        _tableView.delegate = self ;
        _tableView.dataSource = self ;
       
        if(!_fullScreen){
            _tableView.tableFooterView = [self footView];
        }else{
            _tableView.tableFooterView =[self footAddView];
        }
    }
    
    return _tableView;
}

-(void)configuerNavigationLeftItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)configuerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [[UIButton alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:button];
    self.view.backgroundColor = RGBACOLOR(87, 87, 87, 0.3);
    [self.view addSubview:self.tableView];

    selectArray = [[NSArray alloc]initWithArray:self.dataArray copyItems:YES];
    if(_fullScreen){
        self.title = _titleName;
        [self configuerNavigationRightItem];
        [self configuerNavigationLeftItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return selectArray.count ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell className]];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell className]];
    }
    SelectDataModel *model =[selectArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = model.name;
    if(model.state){
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
     SelectDataModel *model =[selectArray objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(model.state){
        model.state = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        model.state = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _titleName ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    return [self footView];
//}


@end
