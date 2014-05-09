/**
 *  Copyright (c) 2014, Inmite s.r.o. (www.inmite.eu).
 *
 * All rights reserved. This source code can be used only for purposes specified
 * by the given license contract signed by the rightful deputy of Inmite s.r.o.
 * This source code can be used only by the owner of the license.
 *
 * Any disputes arising in respect of this agreement (license) shall be brought
 * before the Municipal Court of Prague.
 *
 */

#import "BikeDetailViewController.h"
#import "UIWebView+AFNetworking.h"

@implementation BikeDetailViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = [ContentManager manager].usingBike.name ?: NSLocalizedString(@"Bike Detail", @"Bar button title in navigation bar");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _errorLabel.hidden = YES;
    _errorLabel.text = NSLocalizedString(@"Something went wrong.", @"A label text somewhere on the screen");
    
     _webView.requestSerializer = [APIManager manager].requestSerializer;
    [self reloadData];
}

- (void)reloadData {
    [self loadURL:[NSURL URLWithString:_urlPath]];
}

#pragma mark - Private methods

- (void)loadURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    
    [request addValue:[APIManager manager].accessToken forHTTPHeaderField:@"X-Api-Key"];
    
    __weak __typeof(self)weakSelf = self;
    [_webView loadRequest:request progress:nil success:nil failure:^(NSError *error) {
        if (weakSelf) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (error.code != -999) {
                strongSelf.errorLabel.hidden = NO;
                strongSelf.indicatorView.hidden = YES;
            }
        }
    }];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    webView.userInteractionEnabled = NO;
    _indicatorView.hidden = NO;
    _errorLabel.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    webView.userInteractionEnabled = YES;
    _indicatorView.hidden = YES;
}

@end
