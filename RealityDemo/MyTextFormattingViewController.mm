//
//  MyTextFormattingViewController.mm
//  MiscellaneousUIKit
//
//  Created by Jinwoo Kim on 1/18/25.
//

#import "MyTextFormattingViewController.h"

#if TARGET_OS_VISION

#import <objc/message.h>
#import <objc/runtime.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

@interface MyTextFormattingViewController () <UIColorPickerViewControllerDelegate, UIFontPickerViewControllerDelegate>
@end

@implementation MyTextFormattingViewController

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [[self class] allocWithZone:zone];
}

+ (Class)class {
    static Class isa;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class _isa = objc_allocateClassPair(objc_lookUpClass("UITextFormattingViewController"), "_XRTextFormattingViewController", 0);
        
        //
        
        IMP initWithNibName_nibBundleOrNil_ = class_getMethodImplementation(self, @selector(initWithNibName:bundle:));
        assert(class_addMethod(_isa, @selector(initWithNibName:bundle:), initWithNibName_nibBundleOrNil_, NULL));
        
        IMP _computeContentSize = class_getMethodImplementation(self, @selector(_computeContentSize));
        assert(class_addMethod(_isa, @selector(_computeContentSize), _computeContentSize, NULL));
        
        IMP _presentColorPicker_selectedColor_ = class_getMethodImplementation(self, @selector(_presentColorPicker:selectedColor:));
        assert(class_addMethod(_isa, @selector(_presentColorPicker:selectedColor:), _presentColorPicker_selectedColor_, NULL));
        
        IMP colorPickerViewController_didSelectColor_continuously_ = class_getMethodImplementation(self, @selector(colorPickerViewController:didSelectColor:continuously:));
        assert(class_addMethod(_isa, @selector(colorPickerViewController:didSelectColor:continuously:), colorPickerViewController_didSelectColor_continuously_, NULL));
        
        IMP _presentFontPickerWithConfiguration_selectedFonts_ = class_getMethodImplementation(self, @selector(_presentFontPickerWithConfiguration:selectedFonts:));
        assert(class_addMethod(_isa, @selector(_presentFontPickerWithConfiguration:selectedFonts:), _presentFontPickerWithConfiguration_selectedFonts_, NULL));
        
        IMP fontPickerViewControllerDidPickFont_ = class_getMethodImplementation(self, @selector(fontPickerViewControllerDidPickFont:));
        assert(class_addMethod(_isa, @selector(fontPickerViewControllerDidPickFont:), fontPickerViewControllerDidPickFont_, NULL));
        
        //
        
        objc_registerClassPair(_isa);
        
        isa = _isa;
    });
    
    return isa;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"UIFontPickerRecentFamilies"];
    
    objc_super superInfo = { self, [self class] };
    return reinterpret_cast<id (*)(objc_super *, SEL, id, id)>(objc_msgSendSuper2)(&superInfo, _cmd, nibNameOrNil, nibBundleOrNil);
}

- (CGSize)_computeContentSize {
    return CGSizeMake(self.preferredContentSize.width, 375.);
}

