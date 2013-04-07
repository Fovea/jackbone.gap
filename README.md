Jackbone.gap
============

A Web and PhoneGap javascript application manager.

(c)2013, [Jean-Christophe Hoelt](mailto:hoelt@fovea.cc), Fovea.cc

##Install

  * Download Jackbone.gap
  * Put it wherever your like on your system
    * Something like `/usr/local/jackbone` will do it.
  * Add jackbone.gap directory in your PATH

##Usage

Type `jackbone help` for full usage.

##Anatomy of a Jackbone.gap application

```
+ config                 -- Jackbone.gap config file.
+ app/js/appdelegate.js  -- Entry point of the javascript application.
+ app/css/main.css       -- Your LessCSS CSS.
+ app/html/*.html        -- Your Handlebars templates
+ assets/Default.png     -- Splash image
+ assets/Icon.png        -- Icon image
```

##License

Jackbone.gap is distributed under the MIT License.

##Third party libraries and tools

It is based on a stack of open-source software:
  * Jackbone.js
  * JQuery Mobile
  * Handlebars
  * LessCSS
  * Backbone.js
  * Underscore.js
  * QUnit
  * Kinetic
  * SQLite
  * Stacktrace.js
