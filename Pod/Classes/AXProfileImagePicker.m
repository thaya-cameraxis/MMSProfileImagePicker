//
//  AXProfileImagePicker.m
//  MMSCameraViewController
//
//  Created by Baveendran Nagendran on 5/3/18.
//

#import "AXProfileImagePicker.h"
#import "UIImage+Cropping.h"
#import "MMSProfileImagePicker+SubClass.h"

@interface AXProfileImagePicker ()

@end

@implementation AXProfileImagePicker

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)positionImageView {
    
    CGRect screenRect = [UIScreen mainScreen].bounds;  // get the device physical screen dimensions
    
    CGRect cropRect = [self centerSquareRectInRect:screenRect.size withInsets:self.cropRectEdgeInsets];
    
    self.imageView.image = self.imageToEdit;
    
    CGSize imageSize = [UIImage scaleSize:self.imageView.image.size toSize:cropRect.size];
    CGSize furtherScaledImageSize = [self furtherScaleSize:imageSize toSize:cropRect.size];
    
    CGRect imageRect = CGRectMake(0, 0, furtherScaledImageSize.width, furtherScaledImageSize.height);
    
    self.imageView.frame = imageRect;
    
    self.scrollView.contentSize = imageRect.size;
    
    [self.scrollView layoutIfNeeded];
    self.scrollView.contentOffset = [self centerRect:self.imageView.frame inside:self.scrollView.frame];
    
    UIEdgeInsets insets = [self insetsForImage:self.imageView.frame.size withFrame:cropRect.size inView:screenRect.size];
    self.scrollView.contentInset = insets;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}



-(CGRect)centerSquareRectInRect:(CGSize)layerSize withInsets:(UIEdgeInsets)inset{
    
    CGRect rect = CGRectZero;
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    rect = CGRectMake(x, y, layerSize.width-inset.right-inset.left, layerSize.height-inset.bottom-inset.top);
    
    if (!(CGSizeEqualToSize(rect.size, self.overlayCropSize))) {
        
        if (self.overlayCropSize.width > self.overlayCropSize.height) {
            
            rect.size.height = (self.overlayCropSize.height/self.overlayCropSize.width) * rect.size.width;
            
        }else{
            
            CGFloat newWidth = (self.overlayCropSize.width/self.overlayCropSize.height) * rect.size.height;
            
            if (newWidth > rect.size.width) {
                
                CGFloat newHeight = (self.overlayCropSize.height/self.overlayCropSize.width) * rect.size.width;
                
                if (newHeight > rect.size.height) {
                    
                    rect.size.height = (self.overlayCropSize.height/self.overlayCropSize.width) * rect.size.height;
                    
                }else{
                    
                    rect.size.height = newHeight;
                }
                
            }else{
                rect.size.width = newWidth;
            }
            
        }
        
    }
    
    if (self.isACircleOverlay) {

        if (rect.size.width > rect.size.height) {
            rect.size.width = rect.size.height;
        }else{
            rect.size.height = rect.size.width;
        }
    }
    
    
    x = (layerSize.width/2 - rect.size.width/2);
    y = (layerSize.height/2 - rect.size.height/2);
    
    rect.origin.x = x;
    rect.origin.y = y;
    
    return rect;
    
}



-(CAShapeLayer*)createOverlay:(CGRect)inBounds bounds:(CGRect)outBounds{
    
    // create the circle so that it's diameter is the screen width and its center is at the intersection of the horizontal and vertical centers
    
    // Create a rectangular path to enclose the circular path within the bounds of the passed in layer size.
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:outBounds cornerRadius:0];
    
    if (self.isACircleOverlay) {
        UIBezierPath *circPath = [UIBezierPath bezierPath];
        CGPoint center = CGPointMake((inBounds.origin.x + inBounds.size.width/2.0), (inBounds.origin.y + inBounds.size.height/2.0));
        [circPath addArcWithCenter:center radius:(inBounds.size.height/2.0) startAngle:0 endAngle:2 * M_PI clockwise:YES];
        [rectPath appendPath:circPath];
    }else{
        UIBezierPath *innerRectPath = [UIBezierPath bezierPathWithRect:inBounds];
        [rectPath appendPath:innerRectPath];
    }
    
    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    
    // add the circle path within the rectangular path to the shape layer.
    rectLayer.path = rectPath.CGPath;
    
    rectLayer.fillRule = kCAFillRuleEvenOdd;
    
    rectLayer.fillColor = self.backgroundColor.CGColor;
    
    rectLayer.opacity = self.overlayOpacity;
    
    return rectLayer;
    
}

-(CGSize)furtherScaleSize:(CGSize)scaleSize toSize:(CGSize)toSize {
    
    CGFloat h_w_ratio = (scaleSize.height/scaleSize.width);
    CGFloat w_h_ratio = (scaleSize.width/scaleSize.height);
    
    if (scaleSize.height < toSize.height) {

        scaleSize.height = toSize.height;
        scaleSize.width = w_h_ratio * toSize.height;
        scaleSize.height = h_w_ratio * scaleSize.width;
        
    }else if(scaleSize.width < toSize.width){
        
        scaleSize.width = toSize.width;
        scaleSize.height = h_w_ratio * toSize.width;
        scaleSize.width = w_h_ratio * scaleSize.height;
    }
    
    return scaleSize;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Getters overwrite

-(UIEdgeInsets)cropRectEdgeInsets{
    return UIEdgeInsetsMake(96.0, 25.0, 77.0, 25.0);
}

@end
