//
//  AXProfileImagePicker.m
//  MMSCameraViewController
//
//  Created by Baveendran Nagendran on 5/3/18.
//

#import "AXProfileImagePicker.h"
#import "UIImage+Cropping.h"
#import "MMSProfileImagePicker+SubClass.h"
#import <Photos/PHAsset.h>


@interface AXProfileImagePicker ()

@end

@implementation AXProfileImagePicker
{
    PHAsset *_phAsset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)positionImageView {
    
    if (self.scrollView.zoomScale != 1.0) {
        self.scrollView.zoomScale = 1.0;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;  // get the device physical screen dimensions
    
    CGRect cropRect = [self centerSquareRectInRect:screenRect.size withInsets:self.cropRectEdgeInsets];
    
    self.imageView.image = self.imageToEdit;
    
    CGSize furtherScaledImageSize = [self furtherScaleSize:self.imageView.image.size toSize:cropRect.size];
    
    CGRect imageRect = CGRectMake(0, 0, furtherScaledImageSize.width, furtherScaledImageSize.height);
    
    self.imageView.frame = imageRect;
    
    self.scrollView.contentSize = imageRect.size;
    self.scrollView.contentOffset = [self centerRect:self.imageView.frame inside:self.scrollView.frame];
    
    UIEdgeInsets insets = [self insetsForImage:self.imageView.frame.size withFrame:cropRect.size inView:screenRect.size];
    self.scrollView.contentInset = insets;
    
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

-(CGSize)furtherScaleSize:(CGSize)fromSize toSize:(CGSize)toSize {
    
    CGSize scaleSize = CGSizeZero;
    
    // if the wideth is the shorter dimension
    if (toSize.width < toSize.height) {
        
        if (fromSize.width >= toSize.width) {  // give priority to width if it is larger than the destination width
            
            scaleSize.width = ceilf(toSize.width);
            
            scaleSize.height = ceilf(scaleSize.width * fromSize.height / fromSize.width);
            
        } else if (fromSize.height >= toSize.height) {  // then give priority to height if it is larger than destination height
            
            scaleSize.height = ceilf(toSize.height);
            
            scaleSize.width = ceilf(scaleSize.height * fromSize.width / fromSize.height);
            
        } else {  // otherwise the source size is smaller in all directions.  Scale on width
            
            scaleSize.width = ceilf(toSize.width);
            
            scaleSize.height = ceilf(scaleSize.width * fromSize.height / fromSize.width);
            
            if (scaleSize.height > toSize.height) { // but if the new height is larger than the destination then scale height
                
                scaleSize.height = ceilf(toSize.height);
                
                scaleSize.width = ceilf(scaleSize.height * fromSize.width / fromSize.height);
            }
            
        }
    } else {  // else height is the shorter dimension
        
        if (fromSize.height >= toSize.height) {  // then give priority to height if it is larger than destination height
            
            scaleSize.height = ceilf(toSize.height);
            
            scaleSize.width = ceilf(scaleSize.height * fromSize.width / fromSize.height);
            
        } else if (fromSize.width >= toSize.width) {  // give priority to width if it is larger than the destination width
            
            scaleSize.width = ceilf(toSize.width);
            
            scaleSize.height = ceilf(scaleSize.width * fromSize.height / fromSize.width);
            
            
        } else {  // otherwise the source size is smaller in all directions.  Scale on width
            
            scaleSize.width = ceilf(toSize.width);
            
            scaleSize.height = ceilf(scaleSize.width * fromSize.height / fromSize.width);
            
            if (scaleSize.height > toSize.height) { // but if the new height is larger than the destination then scale height
                
                scaleSize.height = ceilf(toSize.height);
                
                scaleSize.width = ceilf(scaleSize.height * fromSize.width / fromSize.height);
            }
            
        }
        
    }
    
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


-(void)sendDidFinishPickingMediaWithInfo:(NSDictionary*)info{
    
    NSMutableDictionary *infoMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:info];
    
    if(_phAsset){
        
        if (@available(iOS 11.0, *)) {
            [infoMutableDictionary setObject:_phAsset forKey:UIImagePickerControllerPHAsset];
        } else {
            // Fallback on earlier versions
            [infoMutableDictionary setObject:_phAsset forKey:@"UIImagePickerControllerPHAsset"];
        }
        
    }
    
    [super sendDidFinishPickingMediaWithInfo:[NSDictionary dictionaryWithDictionary:infoMutableDictionary]];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    
    if (@available(iOS 11.0, *)) {
        
        if([info valueForKey:UIImagePickerControllerPHAsset]){
            _phAsset = [info objectForKey:UIImagePickerControllerPHAsset];
        }else if([info valueForKey:UIImagePickerControllerReferenceURL]){
            
            [self updatePhAssetWithReferenceURL:info[UIImagePickerControllerReferenceURL]];
            
        }
    } else {
        // Fallback on earlier versions
        
        if([info valueForKey:UIImagePickerControllerReferenceURL]){
            
            [self updatePhAssetWithReferenceURL:info[UIImagePickerControllerReferenceURL]];
            
        }
        
    }
    
    [super imagePickerController:picker didFinishPickingMediaWithInfo:info];
    
}

-(void)updatePhAssetWithReferenceURL:(NSURL*)referenceURL{
    
    PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceURL] options:nil];
    _phAsset = assets.firstObject;

}

- (NSString*)lString:(NSString*) key comment:(NSString*)comment {
    
    if ([key isEqualToString:@"Button.choose.photoFromCamera"]) {
        return @"Use Photo";
    }else if ([key isEqualToString:@"Button.choose.photoFromPicker"]) {
        return @"Choose";
    }else if ([key isEqualToString:@"Button.cancel.photoFromCamera"]) {
        return @"Retake";
    }else if ([key isEqualToString:@"Button.cancel.photoFromPicker"]) {
        return @"Cancel";
    }else if ([key isEqualToString:@"Edit.title"]) {
        return @"Move and Scale";
    }else{
        return @"";
    }
    
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
