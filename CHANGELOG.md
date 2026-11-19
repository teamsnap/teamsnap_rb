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

v1.3.4
------

- Update to support the latest Oj v2 (2.18.5)

v1.3.5
------

- Raise a `TeamSnap::NotFound` error when the API returns a 404 status.

v1.3.6
------

- Fix undefined method `return_message` when the API returns an error.

v1.3.7
------

- Support Ruby 3: relax faraday to `~> 0.17.6` (0.9.x fails on Ruby 3 with
  "tried to create Proc object without a block") and typhoeus to `~> 1.4.0`.
  typhoeus 1.5+ ships a Faraday adapter that needs Faraday 1.x options, so it
  stays on 1.4.x. oj stays at `~> 2.18.5`, which builds and loads on Ruby 3.3.
