//
//  MyTextViewController.m
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

#import "MyTextViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "MyTextFormattingViewController.h"

@interface MyTextViewController ()
@property (retain, nonatomic, getter=_stackView, setter=_setStackView:) UIStackView *stackView;
@property (retain, nonatomic, readonly, getter=_textFormattingViewController) MyTextFormattingViewController *textFormattingViewController;
@end

@implementation MyTextViewController
@synthesize stackView = _stackView;
@synthesize textView = _textView;
@synthesize textFormattingViewController = _textFormattingViewController;

- (void)dealloc {
    [_stackView release];
    [_textView release];
    [_textFormattingViewController release];
    [super dealloc];
}

- (void)loadView {
    UITextView *textView = self.textView;
    MyTextFormattingViewController *textFormattingViewController = self.textFormattingViewController;
    
    [self addChildViewController:textFormattingViewController];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[textFormattingViewController.view, textView]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentFill;
    
    self.view = stackView;
    [stackView release];
    
    [textFormattingViewController didMoveToParentViewController:self];
}

- (UITextView *)textView {
    if (auto textView = _textView) return textView;
    
    UITextView *textView = [UITextView new];
    textView.allowsEditingTextAttributes = YES;
    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    
    _textView = textView;
    return textView;
}

- (MyTextFormattingViewController *)_textFormattingViewController {
    if (auto textFormattingViewController = _textFormattingViewController) return textFormattingViewController;
    
    id configuration = [((id (*)(id, SEL))objc_msgSend)(self.textView, sel_registerName("textFormattingConfiguration")) copy];
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(configuration, sel_registerName("set_textAnimationsConfiguration:"), YES);
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(configuration, sel_registerName("_setHasParentViewController:"), YES);
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(configuration, sel_registerName("_setHasPopoverPresentation:"), NO);
    
    MyTextFormattingViewController *textFormattingViewController = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([MyTextFormattingViewController alloc], sel_registerName("initWithConfiguration:"), configuration);
    [configuration release];
    
    textFormattingViewController.preferredContentSize = CGSizeMake(375., 260.);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(textFormattingViewController, sel_registerName("_setInternalDelegate:"), self.textView);
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(textFormattingViewController, sel_registerName("_setEditResponder:"), self.textView);
    
    _textFormattingViewController = textFormattingViewController;
    return textFormattingViewController;
}

@end
