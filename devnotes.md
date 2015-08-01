Tips, Reminders and Code Snippets
=================================

Discourse Plugins
-----------------

* [basic plugin guide by eviltrout](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins/30515)
* [custom admin settings for plugins](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins-part-3-custom-settings/31115)
* automatic reload doesn't work for plugin code
* using CTRL-F5 is important when making changes to plugins (picking up automatically generated js code, for example)


Ruby
----

* [pry: interactive ruby console](http://pryrepl.org/)
* [rubocop: static ruby code analysis / lint](http://pryrepl.org://github.com/bbatsov/rubocop)


Ember
-----

* [ember inspector for firefox](https://addons.mozilla.org/de/firefox/addon/ember-inspector/)


SSL
---

SSL client certs for omniauth (faraday HTTP lib):

~~~ruby
:ssl => {
  :client_cert => OpenSSL::X509::Certificate.new(File.read('/home/vagrant/discourse.pem')),
  :client_key => OpenSSL::PKey::RSA.new(File.read('/home/vagrant/discourse.key'))
}
~~~
