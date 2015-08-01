discourse-ekklesia
==================

Discourse plugin for integration with the [Ekklesia eDemocracy platform](https://github.com/edemocracy/ekklesia).

Features:

* OAuth2 login via Ekklesia's identity server
* automatic group / trust level assignment for users identified by the id server

Planned Features:

* support for multiple id servers
* pushing motions to the Ekklesia portal ("Antrag stellen")
* ... more to come


Installation
------------

### Production


For a standard docker installation:

Add to following line to the `hooks` section in your discourse container config:

    - git clone https://github.com/ekklesia/discourse-ekklesia.git

Rebuild the docker container:

    ./launcher rebuild my_image


### Dev

Clone the plugin repository to your discourse plugin dir and restart:

    git clone https://github.com/ekklesia/discourse-ekklesia.git 


Configuration
-------------

TODO
