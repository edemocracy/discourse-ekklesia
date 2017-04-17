// Provide a link to push the first post in a topic to the Ekklesia portal as a motion.

import { h } from 'virtual-dom';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { iconNode } from 'discourse/helpers/fa-icon-node';


function addPushMotionLink(api) {
  api.decorateWidget('post:before', (helper) => {
    const post = helper.attrs;

    if (post.firstPost) {
      const title = encodeURIComponent(post.topic.title);
      const post_id = post.id;
      const portal_url = "https://abstimmung.piratenpartei.ch";
      const import_url = portal_url + `/questions/new?source=discourse_pps&from_data=${post_id}`;
      const label = I18n.t('ekklesia.push_motion');
      const icon = iconNode('file-text-o'); 
      return h('a', {href: import_url, target: 'ekklesia_portal'}, [icon, " ", label]);
    };
  });
};

function addChangePasswordLink(api) {
  api.decorateWidget('user-menu-links:after', (helper) => {
    const change_pw_url = "https://id.piratenpartei.ch/password";
    const label = I18n.t('ekklesia.change_id_password');
    const icon = iconNode('key'); 
    const link = h('a.widget-link.change-id-password', {href: change_pw_url, target: 'ekklesia_id'}, [icon, " ", label]);
    return link;
  });
};


function initializePlugin(api) {

  api.includePostAttributes('topic');
  api.includePostAttributes('topic.title');
  addPushMotionLink(api);
  addChangePasswordLink(api);
};


export default {
  name: 'ekklesia-post-menu',
  initialize() {
    withPluginApi('0.1', api => initializePlugin(api))
  }
}
