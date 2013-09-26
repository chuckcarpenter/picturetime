// Generated by CoffeeScript 1.6.3
(function() {
  var pictureTime;

  pictureTime = function() {
    var correctSrc, deviceRatio, frag, matches, media, pic, picImg, picText, pictures, resMatch, sAttr, sources, src, srcSets, srcs, _i, _j, _k, _len, _len1, _len2;
    pictures = document.getElementsByTagName("picture");
    deviceRatio = window.devicePixelRatio || 1;
    for (_i = 0, _len = pictures.length; _i < _len; _i++) {
      pic = pictures[_i];
      matches = [];
      sources = pic.getElementsByTagName("source");
      if (pic.innerHTML === "") {
        return null;
      }
      if (!sources.length) {
        picText = pic.innerHTML;
        frag = document.createElement("div");
        srcs = picText.replace(/(<)source([^>]+>)/gmi, "$1div$2").match(/<div[^>]+>/gmi);
        frag.innerHTML = srcs.join("");
        sources = frag.getElementsByTagName("div");
      }
      for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
        sAttr = sources[_j];
        media = sAttr.getAttribute("media");
        if (!media || window.matchMedia && window.matchMedia(media).matches) {
          matches.push(sAttr);
          break;
        }
      }
      picImg = pic.getElementsByTagName("img")[0];
      if (matches.length !== 0) {
        if (!picImg) {
          picImg = document.createElement("img");
          picImg.alt = pic.getAttribute("alt");
          pic.appendChild(picImg);
        }
        srcSets = matches.pop().getAttribute("srcset");
        if (deviceRatio && srcSets.indexOf(" 2x") !== -1) {
          srcSets = srcSets.split(",");
          for (_k = 0, _len2 = srcSets.length; _k < _len2; _k++) {
            src = srcSets[_k];
            src = src.replace(/^\s*/, '').replace(/\s*$/, '').split(" ");
            resMatch = parseFloat(src[1], 10);
            if (deviceRatio === resMatch) {
              correctSrc = src[0];
              break;
            }
          }
        } else {
          correctSrc = srcSets;
        }
        picImg.src = correctSrc;
      } else if (picImg) {
        pic.removeChild(picImg);
      }
    }
  };

  if (window.addEventListener) {
    window.addEventListener("resize", pictureTime, false);
    window.addEventListener("DOMContentLoaded", function() {
      pictureTime();
      return window.removeEventListener("load", pictureTime, false);
    }, false);
    window.addEventListener("load", pictureTime, false);
  } else {
    window.attachEvent("onload", pictureTime);
  }

  if (typeof define === 'function') {
    define(function() {
      return pictureTime;
    });
  }

  pictureTime();

}).call(this);
