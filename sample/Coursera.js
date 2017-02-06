
if( typeof module !== 'undefined' )
try
{
  require( 'wDownloaderOfCourses' );
}
catch( err )
{
  require( '../staging/atop/downloader/courses/Coursera.s' );
}

var _ = wTools;
var dc = _.DownloaderOfCourses.Loader( 'Coursera' );

dc.download();
