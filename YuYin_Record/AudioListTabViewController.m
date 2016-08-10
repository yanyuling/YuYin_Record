//
//  AudioListTabViewController.m
//  YuYin_Record
//
//  Created by yanyuling on 16/7/18.
//  Copyright © 2016年 yanyuling. All rights reserved.
//

#import "AudioListTabViewController.h"

@interface AudioListTabViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* myAudioTableView;
@property(nonatomic,strong)NSArray* myAudioArray;
@end

@implementation AudioListTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma TableView Delegate API
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   {
    
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    [headView setBackgroundColor:[UIColor grayColor]];
  
    return headView;
    
}
-(void)addQuestionBtnCallBck{
    NSLog(@"addQuestionBtnCallBck >>>");
    //应该弹出搜搜UI
}
-(void)searchTopicBtnCallBck{
    NSLog(@"searchTopicBtnCallBck >>>");
    //弹出添加问题UI
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *  cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageTableViewCell"];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] instanceCellWithStyle:UITableViewCellStyleDefault];
//    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置分区个数
    // 返回字典中的数据个数
    return 1;
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    // 设置每个分区的区头标题
//    // 返回字典中对应地方的  key  值
//
//}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    // 设置索引标题
//    // 返回字典中所有 key 值组成的数组
//
//}

//   自定义设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  70 ;
}

//  提交编辑样式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //  点击删除的时候，删除联系人，然后删除cell
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return  YES ;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return sourceIndexPath;
    //
}
/***************/
//实现点击一个 cell 进入详情页面
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    HomePageDetailViewController* detailPage = [[HomePageDetailViewController alloc] init];
//    [ self.navigationController pushViewController:detailPage  animated:YES ] ;
}



#pragma getter and setter
-(NSArray*)myAudioArray{
    if (_myAudioArray == nil) {
        _myAudioArray = [NSArray array];
    }
    return _myAudioArray;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
