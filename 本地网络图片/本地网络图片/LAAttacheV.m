//
//  LAAttacheV.m
//  本地网络图片
//
//  Created by xuzhiyong on 2020/3/2.
//  Copyright © 2020 xxx. All rights reserved.
//

#import "LAAttacheV.h"
#import "UIView+MJExtension.h"
#import "UIImageView+WebCache.h"

@interface LAAttacheV ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *closeImgV;

@end

@implementation LAAttacheV

- (void)layoutSubviews {
    [super layoutSubviews];
    self.closeImgV.mj_w = 15;
    self.closeImgV.mj_h = 15;
    self.closeImgV.mj_y = 0;
    self.closeImgV.mj_x = self.mj_w - self.closeImgV.mj_w;
    
    self.imageView.mj_w = self.mj_w-8;
    self.imageView.mj_h = self.mj_h-8;
    self.imageView.mj_y = 8;
    self.imageView.mj_x = 0;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.closeImgV];
        
        [self setupUserAction];
    }
    return self;
}

- (void)setupUserAction {
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapA)];
    [self.imageView addGestureRecognizer:imgTap];
    
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTapA)];
    [self.closeImgV addGestureRecognizer:closeTap];
}
- (void)imgTapA {
    if (self.delegate && [self.delegate respondsToSelector:@selector(attacheV:didClickImageV:)]) {
        [self.delegate attacheV:self didClickImageV:self.model];
    }
}
- (void)closeTapA {
    if (self.delegate && [self.delegate respondsToSelector:@selector(attacheV:didClickCloseV:)]) {
        [self.delegate attacheV:self didClickCloseV:self.model];
    }
}

- (void)setModel:(LAImageModel *)model {
    _model = model;
    
    id image = model.image;
    if ([image isKindOfClass:[UIImage class]]){//UIImage
        self.imageView.image = image;
    } else {//NSString
        if ([image hasPrefix:@"https"]||
            [image hasPrefix:@"http"]) {
            NSURL *URL = [NSURL URLWithString:image];
            UIImage *placeholder = [UIImage imageNamed:@"la_placeholder"];
            [self.imageView sd_setImageWithURL:URL placeholderImage:placeholder];
        } else {
            self.imageView.image = [UIImage imageNamed:image];
        }
    }
    self.closeImgV.hidden = !model.editor;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}
- (UIImageView *)closeImgV {
    if (_closeImgV == nil) {
        _closeImgV = [[UIImageView alloc] init];
        _closeImgV.image = [UIImage imageNamed:@"close"];
        _closeImgV.userInteractionEnabled = YES;
    }
    return _closeImgV;
}
@end
