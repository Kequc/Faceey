var AttachablePanel = new Class({
  Implements: Options,
  options: {
    auto_url: true,
    picture_attachable: true
  },
  initialize: function(container, options) {
    this.setOptions(options);
    this.container = container;
    this.textarea_border = container.getElement('.text_area');
    this.textarea = container.getElement('textarea');
    this.url_regex = new RegExp(APP["link_regex"]);
    this.attachable_types = new Hash({
      "normal": new AttachableType(this, "normal", "Normal", 'button.gif'),
      "link": new AttachableType(this, "link", "Link", 'arrow_fat_right.gif')
    });
    if (this.options.picture_attachable) {
      this.attachable_types.combine(new Hash({
        "picture": new AttachableType(this, "picture", "Picture", 'image.gif'),
        "picture_url": new AttachableType(this, "picture_url", "Picture url", 'field_input.gif')
      }));
    }
    this.renderTypeSelect();
    this.boundParseUrl = this.parseUrl.bind(this);
    if (this.options.auto_url) {
      this.textarea.addEvent('keyup', this.boundParseUrl);
    }
  },
  fromTextarea: function(what, attachable_type, replacement) {
    attachable_type.element_input.set('value', what);
    attachable_type.activate();
    var value = this.textarea.get('value').replace(what, replacement);
    this.textarea.set('value', value).fireEvent('keyup');
  },
  parseUrl: function() {
    var text = this.textarea.get('value');
    var match = text.match(this.url_regex);
    if (match) {
      match = match[0];
      if (this.options.picture_attachable && match.test(APP["image_regex"], "i")) {
        var attachable_type = this.attachable_types.get("picture_url");
        this.fromTextarea(match, attachable_type, '');
      } else {
        var attachable_type = this.attachable_types.get("link");
        this.fromTextarea(match, attachable_type, '[link]');
      }
    }
  },
  deactivateAll: function() {
    this.attachable_types.each(function(attachable_type) {
      attachable_type.deactivate();
    });
  },
  renderTypeSelect: function() {
    var type_select = new Element("ul", {'class': "type_select"});
    this.attachable_types.each(function(attachable_type) {
      type_select.adopt(attachable_type.button);
    });
    type_select.inject(this.textarea_border, 'after');
  }
});

var AttachableType = new Class({
  initialize: function(panel, type_name, type_text, image) {
    this.panel = panel;
    this.element = panel.container.getElement('.t_'+type_name);
    if (this.element != undefined) {
      this.element_input = this.element.getElement('input');
    }
    this.type_name = type_name;
    this.type_text = type_text;
    this.image = image;
    this.button = new Element("li", {'class': "ts_"+this.type_name, title: this.type_text}).adopt(
      new Element("img", {alt: "", src: "/images/icons/"+this.image})
    ).addEvent('click', this.buttonClick.bind(this));
  },
  buttonClick: function() {
    this.activate();
  },
  activate: function() {
    this.panel.deactivateAll();
    this.button.addClass("current");
    if (this.element != undefined) {
      this.element_input.set('disabled', false);
      this.element.setStyle('display', 'block');
    }
    this.panel.textarea.removeEvent('keyup', this.panel.boundParseUrl);
  },
  deactivate: function() {
    this.button.removeClass("current");
    if (this.element != undefined) {
      this.element.setStyle('display', 'none');
      this.element_input.set('disabled', true);
    }
  }
});

var ProfileLink = new Class({
  initialize: function(shared) {
    this.thumbnail = shared.getElement('a.thumb, a.tiny');
    this.shared_by = shared.getElement('span.shared_by');
    if (this.thumbnail != undefined && this.shared_by != undefined) {
      this.thumbnail.addEvent('mouseover', this.addHover.bind(this));
      this.thumbnail.addEvent('mouseout', this.removeHover.bind(this));
    }
  },
  addHover: function() {
    this.shared_by.setStyle("text-decoration", 'underline');
  },
  removeHover: function() {
    this.shared_by.setStyle("text-decoration", 'none');
  }
});

var ResizableTextarea = new Class({
  initialize: function(textarea) {
    this.textarea = textarea;
    this.container = textarea.getParent('.textarea_autosize');
    this.textarea_border = textarea.getParent('.text_area');
    this.textarea.addEvent('keyup', this.activate.bind(this));
    this.textarea_border.addEvent('click', this.focusTextarea.bind(this));
    this.activate();
  },
  activate: function() {
    this.container.setStyle("height", (this.container.getHeight()-18) + 'px');
    this.textarea.setStyle("height", 0);
    this.textarea.setStyle("height", this.textarea.scrollHeight + 'px');
    this.container.setStyle("height", 'auto');
  },
  focusTextarea: function() {
    this.textarea.focus();
  }
});

Element.implement({
  toggle: function(event, fn, fn2){
    var flag = true;
    return this.addEvent(event, function() {
      (flag ? fn : fn2).apply(this, arguments);
      flag = !flag;
    });
  }
});

window.addEvent("domready", function() {
  
  // Resizable text areas
  $$('.textarea_autosize textarea').each(function(textarea) {
    new ResizableTextarea(textarea);
  });
  
  // Scroll to comment
  var comment_id = new URI(window.location).getData('comment_id');
  if (comment_id != undefined) {
    var position = $('comment_'+comment_id).getPosition();
    $('viewport').scrollTo(position.x, position.y);
  }
  
  // Form submission
  $$('form').each(function(form) {
    form.addEvent('submit', function() {
      this.getElements('input[type=submit]').each(function(submit_button) {
        submit_button.set('disabled', true);
        submit_button.set('value', 'Thinking...');
      });
    });
  });
  
  // All those crazy buttons near textareas
  $$('.attachable').each(function(attachable) {
    if (attachable.match('.add_comment')) {
      new AttachablePanel(attachable, {
        picture_attachable: false
      });
    } else {
      new AttachablePanel(attachable);
    }
  });
  
  // Hover profile links causes full name underline
  $$('.shared').each(function(shared) {
    new ProfileLink(shared);
  });
  
  // Nerf accessibility border feature on click
  $$('a').each(function(link) {
    link.addEvent('click', function() {
      this.blur();
    });
  });
  
});
  
// Preload
new Asset.images(['/images/lighten.png', '/images/lines.png']);
