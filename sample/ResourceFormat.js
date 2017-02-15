if( typeof module !== 'undefined' )
require( '../staging/atop/downloader/ResourceFormat.s' );

var _ = wTools;


// function onAttempt( target )
// {
//   var self = this;
//
//   if( target )
//  {
//    var result = _.entitySelect({ container : self.video, query : target });
//
//    if( target )
//    return true;
//
//    return false;
//  }
//
//  return [ self.video ];
// }

// function onAttempt( target )
// {
//   var self = this;
//
//
//   return _.timeOut(500)
//   .thenDo(function()
//   {
//     if( target )
//    {
//      var result = _.entitySelect({ container : self.video, query : target });
//
//      if( target )
//      return true;
//
//      return false;
//    }
//
//    return [ self.video ];
//   })
// }

function onAttempt( a, b )
{
  var self = this;


  return _.timeOut(500)
  .thenDo(function()
  {
    if( !a || !b )
    return [ self.video ];

    var query = a;

    if( self.videoVaryFirst === 'resolution' )
    {
      query = b;
      b = a;
    }

    var result = _.entitySelect({ container : self.video, query : query });

    if( !result )
    return false;

    if( result.indexOf( b ) != -1 )
    return true;

  })
}

var Downloader =
{
  video :
  {
    '720p' :
    [
      'mp4',
      'webm'
    ],
    '360p' :
    [
      'mp4',
      'webm'
    ],
    '540p' :
    [
      'mp4',
      'webm'
    ],
  },

  videoResolutionAllowed : [ '720p', '360p', '540p' ],
  videoResolutionPreffered  : [ '720p','360p' ],
  // videoResolutionAllowed : [ null ],
  // videoResolutionPreffered  : [ null ],

  videoFormatAllowed : [ 'mp4','webm' ],
  videoFormatPreffered  : [ 'mp4','webm' ],
  // videoFormatAllowed : [ null ],
  // videoFormatPreffered  : [ null ],

  videoVaryFirst : 'format',

  onAttempt : onAttempt
}

var o =
{
  target : Downloader,
  allowedName : 'videoFormatAllowed',
  prefferedName : 'videoFormatPreffered'
}

if( Downloader.videoVaryFirst === 'format' )
{
  o.allowedName = 'videoResolutionAllowed';
  o.prefferedName = 'videoResolutionPreffered';
  o.dependsOf =
  {
    allowedName : 'videoFormatAllowed',
    prefferedName : 'videoFormatPreffered'
  }
}
if( Downloader.videoVaryFirst === 'resolution' )
{
  o.allowedName = 'videoFormatAllowed';
  o.prefferedName = 'videoFormatPreffered';
  o.dependsOf =
  {
    allowedName : 'videoResolutionAllowed',
    prefferedName : 'videoResolutionPreffered'
  }
}

var rf = _.ResourceFormat( o );
debugger;
rf.make()
.thenDo( function( err, got )
{
  if( err )
  throw _.err( err );

  console.log( "Selected formats : ", got );
})
