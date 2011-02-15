/*
  GOODBOX
  Written for Faceey
  Requires Mootools, Mootools More (Drag, URI, Assets, Hash)
  [Love mootools]

  Goodbox might not have been possible without the software I am crediting now.
  viewboxAdvanced

  It was a lot of the original inspiration used to design this tool.
*/
/*
  this.viewboxAdvanced v1.3.4b - The ultimate extension of Slimbox and Mediabox; an all-this.view script
  updated 2010.09.21
  (c) 2007-2010 John Einselen <http://iaian7.com>
  based on Slimbox v1.64 - The ultimate lightweight Lightbox clone
  (c) 2007-2008 Christophe Beyls <http://www.digitalia.be>
  MIT-style license.
*/

var goodbox_defaults = {
  'player_width': 400,
  'player_height': 300,
  'player_path': '/swf/NonverBlaster.swf',
  'fullscreen': true,
  'content_padding': 20
};
var goodboxes = new Array();

var GoodBox = new Class({
  initialize: function(element) {
    this.element = element;
    this.uri = new URI(this.element.href);
    this.element.addEvent('click', this.gbOpen.bind(this));
    this.skip_gb = this.setContent();
    if (!this.skip_gb) {
      if (this.element.getElement('img.thumbnail') && this.view.get('type') != "image") {
        new Element("img", {
          src: '/images/play.png',
          'class': 'play',
          alt: ''
        }).inject(this.element);
      }
    }
  },
  gbOpen: function() {
    if (!this.skip_gb) {
      if (this.array_pos == undefined) {
        // Initialize box elements
        this.goodbox = new Element("div", {
          'class': "goodbox"
        }).adopt(
        this.box_content = new Element("div", {
          'class': "box_content"
        }).adopt(this.output),
        this.container = new Element("div", {
          'class': "container"
        }).addEvent("click", this.setFocus.bind(this)).adopt(
        this.fade = new Element("div").adopt(
        this.box_title = new Element("div", {
          'class': "box_title"
        }),
        this.box = new Element("div", {
          'class': "box"
        }).setStyles({
          width: 320,
          height: 180
        }),
        this.box_bottom = new Element("div", {
          'class': "box_bottom"
        })
        ),
        new Element("div", {
          'class': "close",
          'title': "Close"
        }).adopt(
        new Element("img", {
          alt: "x",
          src: "/images/close_goodbox.gif"
        })
        ).addEvent("click", this.gbClose.bind(this))
        )
        );
        // Create possible box title
        var title_text = "";
        var title_url = this.uri.toString();
        this.element.getChildren('div').each(function(le) {
          if (le.match('.title')) title_text = le.get('text');
          if (le.match('.url') && title_text == "") title_text = le.get('text');
          if (le.match('.original')) {
            title_text = "Upload source";
            title_url = le.get('html').toURI().toString();
          }
        });
        this.setTitle(title_text, title_url);
        // Create possible link to discussion
        this.source_id = this.element.getParent().get('id');
        var item = this.element.getParent().getElement('a.content');
        if (item) {
          var ils = item.getElement('.stub span.link');
          if (ils) {
            this.box_bottom.adopt(new Element("a", {
              html: ils.get('html'),
              href: item.get('href'),
              'class': "item_link"
            })
            );
          }
        }
        // Create effects
        this.fx_appear_fade = new Fx.Tween(this.fade, {
          property: "opacity",
          duration: 360
        }).set(0);
        this.fx_appear_box_content = new Fx.Tween(this.box_content, {
          property: "opacity",
          duration: 360
        }).set(0);
        var afterResize = function() {
          this.fx_appear_fade.start(1);
          this.fx_appear_box_content.start(1);
        };
        this.fx_resize = new Fx.Morph(this.goodbox, {
          duration: 240,
          onComplete: afterResize.bind(this)
        });
        // Open
        new Drag(this.goodbox.inject(document.body), {
          snap: 0,
          handle: this.container,
          onStart: this.setFocus.bind(this)
        });
      }
      this.goodbox.setStyles(this.getPosition());
      if (this.array_pos == undefined) {
        if (this.output != undefined) {
          this.gbAppear();
        } else if (this.view.get('type') == 'image') {
          function measureAppear() {
            this.view.set('width', image.width);
            this.view.set('height', image.height);
            this.output = new Element("img", this.standardOptions({
              src: this.view.get('url'),
              alt: "Image",
              events: {
                click: this.gbClose.bind(this)
              }
            }));
            this.box_content.adopt(this.output);
            this.gbAppear();
          };
          var image = new Asset.image(this.view.get('url'), {
            onLoad: measureAppear.bind(this)
          });
        }
      }
      this.setFocus();
      return false;
    } else {
      // Skip goodbox for this link.
      return true;
    }
  },
  gbClose: function() {
    this.container.removeEvents();
    goodboxes.splice(this.array_pos, 1);
    this.array_pos = undefined;
    this.fx_resize.cancel();
    this.fx_appear_fade.cancel();
    this.fx_appear_box_content.cancel();
    this.goodbox.dispose();
  },
  setTitle: function(title_text, title_url) {
    if (title_text != "") {
      this.box_title.adopt(
      new Element("a", {
        target: "_blank",
        html: title_text,
        href: title_url
      }).inject(this.fade, 'top')
      );
    }
  },
  setFocus: function() {
    // Move goodbox to end of goodboxes array
    if (this.array_pos != undefined) {
      goodboxes.splice(this.array_pos, 1)
    }
    goodboxes.push(this);
    // Assign z-index related to array position of each open goodbox
    goodboxes.each(function(open_goodbox, index) {
      open_goodbox.array_pos = index;
      open_goodbox.goodbox.setStyle('z-index', index + 101);
    });
  },
  setContentDimensions: function(w, h) {
    if (w != undefined) this.view.set('width', w);
    if (h != undefined) this.view.set('height', h);
  },
  swiffOptions: function(params) {
    return Object.append(this.standardOptions({
      params: {
        wmode: 'opaque',
        allowFullScreen: 'true',
        bgcolor: '#bbbbbb'
      }
    }), params);
  },
  iframeOptions: function(params) {
    return Object.append(this.standardOptions({
      src: this.getViewUrl(),
      frameborder: 0
    }), params);
  },
  standardOptions: function(params) {
    return Object.append({
      id: 'link_' + this.source_id,
      width: this.view.get('width'),
      height: this.view.get('height')
    },
    params);
  },
  setContent: function() {
    var host = this.uri.get('host');
    this.view = new Hash({
      'url': this.uri.toString()
    });
    this.setContentDimensions(goodbox_defaults.player_width, goodbox_defaults.player_height);

    if (this.uri.get('file').test(APP["image_regex"], "i")) {
      // Images
      this.view.set('type', 'image');
      // this.view.set('url', this.view.get('url').replace(/twitpic\.com/i, "twitpic.com/show/full"));
    } else if (host.test(/youtube\.com/i) && this.getViewData('v') != undefined) {
      // YouTube Video (now includes HTML5 option)
      this.setContentDimensions(640, 385);
      this.view.set('type', 'link');
      this.view.set('url', 'http://www.youtube.com/embed/' + this.getViewData('v'));
      this.view.set('query', {
        wmode: 'opaque',
        rel: 0
      });
      // TODO: YouTube Playlist
      // Playlist XML data http://gdata.youtube.com/feeds/api/playlists/67E9CED5E350B737
      // '67E9CED5E350B737' as PLAYLIST_ID
      // this.view.set('query', { wmode: 'opaque', autoplay: false, fs: 1, border: 0, color1: '0x000000', color2: '0x333333', rel: 0, showinfo: 1, showsearch: 0 });
      this.output = new IFrame(this.iframeOptions({
        }));
    } else if (host.test(/vimeo\.com/i) && this.uri.get('file').test(/\d+/)) {
      // Vimeo (now includes HTML5 option)
      this.setContentDimensions(640, 360);
      this.view.set('type', 'link');
      this.view.set('url', 'http://player.vimeo.com/video/' + this.uri.get('file'));
      this.output = new IFrame(this.iframeOptions({
        }));
    } else if (host.test(/dailymotion\.com/i) && this.getUrlDir(1) == "video") {
      // DailyMotion
      this.setContentDimensions(560, 315);
      this.view.set('url', 'http://www.dailymotion.com/swf/video/' + this.uri.get('file'));
      this.output = new Swiff(this.getViewUrl(), this.swiffOptions({
        }));
    } else if (host.test(/metacafe\.com/i) && this.getUrlDir(1) == "watch") {
      // Metacafe
      this.setContentDimensions(600, 370);
      this.view.set('url', 'http://www.metacafe.com/fplayer/' + this.getUrlDir(2) + '/' + this.uri.get('file') + '/.swf');
      this.output = new Swiff(this.getViewUrl(), this.swiffOptions({
        }));
    } else {
      // HTML
      // I am removing framed html pages cuz people hate dat.
      // this.setContentDimensions(window.getWidth()-100, window.getHeight()-200);
      // this.view.set('type', 'link');
      return true
    }
    return false
  },
  gbAppear: function() {
    var dimensions = {
      width: this.view.get('width'),
      height: this.view.get('height')
    };
    this.box.setStyles(dimensions);
    this.box_content.setStyles(dimensions);
    this.fx_resize.start(this.getPosition());
  },
  getPosition: function() {
    var top = window.getScrollTop() + (window.getHeight() / 2);
    var left = window.getScrollLeft() + (window.getWidth() / 2);
    var margin_left = this.box.getStyle('padding-left').toInt() + this.goodbox.getStyle('padding-left').toInt() + this.container.getStyle('padding-left').toInt();
    var margin_top = this.box.getStyle('padding-top').toInt() + this.goodbox.getStyle('padding-top').toInt() + this.container.getStyle('padding-top').toInt() + this.box_title.getStyle('height').toInt();
    // +2 is to account for 1px border on dynamically resized container
    var content_width = this.box.getStyle('width').toInt() + 2;
    var output = {
      top: top + 'px',
      left: left + 'px',
      marginTop: -(this.box.getStyle('height').toInt() / 2) - margin_top + 'px',
      marginLeft: -(content_width / 2) - margin_left + 'px',
      width: content_width + (goodbox_defaults.content_padding * 2) + 'px'
    };
    return output;
  },
  getViewData: function(param) {
    return this.uri.getData(param);
  },
  getUrlDir: function(index) {
    return this.uri.get('directory').split('/')[index];
  },
  getViewUrl: function() {
    output = new URI(this.view.get('url'));
    if (this.view.get('query') != undefined) output.setData(this.view.get('query'));
    return output.toString();
  }
});

window.addEvent("domready",
function() {

  // Goodboxes for all
  $$('a.gb').each(function(element) {
    new GoodBox(element);
  });
});
