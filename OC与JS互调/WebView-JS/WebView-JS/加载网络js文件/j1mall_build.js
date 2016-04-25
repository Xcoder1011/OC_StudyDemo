define('active', function() {
       var isInit = null, obj = {
       className:"elemActive",
       event : [],
       bind : function(ele, type, handle) {
       $(ele).bind(type, handle);
       this.event.push( {
                       "ele" : ele,
                       "type" : type,
                       "handle" : handle
                       })
       },
       destroy : function() {
       this.pop && this.pop.remove();
       $.each(this.event, function(i, n) {
              $(n.ele).unbind(n.type, n.handle);
              });
       isInit = null;
       },
       init : function(elem) {
       if (!isInit) {
       this.destroy();
       isInit = true;
       obj.setEvent();
       }
       $(elem).addClass(this.className);
       },
       start : function(e) {
       var src = this.getTargetEvent(e);
       if (src.elem && this.pop) {
       var p = $(src.elem).offset();
       this.pop.css({"left": p.left,"top": p.top,"width":src.elem.offsetWidth,"height":src.elem.offsetHeight});
       this.pop.show();
       }
       },
       end : function(e) {
       this.pop && this.pop.hide();
       },
       setEvent : function(elem) {
       var longTapTimeout = null, $win = $(document), self = this, longTapDelay = 700;
       function longTap(e) {
       self.start(e);
       }
       function cancelLongTap() {
       if (!longTapTimeout){
       return;
       }
       clearTimeout(longTapTimeout)
       self.end();
       longTapTimeout = null;
       }
       
       this.pop = $("<div class='pop"+ this.className +"'>").appendTo($(HYFramework.config.hybody));
       this.pop.attr("style", "position: absolute;z-index: 5;background-color: rgba(0,0,0,0.15);");
       
       var supportTouch = "ontouchend" in document;
       var touchStartEvent = supportTouch ? "touchstart" : "mousedown",
       touchStopEvent = supportTouch ? "touchend" : "mouseup",
       touchMoveEvent = supportTouch ? "touchmove" : "mousemove";
       this.bind($win, touchStartEvent, function(e) {
                 longTapTimeout = setTimeout(function(){
                                             longTap(e);
                                             }, longTapDelay)
                 })
       this.bind($win, touchMoveEvent, function(e) {
                 cancelLongTap();
                 })
       this.bind($win, touchStopEvent, function(e) {
                 cancelLongTap();
                 })
       this.bind($win, "scroll", function(e) {
                 cancelLongTap();
                 })
       this.bind($win, "click", function(e) {
                 self.start(e);
                 })
       },
       getTargetEvent : function(e) {
       var obj = (e.target || e.srcElement);
       var jobjs = $(obj).parents().add(obj);
       var fn = function(parm) {
       for ( var i = 0, l = jobjs.length; i < l; i++) {
       if ($(jobjs[i]).hasClass(parm)) {
       return jobjs[i];
       }
       }
       return null;
       };
       return {
       elem : fn(this.className),
       }
       }
       }
       var t = function(elem) {
       if (!elem)
       return;
       obj.init(elem);
       }
       t.destroy = function() {
       obj.destroy();
       }
       return t;
       })