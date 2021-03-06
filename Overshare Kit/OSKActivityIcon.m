//
//  OSKActivityIconButton.m
//  Overshare
//
//  Created by Jared Sinclair on 10/13/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKActivityIcon.h"

#import "OSKInMemoryImageCache.h"

static UIImage * OSKActivityIconMaskImage;

@interface OSKActivityIcon ()

@property (copy, nonatomic) NSString *imageKey;
@property (retain, nonatomic) NSMutableDictionary *tintStates;

@end

@implementation OSKActivityIcon

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (UIImage *)maskImage {
    if (OSKActivityIconMaskImage == nil) {
        OSKActivityIconMaskImage = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                        ? [UIImage imageNamed:@"osk-iconMask-bw-76.png"]
                        : [UIImage imageNamed:@"osk-iconMask-bw-60.png"];
    }
    return OSKActivityIconMaskImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)maskImage:(UIImage *)image withMask:(UIImage *)maskImage completion:(void(^)(UIImage *maskedImage))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef maskRef = maskImage.CGImage;
        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                            CGImageGetHeight(maskRef),
                                            CGImageGetBitsPerComponent(maskRef),
                                            CGImageGetBitsPerPixel(maskRef),
                                            CGImageGetBytesPerRow(maskRef),
                                            CGImageGetDataProvider(maskRef), NULL, false);
        
        CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
        CGFloat scale = [[UIScreen mainScreen] scale];
        UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(mask);
        CGImageRelease(maskedImageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(maskedImage);
            }
        });
    });
}

- (NSString *)keyForActivityType:(NSString *)type displayString:(NSString *)displayString {
    return [NSString stringWithFormat:@"%@_%@", type, displayString];
}

- (void)setBackgroundImage:(UIImage *)image forActivityType:(NSString *)type displayString:(NSString *)displayString {
    NSString *imageKey = [self keyForActivityType:type displayString:displayString];
    if ([_imageKey isEqualToString:imageKey] == NO) {
        
        [self setImageKey:imageKey];
        
        UIImage *cachedImage = [[OSKInMemoryImageCache sharedInstance] objectForKey:imageKey];
        
        if (cachedImage) {
            [self setAlpha:1];
            [self setImage:cachedImage forState:UIControlStateNormal];
            [self setImage:cachedImage forState:UIControlStateHighlighted];
        } else {
            [self setAlpha:0];

            __weak OSKActivityIcon *weakSelf = self;
            [self maskImage:image withMask:[self maskImage] completion:^(UIImage *maskedImage) {
                if ([weakSelf.imageKey isEqualToString:imageKey]) { // May have changed during processing
                    [weakSelf setImage:maskedImage forState:UIControlStateNormal];
                    [weakSelf setImage:maskedImage forState:UIControlStateHighlighted];
                    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        [weakSelf setAlpha:1.0];
                    } completion:nil];
                    [[OSKInMemoryImageCache sharedInstance] setObject:maskedImage forKey:imageKey];
                }
            }];
        }
    }
}

- (void)osk_setTintColor:(UIColor *)color forState:(UIControlState)state
{
    if(self.tintStates == nil)
    {
        self.tintStates = [NSMutableDictionary dictionary];
    }
    
    [self.tintStates setObject:color forKey:@(state)];
    
    if(self.state == state)
    {
        self.tintColor = color;
    }
}

- (UIColor *)osk_tintColorForState:(UIControlState)state
{
    return [self.tintStates objectForKey:@(state)];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if(highlighted)
    {
        UIColor *pressedTintColor = [self.tintStates objectForKey:@(UIControlStateHighlighted)];
        if(pressedTintColor)
        {
            self.tintColor = pressedTintColor;
        }
    }
    else
    {
        UIColor *normalTintColor = [self.tintStates objectForKey:@(UIControlStateNormal)];
        if(normalTintColor)
        {
            self.tintColor = normalTintColor;
        }
    }
}

@end
