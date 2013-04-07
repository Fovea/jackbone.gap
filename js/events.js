/**
 * @fileoverview Wrapper for backbone events.
 */
define([
  'jquery',
  'underscore',
  'backbone'
], function($, _, Backbone){
/** 
* @class [events] Central Events Dispatcher.
* @name Events
* @constructor
* @description
* Events is the central dispatcher of events, allowing modules to communicate with each other.
*
* Bellow is the raw list of events triggered by the application.
* <ul>
* <li><b>add:needSync</b> <ul><li>Triggered by Controllers when some synchronized elemenst have been changed locally.</li></ul></li>
* <li><b>app:offline</b> <ul><li>Triggered by Synchronizer when he can't contact the server.</li></ul></li>
* <li><b>app:ready</b> <ul><li>Triggered by Synchronizer when done retrieving all updates.</li></ul></li>
* <li><b>change:&lt;cid&gt;</b> <ul><li>Triggered by collections/models whenever element with &lt;cid&gt; changed.</li></ul></li>
* <li><b>change:download</b>(<i>percent</i>) <ul><li>Triggered by Synchronizer while retrieving updates.</li></ul></li>
* <li><b>change:logs</b> <ul><li>Triggered by Logger when new logs are available.</li></ul></li>
* <li><b>change:pagecid</b>(<i>componentCID, reportCID</i>) <ul><li>Triggered by the ViewManager when a page is opened.</li></ul></li>
* <li><b>change:upload</b>(<i>percent</i>) <ul><li>Triggered by Synchronizer while publishing updates.</li></ul></li>
* <li><b>change:viewers</b>(<i>list</i>) <ul><li>Triggered by Viewers when the list of viewers for current page changes.</li></ul></li>
* <li><b>connection:ko</b> <ul><li>Triggered by Synchronizer or Viewers when an Ajax request fails.</li></ul></li>
* <li><b>connection:nt</b> <ul><li>Triggered by Synchronizer when connection with server is in an unknown state.</li></ul></li>
* <li><b>connection:ok</b> <ul><li>Triggered by Synchronizer or Viewers when an Ajax request is successful.</li></ul></li>
* <li><b>database:busy</b> <ul><li>Triggered by Database when requests are being performed.</li></ul></li>
* <li><b>database:ko</b> <ul><li>Triggered by Database when a request fails.</li></ul></li>
* <li><b>database:ok</b> <ul><li>Triggered by Database when a request is successful.</li></ul></li>
* <li><b>ui:disable</b> <ul><li>Triggered by Controllers when an long operation is in progress, to prevent user interactions.</li></ul></li>
* <li><b>ui:enable</b> <ul><li>Triggered by Controllers to enable user interactions (usually follows 'ui:disable').</li></ul></li>
* <li><b> </b>(<i> </i>) <ul><li>Triggered by X when Y.</li></ul></li>
* </ul>
*/
  var Events = _.extend({}, Backbone.Events);
  return Events;
});
