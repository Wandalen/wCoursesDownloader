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

function _loginAct()
{
  var self = this;

  self.config.payload[ 'webrequest' ] =  true;
  self.config.options.json = true;
  self.config.options.body = self.config.payload;

}

//

function _prepareHeadersAct()
{
  var self = this;
  var con = new wConsequence();

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

  con.give();

  return con;
}

//

function _getUserCoursesAct()
{
  var self = this;

  logger.log( 'Trying to get courses list.' );

  return self._request
  ({
    url : self.config.getUserCoursesUrl,
    headers : self.config.options.headers
  })
  .thenDo( function( err, got )
  {
    if( err )
    throw _.errLogOnce( err );

    self.userData.courses = got.body;

    return got;
  });

}

//

function _coursesListAct()
{
  var self = this;
  var con = new wConsequence();

  var data = JSON.parse( self.userData.courses );

  self.userData.courses = data.linked[ 'courses.v1' ];
  logger.log( 'Courses list : \n' );

  self.userData.courses.forEach( function( element )
  {
    logger.log( 'element',element );
    logger.log( 'name : ', element.name, ' class_name : ', element.slug, '\n' );
  });

  con.give();

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

  _loginAct : _loginAct,
  _prepareHeadersAct : _prepareHeadersAct,

  /* !!! _getUserCoursesAct and _coursesListAct, why two methods for the same problem? */

  _getUserCoursesAct : _getUserCoursesAct,
  _coursesListAct : _coursesListAct,


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
