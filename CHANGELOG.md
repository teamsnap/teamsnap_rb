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

v2.0.0.beta12
------

- Use different criteria to determine if a :put, :patch is a multipart upload.

v2.0.0.beta13
------

- Allow loading of root items with a client.

v2.0.0.beta14
------

- Fix so that OJ can properly parse ActiveSupport::TimeWithZone.

v2.0.0
------

- Drop support for Ruby < 2. Updates rspec gem. Drops beta tag.

[v2.0.1](https://github.com/teamsnap/teamsnap_rb/pull/97)

- Add in the ability to specify a the header option when creating a new client.  This feature is primarily to be used to support feature flags.
