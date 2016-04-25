function createAsync(a) {
    var b = document,
    c = "script",
    d = b.createElement(c);
    d.async = 1;
    for (var e in a) d.setAttribute(e, a[e]);
    var f = b.getElementsByTagName(c)[0];
    f.parentNode.insertBefore(d, f)
}
function loadGAForGoogle() { !
    function(a, b, c, d, e, f, g) {
        a.GoogleAnalyticsObject = e,
        a[e] = a[e] ||
        function() { (a[e].q = a[e].q || []).push(arguments)
        },
        a[e].l = 1 * new Date,
        f = b.createElement(c),
        g = b.getElementsByTagName(c)[0],
        f.async = 1,
        f.src = d,
        g.parentNode.insertBefore(f, g)
    } (window, document, "script", "//www.google-analytics.com/analytics.js", "ga"),
    ga("create", "UA-51643558-1", "auto"),
    ga("send", "pageview")
}
function loadGAForJ1() {
    createAsync({
                src: "http://cj.j1.com/js/ga/ga_head.js?v=52b2db2"
                }),
    createAsync({
                src: "//ga.j1.com/js/ana.js"
                })
}
function loadQQJS() {
    createAsync({
                src: "//qzonestyle.gtimg.cn/qzone/openapi/qc_loader.js",
                "data-callback": "true",
                "data-appid": "100294640",
                "data-redirecturi": "http://m.j1.com",
                async: !1
                })
}
function loadAsyncGA() {
    var a = function() {
        loadQQJS(),
        loadGAForJ1(),
        loadGAForGoogle()
    };
    "complete" == document.readyState ? a() : document.onreadystatechange = function() {
        "complete" == document.readyState && a()
    }
}
define("log",
       function() {
       var a = {
       category: {
       DEBUG: 1,
       INFO: 2,
       WARN: 3,
       ERROR: 4,
       FATAL: 5,
       NONE: 6
       },
       setLogger: function(a) {
       a && (c = a)
       },
       setLevel: function(a) {
       if (void 0 != a) {
       if ("number" == typeof a) return void(b = a);
       switch (a.toLowerCase()) {
       case "debug":
       b = this.category.DEBUG;
       break;
       case "info":
       b = this.category.INFO;
       break;
       case "error":
       b = this.category.ERROR;
       break;
       case "fatal":
       b = this.category.FATAL;
       break;
       case "warn":
       b = this.category.WARN;
       break;
       default:
       b = this.category.NONE
       }
       }
       },
       getLogger: function() {
       return c
       },
       getLevel: function() {
       return b
       },
       _log: function(a, b, c) {
       this[this.getLogger() + "Logger"](this.format(a), b, c)
       },
       debug: function(a) {
       this.getLevel() <= this.category.DEBUG && this._log(a, "DEBUG", this)
       },
       info: function(a) {
       this.getLevel() <= this.category.INFO && this._log(a, "INFO", this)
       },
       warn: function(a) {
       this.getLevel() <= this.category.WARN && this._log(a, "WARN", this)
       },
       error: function(a) {
       this.getLevel() <= this.category.ERROR && this._log(a, "ERROR", this)
       },
       fatal: function(a) {
       this.getLevel() <= this.category.FATAL && this._log(a, "FATAL", this)
       },
       alertLogger: function(a, b) {
       alert(b + " - " + a)
       },
       writeLogger: function(a, b) {
       document.writeln(b + "&nbsp;-&nbsp;" + a + "<br/>")
       },
       consoleLogger: function(b, c, d) {
       window.console ? window.console.log(c + " - " + b) : a.popupLogger(b, c, d)
       },
       path: "http://172.31.10.102:8080/log/servlet/Log",
       serveLogger: function(a, b) {
       var c = new Image;
       c.src = this.path + (this.path.match(/\?/) ? "&": "?") + "msg='" + encodeURIComponent(b + "---" + a) + "'"
       },
       nodeLogger: function(a, b) {
       var c = new XMLHttpRequest;
       c.open("POST", "Log.log", !1),
       c.setRequestHeader("Content-Type", "application/x-www-form-urlencoded"),
       c.send("msg=" + encodeURIComponent(a))
       },
       winLogger: function(a, b) {
       if (this.win) this.win.innerHTML += "<p>" + b + "&nbsp;-&nbsp;" + a + "<br></p>";
       else {
       var c = document.createElement("div"),
       d = document.createElement("div"),
       e = document.createElement("span"),
       f = document.createElement("cite");
       this.win = d,
       d.id = "logtext",
       c.className = "logDiv",
       c.appendChild(d),
       e.innerHTML = "open",
       e.b = !1,
       c.appendChild(e),
       f.innerHTML = "empty",
       c.appendChild(f),
       document.body.appendChild(c),
       e.onclick = function() {
       var a = this,
       b = a.parentNode;
       b.style.left = a.b ? "-100%": "0",
       f.style.left = a.style.left = a.b ? "100%": "0",
       a.innerHTML = a.b ? "open": "close",
       a.b = !a.b
       },
       f.onclick = function() {
       d.innerHTML = ""
       },
       this.winLogger(a, b)
       }
       },
       popupLogger: function(a, b, c) {
       if (!c.popupBlocker) {
       if (!c._window || !c._window.document) {
       if (c._window = window.open("", "logger_popup_window", "width=420,height=320,scrollbars=1,status=0,toolbars=0,resizable=1"), !c._window) return c.popupBlocker = !0,
       void alert("寮瑰嚭鐨勭獥鍙ｆ棩蹇楄闃绘锛岃瑙ｉ櫎闃绘");
       c._window.document.getElementById("loggerTable") || (c._window.document.writeln("<table width='100%' id='loggerTable'><tr><th>Time</th><th width='100%' colspan='2'>Message</th></tr></table>"), c._window.document.close())
       }
       var d = c._window.document.getElementById("loggerTable"),
       e = d.insertRow( - 1),
       f = e.insertCell( - 1),
       g = e.insertCell( - 1),
       h = e.insertCell( - 1);
       f.innerHTML = this.getTime(),
       g.innerHTML = b,
       h.innerHTML = a
       }
       },
       getTime: function() {
       var a = new Date,
       b = a.getHours();
       10 > b && (b = "0" + b);
       var c = a.getMinutes();
       10 > c && (c = "0" + c);
       var d = a.getSeconds();
       return 10 > d && (d = "0" + d),
       a.getFullYear() + "/" + (a.getMonth() + 1) + "/" + a.getDate() + "&nbsp;-&nbsp;" + b + ":" + c + ":" + d
       },
       format: function(a) {
       if ("object" != typeof a) return a;
       var b = ["{\n"];
       for (var c in a) b.push(c + ":"),
       b.push("object" == typeof a[c] ? this.format(a[c]) : a[c]),
       b.push("\n");
       return b.push("}"),
       b.join(" ")
       }
       },
       b = a.category.DEBUG,
       c = "node";
       return a
       });
