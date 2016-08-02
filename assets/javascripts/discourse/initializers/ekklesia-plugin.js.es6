// Provide a link to push the first post in a topic to the Ekklesia portal as a motion.

import { h } from 'virtual-dom';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { iconNode } from 'discourse/helpers/fa-icon';


function addPushMotionLink(api) {
  api.decorateWidget('post:before', (helper) => {
    const post = helper.attrs;

    if (post.firstPost) {
      console.log("ekklesia push motion button created from plugin!");
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



function initializePlugin(api) {

  api.includePostAttributes('topic');
  api.includePostAttributes('topic.title');
  addPushMotionLink(api);
};


export default {
  name: 'ekklesia-post-menu',
  initialize() {
    withPluginApi('0.1', api => initializePlugin(api))
  }
}
