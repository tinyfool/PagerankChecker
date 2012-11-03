//
//  AppDelegate.m
//  Pagerank Checker
//
//  Created by pei hao on 12-10-30.
//  Copyright (c) 2012年 pei hao. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "PageRank.h"

@implementation AppDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize urlist;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    [self reloadData];
    [self.urlTable reloadData];
    [self performSelectorInBackground:@selector(checking:) withObject:nil];
}

-(Url*)oneUrlNeedtoGet:(id)sender {

    __block NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Url"
                inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"pagerank < 0",-1];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"address" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    __block NSArray* ret;
    ret = [[self managedObjectContext] executeFetchRequest:request error:nil];
    if ([ret count]>0) {
        
        Url* url = [ret objectAtIndex:0];
        NSLog(@"%@",url);
        return url;
    }
    return nil;
}


-(int)progress {

    return 100;
}

-(IBAction)checking:(id)sender {

    while (1) {
        
        
        Url* url= [self oneUrlNeedtoGet:nil];
        if (url) {
            int pagerank = [self checkPagerank:url.address];
            if (pagerank>=0) {
                url.pagerank = [NSNumber numberWithInt:pagerank];
                [[self managedObjectContext] save:nil];
                [self reloadData];
                [self.urlTable reloadData];
            }
        }
        [NSThread sleepForTimeInterval:3];
    }
}

-(int)checkPagerank:(NSString*)url {
    
    PageRank* pagerank = [[PageRank alloc] init];
    return [pagerank getPagerank:url];
}


- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"org.tiny4.pagerankchecker"];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"urllist" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"pagerankchecker.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

-(void)reloadData {

    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Url" inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"pagerank" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    urlist = [[self managedObjectContext] executeFetchRequest:request error:&error];
}

- (IBAction)delUrl:(id)sender {
    
    NSInteger sel = [self.urlTable selectedRow];
    if (sel == -1)
        return;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete this url?"];
    [alert setInformativeText:@"Deleted urls cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        
        Url* url = [urlist objectAtIndex:sel];
        [[self managedObjectContext] deleteObject:url];
        [[self managedObjectContext] save:nil];
        [self reloadData];
        [self.urlTable reloadData];
    }
}

- (IBAction)addUrl:(id)sender {
    
    NSString* url = self.urlInput.stringValue;
    [self addOneUrl:url];
    [[self managedObjectContext] save:nil];
    [self reloadData];
    [self.urlTable reloadData];
}

-(void)addOneUrl:(NSString*)url {

    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (url.length==0)
        return;
    
    if ([self findUrl:url])
        return;
    
    Url *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Url" inManagedObjectContext:[self managedObjectContext]];
    entity.address = url;
    entity.pagerank = [NSNumber numberWithInt:-1];
}

-(void)addSomeUrls:(NSString*)urls {
    
    if (urls.length==0)
        return;
    
    NSArray* urlsArray = [urls componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for (NSString* url in urlsArray) {
        
        [self addOneUrl:url];
    }
}

- (IBAction)addSitemap:(id)sender {
}

- (IBAction)addUrlsFromFile:(id)sender {
}

- (IBAction)sync:(id)sender {
    
}

- (IBAction)addUrls:(id)sender {

    NSTextField *input = [[NSTextField alloc]
                          initWithFrame:NSMakeRect(0, 0, 350, 24*6)];
    input.delegate = self;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Add"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Add these urls."];
    [alert setAccessoryView:input];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] != NSAlertFirstButtonReturn)
        return;
    
    NSString* urlsStr = input.stringValue;
    [self addSomeUrls:urlsStr];
    [[self managedObjectContext] save:nil];
    [self reloadData];
    [self.urlTable reloadData];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:))
    {
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    else if (commandSelector == @selector(insertTab:))
    {
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }
    return result;
}

-(BOOL)findUrl:(NSString*)url {

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Url"
                inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"address == %@", url];
    [request setPredicate:predicate];
    
    NSError *error;
    NSInteger count = [[self managedObjectContext] countForFetchRequest:request error:&error];
    if (count>0)
        return YES;
    else
        return NO;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

    return [urlist count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    Url* url = [urlist objectAtIndex:rowIndex];
    if ([[aTableColumn identifier] isEqualToString:@"0"]) {
        return [url address];
    }else if ([[aTableColumn identifier] isEqualToString:@"1"]) {
        return [url title];
    }else if ([[aTableColumn identifier] isEqualToString:@"2"]) {
        return [url pagerank];
    }
    return nil;
}
@end
