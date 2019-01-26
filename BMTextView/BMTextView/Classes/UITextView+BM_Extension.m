//
//  UITextView+BM_Extension.m
//  BMTextView
//
//  Created by Jashion on 2019/1/25.
//  Copyright © 2019 BMu. All rights reserved.
//

#import "UITextView+BM_Extension.h"
#import <objc/runtime.h>

@implementation BMTextLinkModel

@end

@implementation UITextView (BM_Extension)

#pragma mark - Public methods
- (void)resetDefaultConfig {
    self.editable = NO;
    self.selectable = NO;
    self.textContainer.lineFragmentPadding = 0;
    self.textContainerInset = UIEdgeInsetsZero;
    self.contentInset = UIEdgeInsetsZero;
    self.dataDetectorTypes = UIDataDetectorTypeLink;
}

- (void)adjustWebText {
    self.webLinks = @[].mutableCopy;
    self.adjustSize = CGSizeZero;
    
    if (!self.attributedText.string) {
        return;
    }
    
    //get real width value
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if (self.frame.size.width > 0) {
        width = self.frame.size.width;
    }
    width = width - self.contentInset.left - self.contentInset.right - self.textContainerInset.left - self.textContainerInset.right;
    
    //start calculate
    NSAttributedString *attrStr = self.attributedText;
    [attrStr enumerateAttributesInRange: NSMakeRange(0, attrStr.length) options: NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        //adjust attachment size
        if ([attrs.allKeys containsObject: @"NSAttachment"]) {
            NSTextAttachment *attachment = attrs[@"NSAttachment"];
            CGRect bounds = attachment.bounds;
            NSParagraphStyle *paragraph = attrs[@"NSParagraphStyle"];
            CGFloat attachmentWidth = width-paragraph.headIndent;
            if (bounds.size.width > attachmentWidth) {
                CGFloat ratio = bounds.size.height/bounds.size.width;
                CGFloat height = roundf(ratio*attachmentWidth);
                bounds.size.width = attachmentWidth;
                bounds.size.height = height;
                attachment.bounds = bounds;
            }
        }
        //get text link url and range
        if ([attrs.allKeys containsObject: @"NSLink"]) {
            BMTextLinkModel *sdTextLink = [BMTextLinkModel new];
            id url = attrs[@"NSLink"];
            if ([url isKindOfClass: [NSURL class]]) {
                sdTextLink.urlStr = ((NSURL *)url).absoluteString;
            } else if ([url isKindOfClass: [NSString class]]) {
                sdTextLink.urlStr = url;
            }
            sdTextLink.range = range;
            [self.webLinks addObject: sdTextLink];
        }
    }];
    //reset attributedText
    self.attributedText = nil;
    self.attributedText = attrStr;
    
    NSLayoutManager *layoutManager = self.layoutManager;
    [layoutManager ensureLayoutForTextContainer: self.textContainer];
    
    //calculate link text rect
    for (BMTextLinkModel *model in self.webLinks) {
        model.rect = [layoutManager boundingRectForGlyphRange: model.range inTextContainer: self.textContainer];
//        //Text link rect
//        CAShapeLayer *layer = [CAShapeLayer layer];
//        layer.frame = model.rect;
//        layer.path = CGPathCreateWithRect((CGRect){CGPointZero, model.rect.size}, NULL);
//        layer.strokeColor = [UIColor redColor].CGColor;
//        layer.fillColor = [UIColor clearColor].CGColor;
//        layer.backgroundColor = [UIColor clearColor].CGColor;
//        layer.borderWidth = 1;
//        [self.layer addSublayer: layer];
    }
    
    //calculate text size
    CGSize size = [self.attributedText boundingRectWithSize: CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context: nil].size;
    self.adjustSize = CGSizeMake(ceilf(width + self.contentInset.left + self.contentInset.right + self.textContainerInset.left + self.textContainerInset.right), ceilf(size.height + self.textContainer.lineFragmentPadding*2+self.contentInset.top+self.contentInset.bottom+self.textContainerInset.top+self.textContainerInset.bottom));
    
    //add tap event
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(sd_handleTapGesture:)];
    [self addGestureRecognizer: tap];
}

#pragma mark - Event response
- (void)sd_handleTapGesture: (UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView: tapGesture.view];
    for (BMTextLinkModel *model in self.webLinks) {
        if (CGRectContainsPoint(model.rect, point) && self.tapLinkBlock) {
            self.tapLinkBlock(model.urlStr);
        }
    }
}

#pragma mark - Setter and Getter methods
- (NSMutableArray<BMTextLinkModel *> *)webLinks {
    return objc_getAssociatedObject(self, @selector(webLinks));
}

- (void)setWebLinks:(NSMutableArray<BMTextLinkModel *> *)webLinks {
    objc_setAssociatedObject(self, @selector(webLinks), webLinks, OBJC_ASSOCIATION_RETAIN);
}

- (CGSize)adjustSize {
    return CGSizeFromString(objc_getAssociatedObject(self, @selector(adjustSize)));
}

- (void)setAdjustSize:(CGSize)adjustSize {
    objc_setAssociatedObject(self, @selector(adjustSize), NSStringFromCGSize(adjustSize), OBJC_ASSOCIATION_RETAIN);
}

- (TextLinkBlock)tapLinkBlock {
    return objc_getAssociatedObject(self, @selector(tapLinkBlock));
}

- (void)setTapLinkBlock:(TextLinkBlock)tapLinkBlock {
    objc_setAssociatedObject(self, @selector(tapLinkBlock), tapLinkBlock, OBJC_ASSOCIATION_COPY);
}

@end