- (void)_presentColorPicker:(CGRect)rect selectedColor:(UIColor *)selectedColor {
    UIColorPickerViewController *viewController = [UIColorPickerViewController new];
    
    viewController.selectedColor = selectedColor;
    viewController.supportsAlpha = NO;
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(viewController, sel_registerName("_setSupportsEyedropper:"), YES);
    
    id delegate = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("delegate"));
    if ([delegate respondsToSelector:sel_registerName("textFormattingViewController:shouldPresentColorPicker:")]) {
        reinterpret_cast<void (*)(id, SEL, id, id)>(objc_msgSend)(delegate, sel_registerName("textFormattingViewController:shouldPresentColorPicker:"), self, viewController);
    }
    
    viewController.selectedColor = selectedColor;
    viewController.supportsAlpha = NO;
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(viewController, sel_registerName("_setSupportsEyedropper:"), YES);
    viewController.delegate = self;
    
    //
    
    if (reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_isInPopoverPresentation"))) {
        reinterpret_cast<void (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_stopSuppressingKeyboardForTextFormatting"));
        reinterpret_cast<void (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_textFormattingRequestsFirstResponderResignation"));
        reinterpret_cast<void (*)(id, SEL, NSUInteger, BOOL)>(objc_msgSend)(self, sel_registerName("_modifyKeyboardTrackingIfNeededForType:start:"), 2, YES);
    }
    
    //
    
    UIScrollView *_scrollView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_scrollView"));
    _scrollView.hidden = YES;
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(self.view, sel_registerName("_addBoundsMatchingConstraintsForView:"), viewController.view);
    [viewController didMoveToParentViewController:self];
    
    [viewController release];
    reinterpret_cast<void (*)(id, SEL, NSUInteger, BOOL)>(objc_msgSend)(self, sel_registerName("_modifyKeyboardTrackingIfNeededForType:start:"), 2, NO);
}

- (void)colorPickerViewController:(UIColorPickerViewController *)viewController didSelectColor:(UIColor *)color continuously:(BOOL)continuously {
    objc_super superInfo = { self, [self class] };
    reinterpret_cast<void (*)(objc_super *, SEL, id, id, BOOL)>(objc_msgSendSuper2)(&superInfo, _cmd, viewController, color, continuously);
    
    if (continuously) return;
    
//    NSDictionary<NSString *, id> *textAttributes = @{
//        NSForegroundColorAttributeName: color
//    };
//    
//    id changeValue = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("UITextFormattingViewControllerChangeValue") alloc], sel_registerName("initWithTextColor:"), color);
//    
//    reinterpret_cast<void (*)(id, SEL, id, id)>(objc_msgSend)(self, sel_registerName("_textFormattingDidChangeValue:textAttributes:"), changeValue, textAttributes);
//    [changeValue release];
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    
    UIScrollView *_scrollView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_scrollView"));
    _scrollView.hidden = NO;
}

- (void)_presentFontPickerWithConfiguration:(UIFontPickerViewControllerConfiguration *)configuration selectedFonts:(NSArray<UIFont *> *)selectedFonts {
    id ownConfiguration = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("configuration"));
    UIFontPickerViewControllerConfiguration *fontPickerConfiguration = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(ownConfiguration, sel_registerName("fontPickerConfiguration"));
    
    if (fontPickerConfiguration == nil) fontPickerConfiguration = configuration;
    
    UIFontPickerViewController *viewController = [[UIFontPickerViewController alloc] initWithConfiguration:fontPickerConfiguration];
    
    NSMutableArray<UIFontDescriptor *> *selectedFontDescriptors = [NSMutableArray arrayWithCapacity:selectedFonts.count];
    [selectedFonts enumerateObjectsUsingBlock:^(UIFont * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [selectedFontDescriptors addObject:obj.fontDescriptor];
    }];
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(viewController, sel_registerName("_setSelectedFontDescriptors:"), selectedFontDescriptors);
    
    //
    
    id delegate = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("delegate"));
    if ([delegate respondsToSelector:sel_registerName("textFormattingViewController:shouldPresentFontPicker:")]) {
        BOOL shouldPresent = reinterpret_cast<BOOL (*)(id, SEL, id, id)>(objc_msgSend)(delegate, sel_registerName("textFormattingViewController:shouldPresentFontPicker:"), self, viewController);
        
        if (!shouldPresent) {
            [viewController release];
            return;
        }
    }
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(viewController, sel_registerName("_setSelectedFontDescriptors:"), selectedFontDescriptors);
    viewController.delegate = self;
    
    reinterpret_cast<void (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_stopSuppressingKeyboardForTextFormatting"));
    reinterpret_cast<void (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_textFormattingRequestsFirstResponderResignation"));
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(self.view, sel_registerName("_addBoundsMatchingConstraintsForView:"), viewController.view);
    [viewController didMoveToParentViewController:self];
    
    [viewController release];
    
    reinterpret_cast<void (*)(id, SEL, NSUInteger, BOOL)>(objc_msgSend)(self, sel_registerName("_modifyKeyboardTrackingIfNeededForType:start:"), 2, NO);
    
    UIScrollView *_scrollView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_scrollView"));
    _scrollView.hidden = YES;
}

- (void)fontPickerViewControllerDidPickFont:(UIFontPickerViewController *)viewController {
    objc_super superInfo = { self, [self class] };
    reinterpret_cast<void (*)(objc_super *, SEL, id)>(objc_msgSendSuper2)(&superInfo, _cmd, viewController);
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    
    UIScrollView *_scrollView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_scrollView"));
    _scrollView.hidden = NO;
}

@end

#endif
