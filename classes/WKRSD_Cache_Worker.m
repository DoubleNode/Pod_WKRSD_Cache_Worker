//
//  WKRSD_Cache_Worker.m
//  DoubleNode SDWebImage Cache Worker
//
//  Created by Darren Ehlers on 2016/10/16.
//  Copyright © 2016 Darren Ehlers and DoubleNode, LLC.
//
//  WKRSD_Cache_Worker is released under the MIT license. See LICENSE for details.
//

#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>

#import "WKRSD_Cache_Worker.h"

@implementation WKRSD_Cache_Worker

@synthesize nextBaseWorker;
@synthesize nextCacheWorker;

#define ERROR_DOMAIN_CLASS      [NSString stringWithFormat:@"com.doublenode.%@", NSStringFromClass([self class])]
#define ERROR_UNKNOWN           1001
#define ERROR_NOT_FOUND         1002
#define ERROR_BAD_PARAMETER     1003
#define ERROR_BAD_RESPONSE      1004
#define ERROR_SERVER_ERROR      1005
#define ERROR_URL_MISMATCH      1006

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
             withProgress:(nullable PTCLProgressBlock)progressBlock
                 andBlock:(nullable PTCLCacheBlockVoidIDNSError)block
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

- (void)doLoadImageForUrl:(nonnull NSURL*)url
             withProgress:(nullable PTCLProgressBlock)progressBlock
                 andBlock:(nullable PTCLCacheBlockVoidIDNSError)block
{
    if (!url.absoluteString.length)
    {
        NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                               code:ERROR_BAD_PARAMETER
                                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The ID was invalid.", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to load object without a valid ID.", nil)
                                                       }];
        block ? block(nil, error) : (void)nil;
        return;
    }
    
    [self doLoadObjectForId:url.absoluteString
               withProgress:progressBlock
                   andBlock:
     ^(id _Nullable object, NSError* _Nullable error)
     {
         if (object && [object isKindOfClass:UIImage.class])
         {
             block ? block(object, error) : (void)nil;
             return;
         }
         
         [SDWebImageManager.sharedManager loadImageWithURL:url
                                                   options:0
                                                  progress:nil
                                                 completed:
          ^(UIImage* _Nullable image, NSData* _Nullable data, NSError* _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL* _Nullable imageURL)
          {
              if (error)
              {
                  block ? block(nil, error) : (void)nil;
                  return;
              }
              
              if (![imageURL isEqual:url])
              {
                  // Incorrect image download completed
                  NSError*   error = [NSError errorWithDomain:ERROR_DOMAIN_CLASS
                                                         code:ERROR_URL_MISMATCH
                                                     userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Image URL Mismatch.", nil),
                                                                 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The image downloaded doesn't match the URL expected.", nil)
                                                                 }];
                  block ? block(nil, error) : (void)nil;
                  return;
              }
              
              [self doSaveObject:image
                           forId:url.absoluteString
                    withProgress:progressBlock
                        andBlock:
               ^(NSError* _Nullable error)
               {
                   if (error)
                   {
                       block ? block(nil, error) : (void)nil;
                       return;
                   }
                   
                   block ? block(image, nil) : (void)nil;
               }];
          }];
     }];
}

- (void)doDeleteObjectForId:(nonnull NSString*)cacheId
               withProgress:(nullable PTCLProgressBlock)progressBlock
                   andBlock:(nullable PTCLCacheBlockVoidNSError)block
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
        withProgress:(nullable PTCLProgressBlock)progressBlock
            andBlock:(nullable PTCLCacheBlockVoidNSError)block
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
