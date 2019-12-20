//
//  ViewController.m
//  ModelSort
//
//  Created by 冯攀 on 2019/12/20.
//  Copyright © 2019 冯攀. All rights reserved.
//

#import "ViewController.h"
#import "MJExtension.h"
#import "DSD_JQBrandModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSArray *fileArray = (NSArray *)[self readLocalFileWithName:@"PX"];
    NSMutableArray *brandArray = [DSD_JQBrandModel mj_objectArrayWithKeyValuesArray:fileArray];
    
    NSMutableArray *hzArray = [NSMutableArray new];
    NSMutableArray *zmArray = [NSMutableArray new];
    
    for (DSD_JQBrandModel *obj in brandArray) {
        if ([self isChineseFirst:obj.brandname]) {
            [hzArray addObject:obj];
        }else{
            [zmArray addObject:obj];
        }
    }
    
    //汉字排序
    NSArray *resultArr = [hzArray sortedArrayUsingComparator:^NSComparisonResult(DSD_JQBrandModel  *obj1, DSD_JQBrandModel  *obj2) {
        NSString *str1 = [self transformPinyinWithchinese:obj1.brandname];
        NSString *str2 = [self transformPinyinWithchinese:obj2.brandname];
        return [str1 compare:str2];
    }];
    
    // 字母排序 排序key, 某个对象的属性名称，是否升序, YES-升序, NO-降序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"brandname" ascending:YES];
    NSArray *pxArray = [zmArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *hzCopyArray = [resultArr mutableCopy];
    NSMutableArray *zmCopyArray = [pxArray mutableCopy];
    
    [hzCopyArray addObjectsFromArray:zmCopyArray];
    
    for (DSD_JQBrandModel  *obj in hzCopyArray) {
        NSLog(@"obj = %@",obj.brandname);
    }
}

// 读取本地JSON文件
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

//中文转拼音
- (NSString *)transformPinyinWithchinese:(NSString *)chinese {
    
    NSMutableString *pinyin = [[NSMutableString alloc] initWithString:chinese];
    
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    return [pinyin uppercaseString];
    
}
//  判断是否以字母开头
- (BOOL)isEnglishFirst:(NSString *)str {
    NSString *regular = @"^[A-Za-z].+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    if ([predicate evaluateWithObject:str] == YES){
        return YES;
    }else{
        return NO;
    }
}
//  判断是否以汉字开头
- (BOOL)isChineseFirst:(NSString *)str {
    int utfCode = 0;
    void *buffer = &utfCode;
    NSRange range = NSMakeRange(0, 1);
    BOOL b = [str getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
    if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5)){
        return YES;
    }else{
        return NO;
    }
}


@end
