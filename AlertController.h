@interface alertController : NSObject <LAListener>
{
    NSMutableArray *eventArray;
}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle;
- (void)removeAlertFromArray:(alertDataController *)alert;
- (void)saveArray;
- (void)updateSize;

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;

//@property (nonatomic, retain) NSMutableArray *eventArray;

@end
