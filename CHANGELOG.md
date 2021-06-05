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

[v2.1.0](https://github.com/teamsnap/teamsnap_rb/pull/97)
------

- Add in the ability to specify a header option when creating a new client.  This feature is primarily to be used to support feature flags.

[v2.1.1](https://github.com/teamsnap/teamsnap_rb/pull/99)
------

- Update some of the out of date gem dependencies.

[v2.1.2](https://github.com/teamsnap/teamsnap_rb/pull/103)
------

- Update plural inflection for `partner_preferences`

[v2.1.3](https://github.com/teamsnap/teamsnap_rb/pull/106)
------

- Update Rack dependency to patch CVE-2018-16471

[v2.2.0](https://github.com/teamsnap/teamsnap_rb/pull/108)
------

- Require Ruby version 2.3+

[v2.3.0](https://github.com/teamsnap/teamsnap_rb/pull/107)
------

- Update faraday dependency to version 0.15
- Update oj dependency to version 3

[v2.3.1](https://github.com/teamsnap/teamsnap_rb/pull/110)
------

- Update bundler from 1.15 to 1.17
- Update typhoeus from 1.1 to 1.3
- Update rspec from 3.6 to 3.8
- Update vcr from 2.9 to 5.0

[v2.4.0](https://github.com/teamsnap/teamsnap_rb/pull/111)
------

- Remove Oj gem dependency
- Update faraday dependency to allow version 0.17

[v2.4.1](https://github.com/teamsnap/teamsnap_rb/pull/118)
------

- Fix bug with json gem not parsing empty resopnse body
- Fix bug with OpenSSL on Ruby 2.5+
- Fix deprecation on ::Fixnum constant


[v2.5.0](https://github.com/teamsnap/teamsnap_rb/pull/128)
------

- Drop support for Ruby 2.3
- Switch from [Inflecto (discontinued)](https://github.com/mbj/inflecto) to [dry-inflector](https://github.com/dry-rb/dry-inflector)
