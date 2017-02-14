//
//  WKRSD_Cache_Worker.m
//  DoubleNode Core
//
//  Created by Darren Ehlers on 2016/10/16.
//  Copyright © 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

#import <SDWebImage/SDImageCache.h>

#import "WKRSD_Cache_Worker.h"

@implementation WKRSD_Cache_Worker

@synthesize nextBaseWorker;
@synthesize nextCacheWorker;

#define ERROR_DOMAIN_CLASS      [NSString stringWithFormat:@"com.doublenode.rentmywardrobe.%@", NSStringFromClass([self class])]
#define ERROR_UNKNOWN           1001
#define ERROR_NOT_FOUND         1002
#define ERROR_BAD_PARAMETER     1003
#define ERROR_BAD_RESPONSE      1004
#define ERROR_SERVER_ERROR      1005

+ (instancetype _Nonnull)worker   {   return [self worker:nil]; }

+ (instancetype _Nonnull)worker:(nullable id<PTCLCache_Protocol>)nextCacheWorker
{
    return [[self.class alloc] initWithWorker:nextCacheWorker];
}

- (nonnull instancetype)init
{
    self = [super init];
    if (self)
    {
        self.nextCacheWorker = nil;
    }
    
    return self;
}

- (nonnull instancetype)initWithWorker:(nullable id<PTCLCache_Protocol>)nextCacheWorker_
{
    self = [super initWithWorker:nextCacheWorker_];
    if (self)
    {
        self.nextCacheWorker = nextCacheWorker_;
    }
    
    return self;
}

#pragma mark - Common Methods

- (void)enableOption:(nonnull NSString*)option
{
}

- (void)disableOption:(nonnull NSString*)option
{
}

#pragma mark - Business Logic / Single Item CRUD

- (void)doLoadObjectForId:(nonnull NSString*)cacheId
                withBlock:(nullable PTCLCacheBlockVoidIDNSError)block
{
    if (!cacheId.length)
    {
        NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                               code:ERROR_BAD_PARAMETER
                                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The ID was invalid.", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to load object without a valid ID.", nil)
                                                       }];
        block ? block(nil, error) : (void)nil;
        return;
    }
    
    [SDImageCache.sharedImageCache queryCacheOperationForKey:cacheId
                                                        done:
     ^(UIImage* _Nullable image, NSData* _Nullable data, SDImageCacheType cacheType)
     {
         // image is not nil if image was found
         if (image)
         {
             block ? block(image, nil) : (void)nil;
             return;
         }
         
         if (data)
         {
             block ? block(data, nil) : (void)nil;
             return;
         }
         
         NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                                code:ERROR_NOT_FOUND
                                            userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The object was not found.", nil),
                                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to load object.", nil)
                                                        }];
         block ? block(nil, error) : (void)nil;
     }];
}

- (void)doDeleteObjectForId:(nonnull NSString*)cacheId
                  withBlock:(nullable PTCLCacheBlockVoidNSError)block
{
    if (!cacheId.length)
    {
        NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                               code:ERROR_BAD_PARAMETER
                                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The ID was invalid.", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to load object without a valid ID.", nil)
                                                       }];
        block ? block(error) : (void)nil;
        return;
    }
    
    [SDImageCache.sharedImageCache removeImageForKey:cacheId
                                      withCompletion:
     ^()
     {
         block ? block(nil) : (void)nil;
     }];
}

- (void)doSaveObject:(nonnull id)object
               forId:(nonnull NSString*)cacheId
           withBlock:(nullable PTCLCacheBlockVoidNSError)block
{
    if (!cacheId.length)
    {
        NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                               code:ERROR_BAD_PARAMETER
                                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The ID was invalid.", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to load object without a valid ID.", nil)
                                                       }];
        block ? block(error) : (void)nil;
        return;
    }
    
    if (!object)
    {
        NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                               code:ERROR_BAD_PARAMETER
                                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The object was invalid.", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to save a nil object.", nil)
                                                       }];
        block ? block(error) : (void)nil;
        return;
    }
    
    [[SDImageCache sharedImageCache] storeImage:object
                                         forKey:cacheId
                                     completion:
     ^()
     {
         block ? block(nil) : (void)nil;
     }];
}

@end
