// Provide a post menu button to push the first post in a topic to the Ekklesia portal as a motion.
// This button can be activated by adding 'ekklesia-push-motion' to the post_menu setting.

import { iconHTML } from 'discourse/helpers/fa-icon';
import PostMenuComponent from 'discourse/components/post-menu';


export const ExternalLinkButton = function(url, label, icon, opts) {
  this.url = url;
  this.label = label;
  this.icon = icon;
  this.opts = this.opts || opts || {};
  this.target = "_blank";
};


ExternalLinkButton.prototype.render = function(buffer) {
  const opts = this.opts;
  const label = I18n.t(this.label, opts.labelOptions);

  buffer.push(`<a href="${this.url}" target="${this.target}" title="${label}" style="padding: 8px 10px">`);
  if (this.icon) { buffer.push(iconHTML(this.icon)); }
  buffer.push(`</a>`);
};


export function initialize(application) {
  PostMenuComponent.reopen({
      buttonForEkklesiaPushMotion(post) {
          if (post.get('post_number') === 1) {
            console.log("ekklesia push motion button created from plugin!");
            const url = window.location.protocol + "//" + window.location.host + "/posts/" + post.get('id');
            const title = encodeURIComponent(post.get('topic.title'));
            const from_url = encodeURIComponent(url);
            const import_url = `https://abstimmung.piratenpartei.ch/new?from_format=discourse_post&from_url=${from_url}&title=${title}`;
            return new ExternalLinkButton(import_url, 'ekklesia.push_motion', 'file-text-o');
          }
      }
  });
};
  

export default {
  name: 'ekklesia-post-menu',
  initialize: initialize
};
