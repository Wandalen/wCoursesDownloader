if( typeof module !== 'undefined' )
require( '../staging/atop/downloader/ResourceFormat.s' );

var _ = wTools;


// function onAttempt( target )
// {
//   var self = this;
//
//   if( target )
//   {
//     if( self.availableFormats.indexOf( target ) != -1 )
//     return true;
//
//     return false;
//   }
//
//   return self.availableFormats;
// }
function onAttempt( target )
{
  var self = this;

  return _.timeOut(500)
  .thenDo(function()
  {
    if( target )
    {
      if( self.availableFormats.indexOf( target ) != -1 )
      return true;

      return false;
    }
    return self.availableFormats;
  })
}

var Downloader =
{
  availableFormats : [ '720p','360p' ],
  resourceFormatAllowed : [ '720p',null ],
  resourceFormatPreffered : [ '1080p', null ],
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
