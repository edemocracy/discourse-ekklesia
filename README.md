discourse-ekklesia
==================

Discourse plugin for integration with the [Ekklesia eDemocracy platform](https://github.com/edemocracy/ekklesia).

Features:

* OAuth2 login via Ekklesia's identity server
* automatic group / trust level assignment for users identified by the id server
* pushing motions to the Ekklesia portal ("Antrag stellen")

Planned Features:

* support for multiple id servers
* more configuration options, some server URLs are still hard-coded
* ... more to come


Installation
------------

### Production


For a standard docker installation:

Add to following line to the `hooks` section in your discourse container config:

    - git clone https://github.com/dpausp/discourse-ekklesia.git

Rebuild the docker container:

    ./launcher rebuild my_image


### Dev

Clone the plugin repository to your discourse plugin dir and restart:

    git clone https://github.com/dpausp/discourse-ekklesia.git 


Configuration
-------------

Everything can be configured in the Discourse admin area. You must at least set the client ID, client secret and the URL of the Ekklesia ID Server.
