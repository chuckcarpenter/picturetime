// Generated by CoffeeScript 1.3.3
(function() {
  var pictureTime;

  pictureTime = function() {
    var correctSrc, deviceRatio, matches, media, pic, picImg, pictures, resMatch, sAttr, sources, src, srcSets, _i, _j, _k, _len, _len1, _len2, _results;
    pictures = document.getElementsByTagName("picture");
    deviceRatio = window.devicePixelRatio;
    _results = [];
    for (_i = 0, _len = pictures.length; _i < _len; _i++) {
      pic = pictures[_i];
      matches = [];
      sources = pic.getElementsByTagName("source");
      for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
        sAttr = sources[_j];
        media = sAttr.getAttribute("media");
        if (!media || window.matchMedia && window.matchMedia(media).matches) {
          matches.push(sAttr);
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
            if (deviceRatio >= resMatch) {
              correctSrc = src[0];
              break;
            }
          }
        } else {
          correctSrc = srcSets;
        }
        _results.push(picImg.src = correctSrc);
      } else if (picImg) {
        _results.push(pic.removeChild(picImg));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
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

}).call(this);
