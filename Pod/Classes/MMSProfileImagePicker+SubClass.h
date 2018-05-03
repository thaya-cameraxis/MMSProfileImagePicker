//
//  MMSProfileImagePicker+SubClass.h
//  MMSProfileImagePicker
//
//  Created by Baveendran Nagendran on 5/3/18.
//

#import <MMSProfileImagePicker/MMSProfileImagePicker.h>

@interface MMSProfileImagePicker ()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIImage *imageToEdit;


@property (nonatomic, readonly) UIEdgeInsets cropRectEdgeInsets;


-(UIEdgeInsets)insetsForImage:(CGSize)imageSize withFrame:(CGSize)frameSize inView:(CGSize)viewSize;

-(CGPoint)centerRect:(CGRect)insideRect inside:(CGRect)outsideRect;

-(void)sendDidFinishPickingMediaWithInfo:(NSDictionary*)info;

@end
