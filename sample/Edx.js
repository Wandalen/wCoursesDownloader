
if( typeof module !== 'undefined' )
try
{
  require( 'wDownloaderOfCourses' );
}
catch( err )
{
  require( '../staging/atop/downloader/courses/Edx.s' );
}

var _ = wTools;
var dc = _.DownloaderOfCourses.Loader( 'Edx' );

dc.download();

// var con = new wConsequence().give();
//
// con.seal( cd )
// .ifNoErrorThen( cd._make )
// .ifNoErrorThen( cd._login )
// .ifNoErrorThen( cd._coursesList )
// .ifNoErrorThen( cd._coursePick,[ 0 ] )
// .ifNoErrorThen( cd._resourcesList )
// ;
//
// con.thenDo( function( err,got )
// {
//   if( err )
//   throw _.errLogOnce( err );
// });
