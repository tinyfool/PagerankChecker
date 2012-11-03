//
//  AppDelegate.h
//  Pagerank Checker
//
//  Created by pei hao on 12-10-30.
//  Copyright (c) 2012年 pei hao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Url.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *urlTable;
@property (weak) IBOutlet NSTextField *urlInput;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@property (retain,nonatomic) NSArray* urlist;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (IBAction)delUrl:(id)sender;
- (IBAction)addUrl:(id)sender;
- (IBAction)addSitemap:(id)sender;
- (IBAction)addUrlsFromFile:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)addUrls:(id)sender;

-(void)addOneUrl:(NSString*)url;
-(void)addSomeUrls:(NSString*)urls;
-(void)reloadData;
-(BOOL)findUrl:(NSString*)url;
-(int)checkPagerank:(NSString*)url;
-(IBAction)checking:(id)sender;

-(Url*)oneUrlNeedtoGet:(id)sender;
-(int)progress;
@end
