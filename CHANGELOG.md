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
