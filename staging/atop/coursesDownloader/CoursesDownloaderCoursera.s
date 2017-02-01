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

  return con.give();
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
  });

  return con;
}

//

function _coursesListActParse( body )
{
  var self = this;

  var data = JSON.parse( body );

  self.userData.courses = data.linked[ 'courses.v1' ];
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

  _loginPrepareHeaders : _loginPrepareHeaders,

  _coursesListAct : _coursesListAct,
  _coursesListActParse : _coursesListActParse,

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
