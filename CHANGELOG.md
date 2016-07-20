MASTER
------

-

v1.1.0
------

- Fixed a namespacing issue that would try and user classes already defined by
  the user if they shared a name with TeamSnap classes.

v1.3.3
------

- Have the ability to search for a /schemas endpoint and create the collections
  off of the schema endpoint instead of hitting each endpoint individually

v2.0.0.beta
------

- Full CRUD actions available along with TeamSnap::Response option for better
  control-flow statements.

v2.0.0.beta6
------

- Handle errors when response body is an empty string

v2.0.0.beta7
------

- Add attibutes to an Item if it's missing them

v2.0.0.beta10
------

- Allow uploading of Files or Tempfiles

v2.0.0.beta11
------

- Allow uploading Rack::Test::UploadFile for testing purposes