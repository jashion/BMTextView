//
//  UITextView+BM_Extension.h
//  BMTextView
//
//  Created by Jashion on 2019/1/25.
//  Copyright © 2019 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMTextLinkModel : NSObject

@property (nonatomic, assign) NSRange range;  ///< link text range of the page.
@property (nonatomic, strong) NSString *urlStr;  ///< link url string.
@property (nonatomic, assign) CGRect rect;  ///< link text rect in textView.

@end

typedef void(^TextLinkBlock)(NSString *str);

@interface UITextView (BM_Extension)

@property (nonatomic, strong) NSMutableArray<BMTextLinkModel *> *webLinks;  ///< 可点击url相关数据
@property (nonatomic, assign) CGSize adjustSize;  ///< 调整之后的size
@property (nonatomic, copy) TextLinkBlock tapLinkBlock;

/**
 set default configuration
 
 editable = NO
 selectable = NO
 textContainer.lineFragmentPadding = 0
 self.textContainerInset = UIEdgeInsetsZero
 self.dataDetectorTypes = UIDataDetectorTypeLink
 */
- (void)resetDefaultConfig;

/**
 在设置好UITextView所有属性，添加到父view之前调用
 */
- (void)adjustWebText;

@end

NS_ASSUME_NONNULL_END
