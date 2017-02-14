if( typeof module !== 'undefined' )
require( '../staging/atop/downloader/ResourceFormat.s' );

var _ = wTools;


function onAttempt( target )
{
  var self = this;

  if( target )
  {
    if( self.availableFormats.indexOf( target ) != -1 )
    return true;

    return false;
  }

  return self.availableFormats;
}

var Downloader =
{
  availableFormats : [ '1080p', '720p' ],
  resourceFormatAllowed : [ '360p', null ],
  resourceFormatPreffered : [ null ],
  onAttempt : onAttempt
}

var rf = _.ResourceFormat( { target : Downloader, allowedName : 'resourceFormatAllowed', prefferedName : 'resourceFormatPreffered' } );
rf.make()
.thenDo( function( err, got )
{
  if( err )
  throw _.err( err );

  console.log( "Selected formats : ", got );
})
