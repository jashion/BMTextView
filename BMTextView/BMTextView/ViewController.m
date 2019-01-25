//
//  ViewController.m
//  BMTextView
//
//  Created by Jashion on 2019/1/25.
//  Copyright © 2019 BMu. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import "UITextView+BM_Extension.h"

static NSString *content = @"<h1>这是卡的使用说明：</h1><ul><li>可以使用<a href=\"https://www.baidu.com\"><img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1548238742656&di=70c9c1f7474aeeb4fad4edb6017c2077&imgtype=0&src=http%3A%2F%2Fimg1.bimg.126.net%2Fphoto%2F5NRDLMIsjjE80OpZW6zPEg%3D%3D%2F5751941149082902765.jpg\"></a></li><li>不可以使用</li><li>随便使用</li><img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1548417223056&di=8e8835068c2608654f34e6ac2c6a9953&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F9f510fb30f2442a727bb28b8db43ad4bd1130272.jpg\"></ul></li></ul><a href=\"https://www.baidu.com\">百度一下就知道</a><img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1548417312629&di=8d7d0f5b75fe93088af701af6d693097&imgtype=0&src=http%3A%2F%2Fyouimg1.c-ctrip.com%2Ftarget%2Ffd%2Ftg%2Fg4%2FM09%2F44%2F10%2FCggYHlXjKeCARKeGAB3MbOS0fas725.jpg\">";

static NSString *str = @"<h1>这是卡的使用说明：</h1><ul><li>可以使用<img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1548063097688&di=eac25f31ebafe6b17a1c73db54c43075&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01f6d058d9d6c0a801219c77562fcf.png%401280w_1l_2o_100sh.png\" width=\"30\" height=\"30\"></li><li>不可以使用<img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1548063129789&di=c104bf34f86e35dd892ea4c2f822dca2&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01851855f282cf6ac7251df8d15ea0.png%401280w_1l_2o_100sh.png\" width=\"30\" height=\"30\"></li><li>随便使用<img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1548063271927&di=645b217eddc5932477374e2e41c57f64&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F011a53565330296ac7251c94c7ced9.png%401280w_1l_2o_100sh.png\" width=\"30\" height=\"30\"></li></ul><a href=\"https://www.baidu.com\">百度一下就知道</a><a href=\"https://www.google.com\">Google一下就知道</a>";

@interface ViewController ()<UITextViewDelegate, WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *control;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView1;
@property (nonatomic, strong) UITextView *textView2;

@property (nonatomic, strong) NSMutableAttributedString *attributedStr;
@property (nonatomic, strong) NSMutableAttributedString *labelAttr;


@end

@implementation ViewController {
    CGFloat _width;
    CGFloat _height;
    CGSize _contentSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _width = CGRectGetWidth([UIScreen mainScreen].bounds);
    _height = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    self.attributedStr = [[NSMutableAttributedString alloc] initWithData: [content dataUsingEncoding: NSUTF8StringEncoding] options: @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes: nil error: nil];
    self.labelAttr = [[NSMutableAttributedString alloc] initWithData: [content dataUsingEncoding: NSUTF8StringEncoding] options: @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes: nil error: nil];
    _contentSize = [self.attributedStr boundingRectWithSize: CGSizeMake(MAXFLOAT, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context: nil].size;
    [self build];
}

#pragma mark - Private methods
- (void)build {
    CGRect rect = CGRectMake(0, 64, _width, _height-64);
    //webView
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame: rect configuration: configuration];
    _webView.navigationDelegate = self;
    [_webView loadHTMLString: content baseURL: NULL];
    //label
    _scrollView = [[UIScrollView alloc] initWithFrame: rect];
    _scrollView.contentSize = _contentSize;
    _label = [UILabel new];
    _label.frame = (CGRect){CGPointMake(0, 0), _contentSize};
    _label.numberOfLines = 0;
    _label.textAlignment = NSTextAlignmentLeft;
    _label.attributedText = self.labelAttr;
    [_scrollView addSubview: _label];
    //textView1
    _textView1 = [UITextView new];
    _textView1.frame = rect;
    _textView1.editable = NO;
    _textView1.selectable = YES;
    _textView1.dataDetectorTypes = UIDataDetectorTypeLink;
    _textView1.delegate = self;
    _textView1.attributedText = [self adjustAttachment: self.attributedStr width: _width];
    //textView2
    _textView2 = [UITextView new];
    _textView2.frame = rect;
    _textView2.attributedText = [self.attributedStr mutableCopy];
    [_textView2 resetDefaultConfig];
    __weak typeof(self) weakSelf = self;
    _textView2.tapLinkBlock = ^(NSString * _Nonnull str) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf jumpToWebWithUrl: [NSURL URLWithString: str]];
    };
    [_textView2 adjustWebText];

    //selectedIndex = 0
    [self showWebView: YES label: NO textView1: NO textView2: NO];
}

- (void)jumpToWebWithUrl: (NSURL *)url {
    if (!url || !url.absoluteString || ![url.absoluteString hasPrefix: @"http"] || ![url.absoluteString hasPrefix: @"https"]) {
        return;
    }
    SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL: url];
    [self.navigationController pushViewController: controller animated: YES];
}

- (void)showAlertView: (NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"警告" message: message preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle: @"知道了" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated: YES completion: NULL];
    }];
    [controller addAction: confirmAction];
    [self presentViewController: controller animated: YES completion: NULL];
}

- (NSMutableAttributedString *)adjustAttachment: (NSMutableAttributedString *)attrStr width: (CGFloat)width {
    NSMutableAttributedString *attributedStr = [attrStr mutableCopy];
    [attributedStr enumerateAttributesInRange: NSMakeRange(0, attributedStr.length) options: NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
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
    }];
    return attributedStr;
}

#pragma mark - Event response
- (IBAction)handleTapControlEvent:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger index = segmentedControl.selectedSegmentIndex;
    BOOL webView = index == 0? YES : NO;
    BOOL label = index == 1? YES : NO;
    BOOL textView1 = index == 2? YES : NO;
    BOOL textView2 = index == 3? YES : NO;
    [self showWebView: webView label: label textView1: textView1 textView2: textView2];
}

- (void)showWebView: (BOOL)webView label: (BOOL)label textView1: (BOOL)textView1 textView2: (BOOL)textView2 {
    if (webView) {
        if (!self.webView.superview) {
            [self.view addSubview: self.webView];
        }
    } else {
        [self.webView removeFromSuperview];
    }
    
    if (label) {
        if (!self.scrollView.superview) {
            [self.view addSubview: self.scrollView];
        }
    } else {
        [self.scrollView removeFromSuperview];
    }
    
    if (textView1) {
        if (!self.textView1.superview) {
            [self.view addSubview: self.textView1];
        }
    } else {
        [self.textView1 removeFromSuperview];
    }
    
    if (textView2) {
        if (!self.textView2.superview) {
            [self.view addSubview: self.textView2];
        }
    } else {
        [self.textView2 removeFromSuperview];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [self jumpToWebWithUrl: URL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    [self showAlertView: @"Tap image!"];
    return NO;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (!url || !url.absoluteString || ![url.absoluteString hasPrefix: @"http"] || ![url.absoluteString hasPrefix: @"https"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    [self jumpToWebWithUrl: url];
    decisionHandler(WKNavigationActionPolicyCancel);
}

@end
