
if( typeof module !== 'undefined' )
require( 'wdownloaderofcourses' );

var _ = wTools;
var dc = _.DownloaderOfCourses.Loader( 'Coursera' );

dc.download();
