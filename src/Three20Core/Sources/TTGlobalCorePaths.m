//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20Core/TTGlobalCorePaths.h"


static NSBundle* globalBundle = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsBundleURL(NSString* URL) {
  return [URL hasPrefix:@"bundle-"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsDocumentsURL(NSString* URL) {
  return [URL hasPrefix:@"documents://"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTSetDefaultBundle(NSBundle* bundle) {
  [bundle retain];
  [globalBundle release];
  globalBundle = bundle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSBundle* TTGetDefaultBundle() {
  return (nil != globalBundle) ? globalBundle : [NSBundle mainBundle];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
NSBundle* TTBundle(NSString *bundleName) {
    static NSMutableDictionary *bundleDictionary = nil;
    if ( bundleDictionary == nil ) {
        bundleDictionary = [[NSMutableDictionary alloc] init];
    }
    NSBundle *bundle = [bundleDictionary objectForKey:bundleName];
    if ( !bundle ) {
        NSString* path = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingPathComponent:bundleName] stringByAppendingPathExtension:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
        assert( bundle );
        if (bundle) {
            [bundleDictionary setObject:bundle forKey:bundleName];
        } else {
            NSLog(@"could not locate bundle %@ in application bundle", bundleName);
        }
    }
    return bundle;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* TTPathForBundleResource(NSString* relativePath) {
    NSRange colonSlashRange = [relativePath rangeOfString:@"://"];
    NSRange bundleRange = { .location = 0, .length = colonSlashRange.location };
    NSString *bundleName = [relativePath substringWithRange:bundleRange];
    NSBundle *bundle = TTBundle(bundleName);
    NSString* resourcePath = [bundle resourcePath];
    NSString *pathInBundle = [relativePath substringFromIndex:(colonSlashRange.location + colonSlashRange.length)];
    return [resourcePath stringByAppendingPathComponent:pathInBundle];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* TTPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (!documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES);
    documentsPath = [[dirs objectAtIndex:0] retain];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}
