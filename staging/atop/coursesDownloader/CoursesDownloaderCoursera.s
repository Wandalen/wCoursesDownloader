( function _CoursesDownloader_s_( ) {

'use strict';

// dependencies

if( typeof module !== 'undefined' )
{
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
  var con = new wConsequence();

  self.config.payload[ 'webrequest' ] =  true;
  self.config.options.json = true;
  self.config.options.body = self.config.payload;
  con.give();

  return con;
}

//

function _loginPrepareHeaders()
{
  var self = this;
  var con = Parent.prototype._loginPrepareHeaders.call( self );

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

function _parseCourses( body )
{
  var self = this;

  var data = JSON.parse( body );

  self.userData.courses = data.linked[ 'courses.v1' ];
}

//

function _coursesListAct()
{
  var self = this;
  var con = new wConsequence().give();

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

      self._parseCourses( got.body );

      return got;
    });
  }

  con.ifNoErrorThen( function()
  {
    if( self.verbosity )
    {
      var courses = _.toStr( self.userData.courses,{ json : 1 } );
      logger.log( courses );
    }

    con.give( self.userData.courses );
  });

  return con;
}

//

function _resourcesList( course )
{
  _.assert( _.objectIs( course ) );
  var self = this;

  var con = Parent.prototype._loginPrepareHeaders.call( self );

  logger.log( 'Trying to get resources for : ', course.name );

  if( self.userData.resources[ course.name ] )
  {
    if( self.verbosity )
    logger.log( "Resources:\n", _.toStr( self.userData.resources[ course.name ], { json : 1 } ) );

    return con.give( self.userData.resources[ course.name ] );
  }

  var postUrl = _.strReplaceAll( self.config.courseMaterials,'{class_name}', course.slug );

  return self._request( postUrl )
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

    if( self.verbosity )
    logger.log( "Resources:\n", _.toStr( data.courseMaterial, { json : 1 } ) );

    con.give( self.userData.resources[ course.name ] );
  });

  return con;
}

// --
// relationships
// --

var Composes =
{
  verbosity : 1,
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

  /* !!! where is make? */

  _makeAct : _makeAct,
  _loginPrepareHeaders : _loginPrepareHeaders,

  /* !!! _getUserCoursesAct and _coursesListAct, why two methods for the same problem? */

  _parseCourses : _parseCourses,
  _coursesListAct : _coursesListAct,
  _resourcesList : _resourcesList,


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
