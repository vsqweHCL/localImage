//
//  LAHttpModel.m
//  本地网络图片
//
//  Created by xuzhiyong on 2020/3/2.
//  Copyright © 2020 xxx. All rights reserved.
//

#import "LAHttpModel.h"

@implementation LAHttpModel

- (NSMutableArray *)totalM {
    if (_totalM == nil) {
        _totalM = [NSMutableArray array];
    }
    return _totalM;
}

@end
