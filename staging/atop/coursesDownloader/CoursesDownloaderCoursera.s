( function _CoursesDownloader_s_( ) {

'use strict';

// dependencies

if( typeof module !== 'undefined' )
{
  // require( 'wFiles' )

}

// constructor

var _ = wTools;
var Parent = wCoursesDownloader;
var Self = function wCoursesDownloaderCoursera( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'CoursesDownloaderCoursera';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

function _makeAct()
{
  var self = this;

  self.config.payload[ 'webrequest' ] =  true;
  self.config.options.json = true;
  self.config.options.body = self.config.payload;

}

//

function _makePrepareHeadersForLogin()
{
  var self = this;
  var con = Parent.prototype._makePrepareHeadersForLogin.call( self );

  /* */

  var randomstring = require( 'randomstring' );
  var csrftoken = randomstring.generate( 20 );
  var csrf2cookie = 'csrf2_token_' + randomstring.generate( 8 );
  var csrf2token = randomstring.generate( 24 )
  var cookies = `csrftoken=${csrftoken}; csrf2cookie=${csrf2cookie}; csrf2token=${csrf2token};`

  self.config.options.headers =
  {
    'Cookie' : cookies,
    'X-CSRFToken' : csrftoken,
    'X-CSRF2-Cookie' : csrf2cookie,
    'X-CSRF2-Token' : csrf2token,
    'Connection' : 'keep-alive'
  }

  return con;
}

//

function _coursesListActParse( body )
{
  var self = this;

  var data = JSON.parse( body );

  self.userData.courses = data.linked[ 'courses.v1' ];
}

//

function _coursesListAct()
{
  var self = this;
  var con = Parent.prototype._coursesListAct.call( self );

  if( !self.userData.courses )
  {
    if( self.verbosity )
    logger.log( 'Trying to get courses list.' );

    con = self._request
    ({
      url : self.config.getUserCoursesUrl,
      headers : self.config.options.headers
    })
    .thenDo( function( err, got )
    {
      if( err )
      throw _.errLogOnce( err );

      self._coursesListActParse( got.body );

      return got;
    });
  }

  /* */

  con.ifNoErrorThen( function()
  {

    if( self.verbosity )
    {
      var log = _.toStr( self.userData.courses,{ json : 1 } );
      logger.log( log );
    }

    con.give( self.userData.courses );
    self._coursesListAct.completed = true;
  });

  return con;
}

//

function _resourcesList( course )
{
  _.assert( _.objectIs( course ) );

  var self = this;

  var con = self._getResourcesList( course );

  if( self.verbosity )
  {
    con.ifNoErrorThen( function( resources )
    {
      logger.log( "Resources:\n", _.toStr( resources, { levels : 3 } ) );

      con.give( resources );
    });
  }

  return con;
}

//

function _getResourcesList( course )
{
  var self = this;

  var con = new wConsequence();

  logger.log( 'Trying to get resources for : ', course.name );

  if( self.userData.resources[ course.name ] )
  return con.give( self.userData.resources[ course.name ] );

  var postUrl = _.strReplaceAll( self.config.courseMaterials,'{class_name}', course.slug );

  self._request( postUrl )
  .thenDo( function( err, got )
  {
    if( err )
    err = _.err( err );

    if( got.response.statusCode !== 200 )
    err = _.err( "Failed to get resources list. StatusCode: ", got.response.statusCode, "Server response: ", got.body );

    if( err )
    return con.error( err );

    var data = JSON.parse( got.body );

    self.userData.resources[ course.name ] = data.courseMaterial;

    con.give( self.userData.resources[ course.name ] );
  });

  return con;
}

//

function makeDownloadsList( resources )
{
  var self = this;
  var con = new wConsequence().give();

  var chapters = resources.elements;

  chapters.forEach( function ( chapter )
  {
    chapter.elements.forEach( function ( lecture )
    {
      lecture.elements.forEach( function ( element )
      {
        if( element.content.typeName === 'lecture' )
        {
          var videoId = element.content.definition.videoId;
          var name = element.name;

          con.thenDo( _.routineSeal( self,self.getVideoUrl,[ videoId, "720p" ] ) )
          .ifNoErrorThen( function ( url )
          {
            self.userData.downloadsList.push( { name : name, url : url } );
          });
        }
      })
    });

  });

  return con;
}


function getVideoUrl( videoId, resolution )
{
  var self = this;
  var getUrl = _.strReplaceAll( self.config.getVideoApi,'{id}', videoId );

  var con = new wConsequence();

  self._request( getUrl )
  .thenDo( function( err, got )
  {
    if( err )
    err = _.err( err );

    if( got.response.statusCode !== 200 )
    err = _.err( "Failed to get resources list. StatusCode: ", got.response.statusCode, "Server response: ", got.body );

    if( err )
    return con.error( err );

    var data = JSON.parse( got.body );

    data.sources.forEach( function( source )
    {
      if( source.resolution == resolution )
      {
        var url = source.formatSources[ "video/mp4" ];
        return con.give( url );
      }
    })
  });

  return con;
}

// --
// relationships
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
  _requestAct : null,
}

var Restricts =
{
}

var Statics =
{
}

// --
// proto
// --

var Proto =
{

  init : init,

  _makeAct : _makeAct,
  _makePrepareHeadersForLogin : _makePrepareHeadersForLogin,

  _coursesListAct : _coursesListAct,
  _coursesListActParse : _coursesListActParse,

  _resourcesList : _resourcesList,
  _getResourcesList : _getResourcesList,

  makeDownloadsList : makeDownloadsList,
  getVideoUrl : getVideoUrl,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

};

// define

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});


// accessor

_.accessor( Self.prototype,
{
});

// readonly

_.accessorReadOnly( Self.prototype,
{
});

_.CoursesDownloader.registerClass( Self );

})();