var moduleConfig = {
activity: {},
mall: {},
    "native": {}
};
if (window.onerror = function(a, b, c, d, e) {
    require(["log"],
            function(f) {
            try {
            var g = "window.onerror: {0} js: {1} line: {2} column: {3} errorObj: {4} forUrl: {5}".format(a, b, c, d, e, window.location.href);
            f.error(g)
            } catch(h) {
            console.log(h)
            }
            })
    },
    define("hybrid", ["log"],
           function(a) {
           function b(a, b) {
           setTimeout(function() {
                      try {
                      d.triggerCallback(a, b)
                      } catch(c) {}
                      },
                      0)
           }
           function c() {
           var a = queryString.parse(location.search);
           if (a.os) return void(k.os = a.os);
           if (window.j1wireless) return void(k.os = window.j1wireless);
           var b = /(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(navigator.userAgent),
           c = navigator.userAgent.toLowerCase().indexOf("android") > -1; (b || c) && (c && (k.os = window.hywireless ? g: !1), b && (k.os = window.clienttype ? f: !1))
           }
           var d, e = null,
           f = "ios",
           g = "android",
           h = {
           "com.hy.patienthoc": f,
           "com.hy.patient": f,
           "com.j1.healthcare.patient": g
           },
           i = "j1wireless://",
           j = {
           android: function(a, b) {
           return window.hywireless.action(a, JSON.stringify(b))
           },
           ios: function(a, b) {
           var c = i + a + "/" + b.id + "?" + encodeURIComponent(JSON.stringify(b)),
           d = document.createElement("iframe");
           d.src = c,
           document.documentElement.appendChild(d),
           d.parentNode.removeChild(d),
           d = null
           }
           },
           k = function() {
           var a = this;
           a.message_id = 1,
           a.callbacks = {},
           a.listeners = {},
           a.system_ios = f,
           a.system_android = g,
           a.size = {
           width: 720,
           height: 1024
           },
           a.token = {
           token: ""
           },
           a.platform = g
           },
           l = k.prototype;
           return k.newInstance = function() {
           return new k
           },
           l.setSize = function(a) {
           this.size = a
           },
           l.isApp = function(a) {
           return a ? a == k.os: k.os
           },
           l.formatVersion = function() {
           if (e) return e;
           var a = window.location.search.match(/package_name=(.*)/)[0].split(";")[0].match(/package_name=(.*)/)[1],
           b = a.split("-");
           return e = {},
           e.version = b[1],
           e.numberVersion = parseFloat(b[1].replace(/\./, "")),
           e["package"] = b[0],
           e.os = h[e["package"]] || "",
           e
           },
           l.compVersion = function(a, b) {
           if (!this.isApp(b)) return ! 1;
           var c = this.formatVersion(),
           d = parseFloat(a.replace(/\./, ""));
           return c.numberVersion >= d
           },
           l.getSize = function() {
           return this.size
           },
           l.openLoginView = function(a) {
           var b = this;
           b.send("openLoginView", {
                  id: "openLoginView"
                  },
                  function(c) {
                  b.setToken(c),
                  a && a(c)
                  })
           },
           l.setToken = function(a) {
           this.token = a;
           var b = 30,
           c = new Date;
           c.setTime(c.getTime() + 24 * b * 60 * 60 * 1e3),
           document.cookie = "token=" + a.token + "; path=/; expires=" + c.toGMTString()
           },
           l.getToken = function() {
           var a = this;
           return a.token || a.send("getToken", {},
                                    function(b) {
                                    a.setToken(b)
                                    }),
           a.token
           },
           l.dispatchMessage = function(a, b, d) {
           var e = this;
           e.callbacks[b.id] = function(a) {
           d && d(a),
           b.fixed_callback || e.removeCallback(b.id)
           },
           k.os || c(),
           j[k.os](a, b)
           },
           l.removeCallback = function(a, b) {
           var c = this;
           c.callbacks[a] && delete c.callbacks[a],
           b && c.send("removeView", {
                       messageId: a
                       })
           },
           l.off = function(a) { (!this.listeners.hasOwnProperty(a) || !this.listeners[a] instanceof Array) && (this.listeners[a] = []),
           this.listeners[a] = []
           },
           l.on = function(a, b) { (!this.listeners.hasOwnProperty(a) || !this.listeners[a] instanceof Array) && (this.listeners[a] = []),
           this.listeners[a].push(b)
           },
           l.isYQB = function() {
           return document.cookie.match(/isYQB/)
           },
           l.isHFL = function() {
           return document.cookie.match(/isHFL/)
           },
           l.send = function(a, b, c) {
           var d = this,
           e = !1;
           b = b || {},
           c = c ||
           function() {},
           b.id || (e = !0, b.id = d.message_id + ""),
           b.host = window.location.host;
           try {
           d.dispatchMessage(a, b, c)
           } catch(f) {}
           return e && (d.message_id += 1),
           b.id
           },
           l.triggerCallback = function(a, b) {
           var c = this;
           if (c.callbacks[a] && this.callbacks[a](b), c.listeners[a]) for (var d in c.listeners[a]) c.listeners[a][d](b)
           },
           d = k.newInstance(),
           l.setTitle = function(a, b, c) {
           var d, e = this,
           f = c,
           g = $("[data-role=header]", f);
           if (k.os) e.send("setTitle", {
                            title: a
                            });
           else if (g.size() || (f.prepend($('<div data-role="header" class="header">')), g = $("[data-role=header]", f)), g.show(), a = a.length > 6 ? a.substring(0, 6) + "...": a, g.append($('<div class="headercon">' + a + "</div>")), b.url && (g.append($('<span class="header-return">')), d = g.find(".header-return"), d.on("click",
                                                                                                                                                                                                                                                                                                                                       function() {
                                                                                                                                                                                                                                                                                                                                       HYFramework.pageIn(b.url)
                                                                                                                                                                                                                                                                                                                                       })), b.fontsBtn && b.fontsBtn.length) {
           for (var h = 0; h < b.fontsBtn.length; h++) {
           var i = b.fontsBtn[h],
           j = "";
           if (i.data) for (var l in i.data) j += "data-" + l + "=" + i.data[l] + " ";
           g.append($("<button " + j + ' style="position:absolute;right:' + (parseInt(i.pos.right) || 0) + "px;top:" + (parseInt(i.pos.top) || 0) + '">' + i.title + "</button>"))
           }
           g.find("button").each(function(a, c) {
                                 $(c).data("index", a),
                                 $(c).bind("click",
                                           function() {
                                           b.fontsBtn[$(this).data("index")].cb && b.fontsBtn[$(this).data("index")].cb()
                                           })
                                 })
           }
           },
           c(),
           window.HYWirelessTriggerCallback = b,
           d
           }), define("page", ["hybrid", "log"],
                      function(a, b) {
                      $.scrollTop = function(a) {
                      document.body.scrollTop = a
                      };
                      var c = function() {
                      this.init && this.init.apply(this, arguments)
                      };
                      return c.prototype = {
                      init: function(a) {
                      this.pageScript = {},
                      this.pageScriptPath = null,
                      this.options = $.extend({
                                              io: "slide",
                                              hybody: "#hymain",
                                              cb: function() {}
                                              },
                                              a),
                      this.options.$element = $(a.$element || HYFramework.config.hybody + " [data-role=page]")
                      },
                      _goBack: function() {
                      if (1 == HYFramework.histroyArr.length) if (document.cookie.match(/back-url/)) {
                      var a = document.cookie.match(/back-url=(.*)/)[0].split(";")[0].match(/back-url=(.*)/)[1];
                      document.cookie = "back-url=" + a + "; path=/; expires=Sat,03 May 2000 17:44:22 GMT",
                      window.location.href = a
                      } else window.history.back();
                      else HYFramework.histroyArr.pop(),
                      HYFramework.pageIn(HYFramework.histroyArr.pop())
                      },
                      goBack: function() {
                      var a = this;
                      a.pageScript && a.pageScript.goBack ? a.pageScript.goBack(function() {
                                                                                a._goBack()
                                                                                }) : a._goBack()
                      },
                      resetLoadScript: function(a) {
                      this.pageScriptPath = c.getPageScriptName(a)
                      },
                      loadPage: function() {
                      this.pageScriptPath ? this.loadPageScript() : this.loadScript()
                      },
                      loadScript: function() {
                      var a = c.getCurrentModule();
                      a && a.pageOut(this),
                      this.loadAnimate()
                      },
                      loadPageScript: function() {
                      var a = this;
                      require([this.pageScriptPath],
                              function(b) {
                              a.pageScript = b || {},
                              a.loadScript()
                              })
                      },
                      addRightTopNav: function() {
                      var a = $(".pageTitle"),
                      b = $("<cite>"),
                      c = $("<s>"),
                      d = $("<div>").addClass("rightNav"),
                      e = ["shopcart.html", "mine.html", "orderInfo.html", "paychoose.html", "useCoupon.html", "checkchoose.html", "deliverAddressEdit.html", "coudan.html", "promote.html", "sign.html"],
                      f = new RegExp(e.join("|")).test(location.href);
                      if (aNav = [{
                                  type: "index",
                                  href: "index.html",
                                  text: "棣栭〉"
                                  },
                                  {
                                  type: "cate",
                                  href: "catalog.html",
                                  text: "鍒嗙被"
                                  },
                                  {
                                  type: "shopcart",
                                  href: "shopcart.html",
                                  text: "璐墿杞�"
                                  },
                                  {
                                  type: "mine",
                                  href: "mine.html",
                                  text: "鎴戠殑"
                                  }], !f) {
                      isNativeClient() || !$(".pageTitle").size() || $(".pageTitle button").size() || (b.append(c), a.append(b));
                      for (var g = 0; g < aNav.length; g++) {
                      var h = aNav[g],
                      i = $("<a>").data("type", h.type).attr("href", h.href).text(h.text);
                      d.append(i)
                      }
                      $("#hymain").append(d),
                      $(".pageTitle cite").on("click",
                                              function() {
                                              var a = $(".rightNav");
                                              a.is(".active") ? a.removeClass("active") : a.addClass("active")
                                              })
                      }
                      },
                      loadAnimate: function() {
                      function b(a) {
                      return f ? void _ga_tracker() : (f = !0, e.$element.unbind(a.type), $(e.hybody).removeClass("temOverflow"), d.pageAnimateDone(), void _ga_tracker())
                      }
                      var d = this,
                      e = d.options,
                      f = !1,
                      g = e.reverse ? " reverse": "",
                      h = c.getCurrentModule();
                      if (!e.io || !h) return this.pageAnimateDone(),
                      this.pageScript.pageIn && this.pageScript.pageIn(this),
                      d.noteSource(),
                      a.isApp() || d.addRightTopNav(),
                      void _ga_tracker();
                      var i = h.options.$element;
                      i.removeClass("out in reverse " + e.io),
                      $(".pageTitle").size() > 0 && $(".pageTitle").remove(),
                      $(e.hybody).append(e.$element).addClass("temOverflow"),
                      i.addClass(e.io + " out" + g),
                      e.$element.addClass(e.io + " in" + g),
                      "none" == e.io ? b({
                                         type: ""
                                         }) : (e.$element.bind("webkitAnimationEnd", b), e.$element.bind("animationend", b)),
                      this.options.cb(this.options),
                      this.pageScript.pageIn && this.pageScript.pageIn(this),
                      d.addRightTopNav(),
                      HYFramework.lazyImg(),
                      HYFramework.util.addHistroy(),
                      (void 0 === this.pageScript.isTargetNav || this.pageScript.isTargetNav) && HYFramework.util.popNavHistroy()
                      },
                      noteSource: function() {
                      var a = document.referrer,
                      b = HYFramework.util.getRequest().fromSite;
                      return refererPath = a.replace(/\?.*/, ""),
                      b ? void HYFramework.util.setCookie("outsource", encodeURIComponent(b)) : void(refererPath && !/j1\.com/.test(refererPath) && HYFramework.util.setCookie("outsource", encodeURIComponent(a)))
                      },
                      pageOut: function() {
                      var b = this.options,
                      c = this.pageScript;
                      c.pageOut && c.pageOut(this),
                      $(".rightNav").remove(),
                      b.$element.off(),
                      $("div[data-role]").each(function() {
                                               $(this).is("none") && ($(this).off(), $(this).remove())
                                               }),
                      $(".rightNav").removeClass("active"),
                      a.send("removeRightButtonItem"),
                      a.send("removeAllView")
                      },
                      pageAnimateDone: function() {
                      var a = c.getCurrentModule(),
                      b = this;
                      a && a.pageScript.animateEnd && a.pageScript.animateEnd(this),
                      a && a.dealloc(),
                      c.setCurrentModule(this),
                      HYFramework.lazyImg(),
                      $(".backBtn").unbind("click").on("click",
                                                       function() {
                                                       b.goBack()
                                                       })
                      },
                      dealloc: function() {
                      var a = c.getCurrentModule();
                      a && a.options.$element.remove()
                      }
                      },
                      $.extend(c, {
                               getNormalizePath: function(a) {
                               if (!a) return "/";
                               if ("/" == a[0]) return a;
                               var b = window.location.pathname;
                               return b.substr(0, b.lastIndexOf("/")) + "/" + a
                               },
                               getPageScriptName: function(a) {
                               var b = this.getModule(a),
                               a = this.getPathName(a);
                               return "index" == b ? a: b + "-" + a
                               },
                               getPathName: function(a) {
                               var b = a || window.location.pathname;
                               return "/" == b ? "index": (b = b.substr(b.lastIndexOf("/") + 1), b ? b.replace(".html", "") : "index")
                               },
                               getModule: function(a) {
                               var b = window.location.host;
                               if ("m.j1.net" == b || "m.j1.com" == b || "api.app.j1.com" == b || "wap.j1.com" == b) return "mall";
                               var a = a || window.location.pathname,
                               c = a.split("/"),
                               d = "index";
                               for (var e in c) if (c[e]) {
                               if ( - 1 == c[e].indexOf(".html")) {
                               d = c[e];
                               break
                               }
                               break
                               }
                               return d
                               },
                               render: function(a, b, c) {
                               return HYFramework.render(a, $.extend(b, c))
                               },
                               currentModule: null,
                               getCurrentModule: function() {
                               return this.currentModule
                               },
                               setCurrentModule: function(a) {
                               this.currentModule = a
                               },
                               unreadly: function() {
                               this.getCurrentModule().pageOut()
                               },
                               normalizePath: function(a) {
                               a = a || "";
                               var b = window.location.pathname,
                               c = "",
                               d = b.indexOf(".html");
                               return c = -1 == d ? "/" == b[b.length - 1] ? b + a: b + "/" + a: b.substr(0, b.lastIndexOf("/")) + "/" + a
                               }
                               }),
                      {
                      page: c,
                      loadPage: function(a) {
                      var d = a.url || location.href,
                      e = new c(a);
                      if (a.hyjs && "false" != a.hyjs && require.defined(a.hyjs) || require.s.contexts._.registry[a.hyjs]) e.pageScriptPath = a.hyjs,
                      e.loadPage();
                      else {
                      var f = d.replace(/(#|\?).*/, ""),
                      g = c.getNormalizePath(c.normalizePath(f)),
                      h = c.getPageScriptName(g),
                      i = /product\/\d+-\d+/,
                      j = /customactivity(.+)\.html/;
                      i.test(d) ? (e.pageScriptPath = "mall-detail", a.scriptName = "/mall/scripts/detail.js") : j.test(d) ? (e.pageScriptPath = "mall-customactivity", a.scriptName = "/mall/scripts/customactivity.js") : e.pageScriptPath = a.pageScriptPath || h,
                      b.debug("bean.pageScriptPath is:" + e.pageScriptPath + ", options.scriptName is:" + a.scriptName),
                      require([a.scriptName],
                              function() {
                              e.loadPage()
                              })
                      }
                      }
                      }
                      }), define("cache",
                                 function() {
                                 return {
                                 time: 18e5,
                                 setData: function(a, b) {},
                                 getData: function(a) {
                                 return ! 1
                                 },
                                 clearData: function(a) {},
                                 _installStorage: function() {},
                                 _getCach: function(a) {
                                 return null
                                 },
                                 _setCach: function(a, b) {},
                                 _checkCach: function() {
                                 return
                                 }
                                 }
                                 }), define("main", ["page", "hybrid", "cache", "log"],
                                            function(a, b, c, d) {
                                            var e = {
                                            event: [],
                                            bind: function(a, b, c) {
                                            $(a).bind(b, c),
                                            this.event.push({
                                                            ele: a,
                                                            type: b,
                                                            handle: c
                                                            })
                                            },
                                            clearBind: function() {
                                            $.each(this.event,
                                                   function(a, b) {
                                                   $(b.ele).unbind(b.type, b.handle)
                                                   })
                                            },
                                            lazyImg: function(a) {
                                            function b() {
                                            for (var a = document,
                                                 b = $(a).height(), d = Math.max(a.documentElement.scrollTop, a.body.scrollTop), e = 0; e < c.imgs.length; e++) {
                                            var f = c.imgs[e],
                                            g = $(f),
                                            h = g.offset().top,
                                            i = f.offsetHeight,
                                            j = h + i; (h - c.fill > d && h + c.fill < d - c.fill + b || j + c.fill > d && d + b > j) && (g.attr("src", g.attr("lazySrc")), g.removeAttr("lazySrc"), c.imgs.splice(e--, 1))
                                            }
                                            }
                                            var c = {
                                            fill: 0,
                                            imgs: []
                                            };
                                            $.extend(c, a || {}),
                                            c.imgs = $("img[lazySrc]").toArray(),
                                            c.imgs.length < 1 || (this.clearBind(), this.bind(window, "scroll",
                                                                                              function() {
                                                                                              b()
                                                                                              }), this.bind(window, "resize",
                                                                                                            function() {
                                                                                                            b()
                                                                                                            }), b())
                                            }
                                            },
                                            f = {
                                            currIndex: 0,
                                            init: function() {
                                            this.addUrl(),
                                            this.onGlobalEvent(),
                                            this.onGlobalEventPage()
                                            },
                                            addUrl: function(a) {
                                            var b = {
                                            title: "",
                                            url: a || location.href,
                                            currIndex: ++f.currIndex
                                            };
                                            history[a ? "pushState": "replaceState"](b, b.title, b.url)
                                            },
                                            onGlobalEventPage: function() {
                                            $(HYFramework.config.hybody).on("click", "a",
                                                                            function(a) {
                                                                            var b = $(this);
                                                                            if (b.is("[noPage]")) return void f.addUrl(b.attr("href"));
                                                                            a.preventDefault();
                                                                            var c = b.data("io") || "slide";
                                                                            HYFramework.pageIn(b.attr("href"), {
                                                                                               io: c
                                                                                               })
                                                                            }),
                                            this.writeToCookie(),
                                            HYFramework.util.addHistroy()
                                            },
                                            writeToCookie: function() {
                                            var a = HYFramework.util.getRequest(),
                                            b = HYFramework.util.setCookie,
                                            c = HYFramework.util.getCookie,
                                            d = (HYFramework.util.deleteCookie, ["mul", "package_name", "memberKey", "token", "contentNo"]);
                                            for (var e in d) {
                                            var f = d[e];
                                            a[f] && b(f, a[f])
                                            }
                                            c("contentNo") || b("contentNo", +new Date + Math.floor(1e3 * Math.random())),
                                            c("mul") || b("mul", "wap"),
                                            c("key") && deleteCookie("key");
                                            var g = c("memberKey") || c("token");
                                            b("memberKey", g),
                                            b("token", g)
                                            },
                                            onGlobalEvent: function() {
                                            window.addEventListener("popstate",
                                                                    function(a) {
                                                                    if (b.isApp()) try {
                                                                    var c = a.state,
                                                                    e = "";
                                                                    c && c.url && (c.currIndex < f.currIndex && (e = !0), f.currIndex = c.currIndex, HYFramework.pageIn({
                                                                                                                                                                        url: c.url,
                                                                                                                                                                        io: "none",
                                                                                                                                                                        cb: function() {},
                                                                                                                                                                        reverse: e
                                                                                                                                                                        }))
                                                                    } catch(a) {
                                                                    d.error("ERROE popstate event trigger main.js..." + a.stack)
                                                                    }
                                                                    })
                                            }
                                            };
                                            return function(g, h) {
                                            $.extend(g, {
                                                     Page: a.page,
                                                     urlEvent: f,
                                                     readly: function() {
                                                     var c = function() {
                                                     f.init(),
                                                     a.loadPage({
                                                                scriptName: "undefined" != typeof defaultScript ? defaultScript: "",
                                                                $element: HYFramework.config.hybody + " [data-role=page]",
                                                                pageScriptPath: "undefined" != typeof defaultModel ? defaultModel: null
                                                                })
                                                     };
                                                     b.constructor.os ? (b.send("getToken", {},
                                                                                function(a) {
                                                                                b.setToken(a)
                                                                                }), b.send("getSize", {},
                                                                                           function(a) {
                                                                                           b.setSize(a),
                                                                                           c()
                                                                                           })) : c()
                                                     },
                                                     share: function(a) {
                                                     b.send("share", a)
                                                     },
                                                     render: function(a, b, c) {
                                                     return Mustache.render(a, $.extend(b, c))
                                                     },
                                                     mask: function() {
                                                     this.unmask(),
                                                     this._mask = $('<div class="mallMash"><div class="progress"></div></div>'),
                                                     $(HYFramework.config.hybody).append(this._mask);
                                                     setTimeout(function() {
                                                                $(".mallMash").addClass("maskFlash")
                                                                },
                                                                0),
                                                     $(window).unbind("touchmove", window._dontMove),
                                                     window._dontMove = function(a) {
                                                     a.preventDefault()
                                                     },
                                                     $(window).bind("touchmove", window._dontMove)
                                                     },
                                                     unmask: function() {
                                                     $(window).unbind("touchmove", window._dontMove),
                                                     this._mask && this._mask.remove()
                                                     },
                                                     getUrlObj: function() {
                                                     var a, b = location.search.substring(1).split("&"),
                                                     c = {};
                                                     for (a = 0; a < b.length; a++) {
                                                     var d = b[a].split("=");
                                                     c[d[0]] = d[1]
                                                     }
                                                     return c
                                                     },
                                                     getAllUrl: function(a) {
                                                     if (0 == a.indexOf("http")) return a;
                                                     var b = window.location.pathname; ! 1 !== a.indexOf("/mall") && b.indexOf("/mall") !== !1 && (a = a.replace("/mall", ""));
                                                     var c = b.split("/"),
                                                     d = null;
                                                     return d = c.length >= 3 ? "/" + ("product" == c[1] ? "": c[1]) + "/" + a: "/" + a,
                                                     window.location.origin + d.replace(/\/\//g, "/")
                                                                                        },
                                                                                        lazyImg: function() {
                                                                                        e.lazyImg()
                                                                                        },
                                                                                        removeArgs: function(a, b) {
                                                                                        for (var c = 0; c < b.length; c++) b[c] in a && delete a[b[c]]
                                                                                        },
                                                                                        pageIn: function(e, h) {
                                                                                        function i(b, c, e, f) {
                                                                                        b || d.error("ERROR NOT is id lt hymain"),
                                                                                        a.loadPage($.extend({
                                                                                                            hyjs: e,
                                                                                                            scriptName: f,
                                                                                                            $element: b
                                                                                                            },
                                                                                                            h)),
                                                                                        k && g.unmask()
                                                                                        }
                                                                                        if (_event_renderListener(), h = h || {},
                                                                                            $.isPlainObject(e) && (h = e, e = h.url), e) {
                                                                                        h.url = g.getAllUrl(e),
                                                                                        h.io = h.io || "slide",
                                                                                        h.cb = h.cb ||
                                                                                        function(a) {
                                                                                        f.addUrl(a.url)
                                                                                        };
                                                                                        var j = HYFramework.util.getRequest(h.url),
                                                                                        k = (HYFramework.util.getCookie, h.mask !== !1 && b.isApp()),
                                                                                        l = $.extend({},
                                                                                                     j);
                                                                                        l.package_name || delete l.package_name;
                                                                                        var m = ["token", "memberKey", "contentNo", "mul"];
                                                                                        if (b.isApp() || HYFramework.removeArgs(l, m), h.url = h.url.split("?")[0] + ($.isEmptyObject(l) ? "": "?" + $.param(l)), k && g.mask(), h.cache !== !1) {
                                                                                        var n = h.url + $.param(h.data || {}),
                                                                                        o = n + "_xhr",
                                                                                        p = c.getData(n);
                                                                                        if (p) {
                                                                                        try {
                                                                                        i(p, null, c.getData(o)),
                                                                                        k && g.unmask(),
                                                                                        d.debug("success loading cache main.js....")
                                                                                        } catch(q) {
                                                                                        k && g.unmask(),
                                                                                        d.error("ERROE loading cache main.js....")
                                                                                        }
                                                                                        return
                                                                                        }
                                                                                        }
                                                                                        return d.debug("pageIn ajax url:" + h.url),
                                                                                        b.isApp() ? ($.ajax({
                                                                                                            url: h.url,
                                                                                                            cache: !1,
                                                                                                            data: $.param(h.data || {}),
                                                                                                            success: function(a, b, c) {
                                                                                                            i(a, b, c.getResponseHeader("hyjs"), c.getResponseHeader("scriptName"))
                                                                                                            },
                                                                                                            error: function() {
                                                                                                            k && g.unmask()
                                                                                                            }
                                                                                                            }), !1) : void(window.location.href = h.url)
                                                                                        }
                                                                                        }
                                                                                        },
                                                                                        h)
                                                     }
                                                     }), define("ui",
                                                                function() {
                                                                return function(a, b) {
                                                                a.ui = {};
                                                                var c = a.ui;
                                                                c.alert = function(a) {
                                                                a = $.extend({
                                                                             title: "鎻愮ず",
                                                                             content: "鏈煡鐨勯敊璇�",
                                                                             btntext: "纭畾"
                                                                             },
                                                                             a),
                                                                0 == $(".mask").size() && $("#hymain").append($("<div>").addClass("mask")),
                                                                $(".mask").html("").append($('<div class="alert-box"><h2>' + a.title + "</h2><p>" + a.content + "</p><button>" + a.btntext + "</button></div>")).show();
                                                                var b = $(".alert-box"),
                                                                c = b.find("button");
                                                                b.css({
                                                                      marginTop: -parseInt(b.height() / 2)
                                                                      }),
                                                                c.on("click",
                                                                     function() {
                                                                     a.success && a.success(),
                                                                     $(".mask").hide()
                                                                     })
                                                                },
                                                                c.close = function() {
                                                                $(".mask").size() && $(".mask").remove()
                                                                },
                                                                c.confirm = function(a) {
                                                                a = $.extend({
                                                                             title: "榛樿鎻愮ず",
                                                                             content: "榛樿鍐呭",
                                                                             cancelText: "鍙栨秷",
                                                                             confirmText: "纭畾"
                                                                             },
                                                                             a),
                                                                0 == $(".mask").size() && $("#hymain").append($("<div>").addClass("mask")),
                                                                $(".mask").html("").append($('<div class="confirm-box"><h2>' + a.title + "</h2><p>" + a.content + '</p><div class="buttonBox" style="display:-webkit-box"><button class="cancel">' + a.cancelText + '</button><button class="sure">' + a.confirmText + "</button></div></div>")).show();
                                                                var b = $(".confirm-box"),
                                                                c = b.find("button");
                                                                b.css({
                                                                      marginTop: -parseInt(b.height() / 2)
                                                                      }),
                                                                c.eq(0).on("click",
                                                                           function() {
                                                                           a.cancelFun && a.cancelFun()
                                                                           }),
                                                                c.eq(1).on("click",
                                                                           function() {
                                                                           a.success && a.success()
                                                                           })
                                                                },
                                                                c.tips = function(a) {
                                                                a = $.extend({
                                                                             content: "榛樿鐨勯敊璇秷鎭痶ips",
                                                                             time: 2e3
                                                                             },
                                                                             a);
                                                                var b = null;
                                                                $(".tipBox").length || $("body").append($('<div class="tipBox r5"></div>'));
                                                                var c = $(".tipBox");
                                                                c.html("").css({
                                                                               top: $(window).scrollTop() + parseInt($(window).height() / 2),
                                                                               "z-index": 999
                                                                               }),
                                                                c.append($("<h2>" + a.content + "</h2>")).show(),
                                                                clearTimeout(b),
                                                                b = setTimeout(function() {
                                                                               c.hide()
                                                                               },
                                                                               a.time)
                                                                },
                                                                c.shopcartalert = function(a) {
                                                                a = $.extend({
                                                                             title: "鎻愮ず",
                                                                             content: "鏈煡鐨勯敊璇�"
                                                                             },
                                                                             a),
                                                                0 == $(".mask").size() && $("#hymain").append($("<div>").addClass("mask")),
                                                                $(".mask").html("").append($('<div class="alert-shopcartbox"><h2>' + a.title + "</h2><p>" + a.content + '</p><div class="alertbuttonwrap"><button class="gosee">鍐嶉€涢€�</button><button class="goshopcart">鍘昏喘鐗╄溅</button></div></div>')).show();
                                                                var b = $(".alert-box"),
                                                                c = b.find("button");
                                                                b.css({
                                                                      marginTop: -parseInt(b.height() / 2)
                                                                      }),
                                                                c.on("click",
                                                                     function() {
                                                                     $(".mask").hide()
                                                                     })
                                                                },
                                                                c.alertchoose = function(a) {
                                                                a = $.extend({
                                                                             title: "鎻愮ず",
                                                                             content: "鏈煡鐨勯敊璇�"
                                                                             },
                                                                             a),
                                                                0 == $(".mask").size() && $("#hymain").append($("<div>").addClass("mask")),
                                                                $(".mask").html("").append($('<div class="alert-shopcartbox"><h2>' + a.title + "</h2><p>" + a.content + '</p><div class="alertbuttonwrap"><button class="ok">纭畾</button><button class="cancel">鍙栨秷</button></div></div>')).show();
                                                                var b = $(".alert-shopcartbox"),
                                                                c = b.find("button");
                                                                b.css({
                                                                      marginTop: -parseInt(b.height() / 2)
                                                                      }),
                                                                c.on("click",
                                                                     function() {
                                                                     $(".mask").hide()
                                                                     })
                                                                }
                                                                }
                                                                }), /isYQB/.test(window.location.href)) {
    var cookie = window.location.search.match(/cookie=(.*)/)[1];
    cookie = JSON.parse(decodeURIComponent(cookie));
    for (var i in cookie) document.cookie = cookie[i] + "; path=/"
    }
    if (/memberId/.test(document.cookie)) {
    var memberId = document.cookie.match(/memberId=(.*)/)[0].split(";")[0].match(/memberId=(.*)/)[1];
    window._uid = memberId
    }
    var HYFrameworkDefaultConfig = {
    hybody: "#hymain",
    anibox: ".page-swap",
    module: {
    "native": 1,
    activity: 1,
    mall: 1,
    index: 1,
    health: 1
    }
    },
    _swa = function(a) {
    var b = "undefined";
    return a != b
    },
    page_listener = [],
    _event_addlistener = function(a) {
    page_listener.push(a)
    },
    _event_renderListener = function() {
    for (var a in page_listener) try {
    page_listener[a]()
    } catch(b) {}
    },
    _ga_tracker = function() {
    window.trackerMethod && trackerMethod()(),
    window.ga && ga("send", "pageview")
    },
    emptyfunc = function() {},
    _log = {},
    getAPI = function(a) {
    var b = function(a) {
    for (var b = {},
         c = [], d = document.cookie.split(";"), e = 0, f = d.length; f > e; e++) if (d[e]) {
    if (c = d[e].split("="), !c || !c[0] || !c[1]) continue;
    if ("key" == c[0].trim()) continue;
    b[c[0].trim()] = decodeURIComponent(c[1].trim())
    }
    return b[a]
    },
    c = b(a);
    return c ? c: URL[a]
    },
    URL = {
    h5url: "http://m.j1.com/",
    webapi: "http://api.soa.h5mall.j1.com/",
    payurl: "http://pay.j1.com/",
    nativeApi: "http://soa.app.j1.com/",
    payCheckurl: "http://soa.app.j1.com/",
    apph5url: "http://app.j1.com/"
    },
    cartNoSelect = [],
    d_h5url = function(a) {
    var b = forUrl(getAPI("h5url")) + (a || "");
    return _log.debug(b),
    b
    },
    d_apph5url = function(a) {
    var b = forUrl(getAPI("apph5url")) + (a || "");
    return b
    },
    d_webapi = function(a) {
    var b = forUrl(getAPI("webapi")) + (a || "");
    return _log.debug(b),
    b
    },
    d_payurl = function(a) {
    var b = forUrl(getAPI("payurl")) + (a || "");
    return _log.debug(b),
    b
    },
    d_nativeApi = function(a) {
    var b = forUrl(getAPI("nativeApi")) + (a || "");
    return _log.debug(b),
    b
    },
    d_payCheckurl = function(a) {
    var b = forUrl(getAPI("payCheckurl")) + (a || "");
    return _log.debug(b),
    b
    },
    forUrl = function(a) {
    return a + (a && a.lastIndexOf("/") == a.length - 1 ? "": "/")
    },
    nativeClientInfo = function() {
    var a = "com.j1.healthcare.patient,com.hy.patient,com.j1.patient".split(","),
    b = window.location.href;
    for (var c in a) if ( - 1 !== b.indexOf("package_name=" + a[c])) return {
    packageName: a[c]
    };
    return ! 1
    },
    isNativeClient = function() {
    return nativeClientInfo()
    },
    click = function() {
    var a = /AppleWebKit.*Mobile.*/;
    return a.test(navigator.userAgent) ? "touchend": "click"
    } ();
    String.prototype.format = function() {
    var a = arguments;
    return this.replace(/\{(\d+)\}/g,
                        function(b, c) {
                        return a[c]
                        })
    },
    require.config({
                   ewaitSeconds: 200,
                   baseUrl: "../scripts",
                   paths: {
                   ui: "/scripts/core/ui",
                   main: "/scripts/core/main",
                   core: "/scripts/core/core",
                   ajax: "/scripts/core/ajax",
                   page: "/scripts/core/page",
                   nav: "/scripts/core/nav",
                   hybrid: "/scripts/core/hybrid",
                   log: "/scripts/core/log",
                   cache: "/scripts/core/cache",
                   iscroll: "/scripts/core/iscroll",
                   qrcode: "/scripts/core/qrcode",
                   active: "/scripts/core/active",
                   area: "/scripts/core/area",
                   tips: "/scripts/core/tips",
                   loading: "/scripts/core/loading",
                   mask: "/scripts/core/mask",
                   tab: "/scripts/core/tab",
                   user: "/scripts/core/user",
                   moduletype: "/scripts/core/moduletype"
                   }
                   }),
    define("core", ["main", "ui", $("#hymainjs").data("index"), "log", "hybrid", "ajax"],
           function(a, b, c, d, e, f) {
           _log = d;
           var g = function() {
           self.currentModule = null
           };
           g.prototype.util = {
           getTimestamp: function() {
           return + new Date + "" + parseInt(10 * Math.random())
           },
           clearHistory: function(a) {
           if (!a) return void(g.histroyArr = []);
           var b = g.histroyArr;
           for (var c in b) - 1 != b[c].indexOf(a) && delete g.histroyArr[c]
           },
           popNavHistroy: function() {
           var a = g.histroyArr,
           b = window.location.pathname;
           for (var c in a) if ( - 1 != a[c].indexOf(b)) return void(g.histroyArr = a.slice(0, parseInt(c) + 1))
           },
           addHistroy: function() {
           g.histroyArr || (g.histroyArr = []);
           var a = g.histroyArr,
           b = window.location.pathname;
           for (var c in a) if ( - 1 != a[c].indexOf(b)) return;
           g.histroyArr.push(location.href)
           },
           createToCartBox: function() {
           var a = $('<div class="maskDiv">'),
           b = $('<div class="cartBox">'),
           c = $("<h2><cite></cite><span>娣诲姞鎴愬姛锛�</span><span>鍟嗗搧宸插姞鍏ヨ喘鐗╄溅</span></h2>"),
           d = $('<div class="btnBox"><button>鍐嶉€涢€�</button><button>鍘昏喘鐗╄溅</button></div>');
           b.append(c),
           b.append(d),
           a.append(b),
           $("body").append(a),
           d.on("click",
                function(b) {
                var c = null;
                "button" === b.target.tagName.toLowerCase() && (c = $(b.target), 0 === c.index() && a.remove(), 1 === c.index() && (a.remove(), g.util.goShopcart()))
                })
           },
           cartNotSelectedArr: [],
           goShopcart: function() {
           if (!isNativeClient()) return g.pageIn("shopcart.html", {
                                                  cache: !1
                                                  });
           var a = isNativeClient().packageName;
           return "com.j1.patient" === a ? g.pageIn("shopcart.html", {
                                                    cache: !1
                                                    }) : e.constructor && e.constructor.os ? e.send("showCart") : void g.pageIn("shopcart.html", {
                                                                                                                                cache: !1
                                                                                                                                })
           },
           addTocart: function(a) {
           var b = $.extend({
                            skuId: 0,
                            multiId: 36,
                            type: "add",
                            isSelected: "Y",
                            amount: 1,
                            cache: !1
                            },
                            {
                            goodsId: a
                            });
           f.Hyget("shopcart/modify.html",
                   function() {
                   g.util.createToCartBox()
                   },
                   b)
           },
           setRightBtn: function(a) {
           var b = $(".pageTitle"),
           c = $("<button>");
           return isNativeClient() ? void(a.isNeed && e.send("createRightCustomButton", {
                                                             fixed_callback: !0,
                                                             title: a.title,
                                                             type: "icon",
                                                             frame: {
                                                             x: e.getSize().width - ("android" == e.constructor.os ? 100 : 57),
                                                             y: 5 + ("android" == e.constructor.os ? 0 : 23),
                                                             width: "android" == e.constructor.os ? 110 : 55,
                                                             height: "android" == e.constructor.os ? 47 : 26
                                                             }
                                                             },
                                                             function() {
                                                             a.callback && a.callback()
                                                             })) : (c.text(a.title), b.append(c), void c.on("click",
                                                                                                            function() {
                                                                                                            a.callback && a.callback($(this))
                                                                                                            }))
           },
           getMark: function(a) {
           return a = a || "",
           -1 == a.indexOf("?") ? "?": "&"
           },
           getRequest: function(a) {
           var b = {},
           c = a || location.search,
           d = c.indexOf("?");
           c = c.substr(d + 1);
           for (var e, f, g = c.split("&"), h = 0; h < g.length; h++) d = g[h].indexOf("="),
           d > 0 && (e = g[h].substring(0, d), f = g[h].substr(d + 1), b[e] = decodeURIComponent(f));
           return b
           },
           setCookie: function(a, b, c) {
           var d = a + "=" + encodeURIComponent(b);
           if ("key" != a.toLowerCase()) {
           if ("undefined" == typeof c && (c = 24), c > 0) {
           var e = new Date;
           e.setTime(e.getTime() + 3600 * c * 1e3),
           d = d + "; path=/; expires=" + e.toGMTString()
           }
           document.cookie = d
           }
           },
           getCookie: function(a) {
           for (var b = document.cookie,
                c = b.split("; "), d = 0; d < c.length; d++) {
           var e = c[d].split("=");
           if (e[0] == a) return decodeURIComponent(e[1])
           }
           return ""
           },
           deleteCookie: function(a) {
           var b = new Date;
           b.setTime(b.getTime() - 1e4),
           document.cookie = a + "=" + g.util.getCookie(a) + "; path=/; expires=" + b.toGMTString()
           },
           setNavIcon: function() {
           isNativeClient()
           },
           toFixed: function(a) {
           return a = Number(a || 0) || 0,
           "楼" + a.toFixed(2)
           }
           },
           g.h5testhost = "",
           g.config = HYFrameworkDefaultConfig,
           a(g, g.prototype),
           b(g, g.prototype),
           window.HYFramework = g;
           try {
           g.readly()
           } catch(h) {
           d.error("椤甸潰鍑洪敊銆傘€傘€�"),
           document.body.innerHTML = h.stack
           }
           return isNativeClient() && (g.iVersion = parseInt(g.util.getRequest().package_name.split("-")[1].split(".").join(""))),
           loadAsyncGA(),
           g
           }),
    require(["core"]),
    $.fn.HYTemplate = function(a) {
    if (a) return this.data("hytemplate", a),
    this;
    var b = this.data("hytemplate");
    return b ? $(b).html() : ""
    },
    $.fn.getJson = function(a, b, c) {
    var d = this;
    return require(["ajax"],
                   function(e) {
                   var f, g = {},
                   h = {},
                   i = function() {};
                   $.isFunction(b) && (f = b),
                   $.isFunction(c) && (f = b),
                   $.isPlainObject(b) && (g = b),
                   $.isPlainObject(c) && (g = c),
                   g.render && (h = $.extend(h, g.render), delete g.render),
                   g.cb && $.isFunction(g.cb) && (i = g.cb, delete g.cb),
                   e.Hyget(a,
                           function(a) {
                           try {
                           d.get(0).ajaxData = a
                           } catch(b) {}
                           g.beforeRender && g.beforeRender(a),
                           d.html(HYFramework.render(d.HYTemplate(), a, h)),
                           i(a)
                           },
                           g)
                   }),
    d
    },
    define("ajax", ["log", "hybrid", "cache", "user", "loading"],
           function(a, b, c, d, e) {
           function f(e, f, g) {
           function h(a) {
           return 0 == a.indexOf("http://")
           }
           function i(a) {
           return a = a || "",
           -1 == a.indexOf("?") ? "?": "&"
           }
           function j(a, b) {
           return ! ( - 1 == a.indexOf(b + "="))
           }
           var k = {};
           $.isPlainObject(f) && (k = $.extend(k, f), f = null),
           $.isFunction(f) && (f = f ||
                               function() {}),
           $.isFunction(g) && (f = g),
           $.isPlainObject(g) && (k = $.extend(k, g)),
           g = k;
           var l = g.error ||
           function() {}; ! g.token && b.getToken().token && (g.token = b.getToken().token),
           HYFramework.mask();
           var m = !g || g && g.cache !== !1 && "false" !== g.cache;
           if (g && delete g.cache, m) {
           var n = e + $.param(g),
           o = c.getData(n);
           if (o && f) {
           try {
           f(o.data || {}),
           HYFramework.unmask()
           } catch(p) {
           HYFramework.unmask()
           }
           return
           }
           }
           var q = g.interfaceHost ? g.interfaceHost: d_webapi(),
           e = h(e) ? e: q + e,
           r = g.err || !1;
           delete g.err,
           e += (e.indexOf("?") > 0 ? "&": "?") + $.param(g),
           a.debug(e),
           a.debug(g);
           var s = HYFramework.util.getRequest(),
           t = HYFramework.util.getCookie,
           u = null;
           u = $.extend(s, {
                        mul: d.get("mul"),
                        token: d.getToken(),
                        memberKey: d.getToken(),
                        contentNo: decodeURIComponent(t("contentNo"))
                        }),
           g.token || j(e, "token") || !u.token || (e += i(e) + "token=" + u.token),
           g.token || j(e, "memberKey") || !u.token || (e += i(e) + "memberKey=" + u.token),
           g.token && !j(e, "memberKey") && (e += i(e) + "memberKey=" + g.token),
           g.memberKey || j(e, "memberKey") || !u.memberKey || (e += i(e) + "memberKey=" + u.memberKey),
           g.contentNo || j(e, "contentNo") || !u.contentNo || (e += i(e) + "contentNo=" + u.contentNo),
           g.mul || j(e, "mul") || !u.mul || (e += i(e) + "mul=" + u.mul),
           a.debug("Ajax Request Url锛歿0} ".format(e)),
           $.ajax({
                  url: e,
                  dataType: "jsonp",
                  success: function(b) {
                  return HYFramework.unmask(),
                  0 != b.status ? (r ? r(b) : HYFramework.ui.tips({
                                                                  content: b.msg
                                                                  }), l(), void a.debug(b.msg)) : void(f && (f(b.data || {}), HYFramework.lazyImg(), m && c.setData(n, b)))
                  },
                  error: function(b, c, d) {
                  HYFramework.unmask(),
                  a.error("璇锋眰鎺ュ彛鏁版嵁鍑洪敊..."),
                  r && r(),
                  a.error(b),
                  a.error(c),
                  a.error(d)
                  }
                  },
                  {})
           }
           function g(d, e, f, g) {
           var g = g || {},
           e = e || {},
           f = f ||
           function() {};
           a.debug("start Request API url锛�" + d + ";data:" + e + ";opts:" + g),
           !g.token && b.getToken().token && (g.token = b.getToken().token),
           g.mask !== !1 && HYFramework.mask();
           var h = !g || g && g.cache !== !1 && "false" !== g.cache;
           if (a.debug(h), g && delete g.cache, h) {
           var i = d + $.param(g),
           j = c.getData(i);
           if (j && f) {
           try {
           f(j.data || {}),
           HYFramework.unmask(),
           a.debug("success loading cache ajax.js....")
           } catch(k) {
           HYFramework.unmask(),
           a.error("error loading cache ajax.js....")
           }
           return
           }
           }
           var l = g.interfaceHost ? g.interfaceHost: d_webapi(),
           m = l + d,
           n = $.extend(e, g);
           a.debug(m),
           a.debug(g),
           a.debug(n),
           $.ajax({
                  type: "POST",
                  dataType: "jsonp",
                  url: m,
                  data: n,
                  success: function(b) {
                  return 0 != b.status ? (HYFramework.ui.tips({
                                                              content: b.msg
                                                              }), this.error(), void a.debug(b.msg)) : 1 != parseInt(b.state) ? void HYFramework.ui.tips({
                                                                                                                                                         content: b.msg,
                                                                                                                                                         time: 500
                                                                                                                                                         }) : void(f && (f(b), HYFramework.lazyImg()))
                  },
                  error: function(b, c, d) {
                  HYFramework.unmask(),
                  a.error("request API ERROR url: " + m + " param:" + $.param(n) + " status: " + c + " thrown: " + d)
                  }
                  })
           }
           return {
           Hyget: f,
           Hypost: g
           }
           }),
    define("nav",
           function() {
           function a() {
           this.nav = $("[data-role=header]")
           }
           var b = a.prototype;
           return b.hideNav = function() {
           return this.nav.hide(),
           this
           },
           b.showNav = function() {
           return this.nav.show(),
           this
           },
           b.remove = function() {
           return $("[data-role=header]").remove(),
           this
           },
           b.setLeftBtn = function(a, b) {
           var c = this,
           d = c.nav.find(".header-return");
           return d.length || c.nav.append($('<a class="header-return" href="javascript:;">' + a + "</a>")),
           d = c.nav.find(".header-return"),
           b && b(d),
           c
           },
           b.setRightBtn = function(a, b) {
           var c = this,
           d = c.nav.find(".header-righttext");
           return d.length || c.nav.append($('<a class="header-righttext" href="javascript:;">')),
           d = c.nav.find(".header-righttext"),
           d.html(a),
           b && b(d),
           c
           },
           b.setTitle = function(a, b) {
           var c, d = this;
           return c = d.nav.find(".headercon"),
           c.length || d.nav.append($('<div class="headercon">')),
           c = d.nav.find(".headercon"),
           c.html(a),
           b && b(c),
           d
           },
           new a
           }),
    define("user", ["hybrid"],
           function(a) {
           var b = ["memberId", "token", "memberKey", "mul", "loginName"],
           c = function() {
           this.instance = {}
           },
           d = new c;
           return d.location = function(b) {
           a.isApp() ? a.send("openWebView", {
                              url: b
                              }) : location.replace(b)
           },
           d.loginSuccess = function(a, c) {
           var d = function(a, b) {
           HYFramework.util.setCookie(a, b)
           },
           e = b.join(",");
           for (var f in a) - 1 != e.indexOf(f) && d(f, a[f]);
           d("mul", "wap"),
           d("token", a.memberKey),
           window._uid = a.memberId,
           c && c()
           },
           d.getToken = function() {
           var a = HYFramework.util.getCookie("token") || HYFramework.util.getRequest().token;
           return a || (a = HYFramework.util.getCookie("memberKey") || HYFramework.util.getRequest().memberKey),
           a && "" != a || (a = HYFramework.util.getRequest().token || HYFramework.util.getRequest().memberKey),
           a
           },
           d.logout = function(a) {
           HYFramework.util.deleteCookie("token"),
           HYFramework.util.deleteCookie("memberKey"),
           a && a()
           },
           d.isLogin = function() {
           var a = !(!HYFramework.util.getCookie("memberKey") && !HYFramework.util.getRequest().memberKey);
           return "" == !a ? a: HYFramework.util.getCookie("token") || HYFramework.util.getRequest().token
           },
           d.loginPage = function(b, c) {
           var d = c ? "?referer=" + c: "";
           isNativeClient() ? a.openLoginView(b ||
                                              function() {}) : HYFramework.pageIn("login.html" + d,
                                                                                  function() {
                                                                                  b && b()
                                                                                  })
           },
           d.get = function(a) {
           if (this.instance[a]) return this.instance[a];
           var b = HYFramework.util.getRequest(),
           c = HYFramework.util.getCookie(a) || b[a];
           return this.instance[a] = c,
           c
           },
           d
           }),
    define("moduletype",
           function() {
           var a = {
           SEARCH: 0,
           FOCUS: 1,
           TITLEIMAGE: 2,
           COUPON: 3,
           TIMEKILL: 7,
           TWOFORONE: 6,
           BRAND: 4,
           ACTIVITY: 5
           };
           return a
           }),
    define("tips",
           function() {
           function a(b, c) {
           this.o = a.$(b),
           this.m = a.k("div"),
           this.m.className = "tips",
           this.m.innerHTML = c || "",
           this.o.parentNode.style.position = "relative",
           this.c = {
           color: "#c7c7c7",
           textIndent: "5px",
           fontSize: "17px",
           textAlign: "left",
           overflow: "hidden",
           position: "absolute",
           top: this.o.offsetTop + "px",
           left: this.o.offsetLeft + "px",
           width: this.o.offsetWidth + "px",
           height: this.o.offsetHeight + "px",
           lineHeight: this.o.offsetHeight + "px",
           display: "" == this.o.value ? "block": "none"
           };
           for (var d in this.c) this.m.style[d] = this.c[d];
           var e = this;
           this.o.parentNode.appendChild(this.m),
           a.b(this.m, "click",
               function() {
               e.o.focus()
               }),
           a.b(this.o, "focus",
               function() {
               e.m.style.display = "none"
               }),
           a.b(this.o, "blur",
               function() {
               "" == e.o.value && (e.m.style.display = "block")
               })
           }
           return a.$ = function(a) {
           return "string" == typeof a ? document.getElementById(a) : a
           },
           a.k = function(a) {
           return document.createElement(a)
           },
           a.b = function(a, b, c) {
           a.attachEvent ? a.attachEvent("on" + b,
                                         function(a) {
                                         return function() {
                                         c.call(a)
                                         }
                                         } (a)) : a.addEventListener(b, c, !1)
           },
           a
           });