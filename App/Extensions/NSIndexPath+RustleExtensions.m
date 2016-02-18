// Rustle
// @author: Slipp Douglas Thompson

#import "NSIndexPath+RustleExtensions.h"



@implementation NSIndexPath (GTExtensions)


- (NSUInteger)innermostIndex
{
	@synchronized(self) {
		return [self indexAtPosition:(self.length - 1)];
	}
}

- (NSUInteger)outermostIndex
{
	@synchronized(self) {
		return [self indexAtPosition:0];
	}
}


@end
