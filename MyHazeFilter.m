/* MyHazeFilter.m - custom CIFilter
 
 Version: 1.1
 
 © Copyright 2006-2009 Apple, Inc. All rights reserved.
 
 IMPORTANT:  This Apple software is supplied to 
 you by Apple Computer, Inc. ("Apple") in 
 consideration of your agreement to the following 
 terms, and your use, installation, modification 
 or redistribution of this Apple software 
 constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, 
 install, modify or redistribute this Apple 
 software.
 
 In consideration of your agreement to abide by 
 the following terms, and subject to these terms, 
 Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this 
 original Apple software (the "Apple Software"), 
 to use, reproduce, modify and redistribute the 
 Apple Software, with or without modifications, in 
 source and/or binary forms; provided that if you 
 redistribute the Apple Software in its entirety 
 and without modifications, you must retain this 
 notice and the following text and disclaimers in 
 all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or 
 logos of Apple Computer, Inc. may be used to 
 endorse or promote products derived from the 
 Apple Software without specific prior written 
 permission from Apple.  Except as expressly 
 stated in this notice, no other rights or 
 licenses, express or implied, are granted by 
 Apple herein, including but not limited to any 
 patent rights that may be infringed by your 
 derivative works or by other works in which the 
 Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS 
 IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR 
 IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED 
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY 
 AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING 
 THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE 
 OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY 
 SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF 
 THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER 
 UNDER THEORY OF CONTRACT, TORT (INCLUDING 
 NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN 
 IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF 
 SUCH DAMAGE.
 
 */
 
#import "MyHazeFilter.h"


@implementation MyHazeFilter

static CIKernel *hazeRemovalKernel = nil;

+ (void)registerFilter
{
    [CIFilter registerFilterName: @"MyHazeRemover"  constructor: self
        classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:

		@"Haze Remover", kCIAttributeFilterDisplayName,

        [NSArray arrayWithObjects:
            kCICategoryColorAdjustment, kCICategoryVideo, kCICategoryStillImage,
            kCICategoryInterlaced, kCICategoryNonSquarePixels,
            nil],                              kCIAttributeFilterCategories,

        nil]];
}

+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
	
    filter = [[self alloc] init];
    return [filter autorelease];
}

- (id)init
{
    if(hazeRemovalKernel == nil)
    {
		NSError		*err;
        NSBundle    *bundle = [NSBundle bundleForClass: [self class]];
        NSString    *code = [NSString stringWithContentsOfFile: [bundle
            pathForResource: @"MyHazeRemoval" ofType: @"cikernel"] encoding:NSUTF8StringEncoding error:&err];
        NSArray     *kernels = [CIKernel kernelsWithString: code];

        hazeRemovalKernel = [[kernels objectAtIndex:0] retain];
    }

    return [super init];
}


- (CIImage *)outputImage
{
    CISampler *src = [CISampler samplerWithImage: inputImage];

    return [self apply: hazeRemovalKernel, src, inputColor, inputDistance,
        inputSlope, kCIApplyOptionDefinition, [src definition], nil];
}


- (NSDictionary *)customAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:

        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:  0.0], kCIAttributeMin,
            [NSNumber numberWithDouble:  1.0], kCIAttributeMax,
            [NSNumber numberWithDouble:  0.0], kCIAttributeSliderMin,
            [NSNumber numberWithDouble:  0.7], kCIAttributeSliderMax,
            [NSNumber numberWithDouble:  0.2], kCIAttributeDefault,
            [NSNumber numberWithDouble:  0.0], kCIAttributeIdentity,
            kCIAttributeTypeScalar,            kCIAttributeType,
            nil],                              @"inputDistance",

        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble: -0.01], kCIAttributeSliderMin,
            [NSNumber numberWithDouble:  0.01], kCIAttributeSliderMax,
            [NSNumber numberWithDouble:  0.00], kCIAttributeDefault,
            [NSNumber numberWithDouble:  0.00], kCIAttributeIdentity,
            kCIAttributeTypeScalar,             kCIAttributeType,
            nil],                               @"inputSlope",

        [NSDictionary dictionaryWithObjectsAndKeys:
            [CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], kCIAttributeDefault,
            nil],                               @"inputColor",

		@"MyHazeRemover", kCIAttributeFilterName, // this is needed since the filter is registered under a different name than the class
        nil];
}

@end
