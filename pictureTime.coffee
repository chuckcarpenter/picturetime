# pictureTime polyfill by Chuck Carpenter for National Geographic, 2012

# much observed from the picturefill polyfill by Scott Jehl 
# http://github.com/scottjehl/picturefill

# needed to change markup to respect actual picture element and double density photos

pictureTime = ->
    pictures = document.getElementsByTagName "picture"
    deviceRatio = window.devicePixelRatio or 1

    for pic in pictures
        matches = []
        sources = pic.getElementsByTagName "source"

        # IE8 is not going to let us process srcset attr, return and let the fallback load
        if pic.innerHTML is "" then return null

        if not sources.length
            picText =  pic.innerHTML
            frag = document.createElement "div"
            # For IE9, convert the source elements to divs
            srcs = picText.replace( /(<)source([^>]+>)/gmi, "$1div$2" ).match( /<div[^>]+>/gmi )
            frag.innerHTML = srcs.join( "" )
            sources = frag.getElementsByTagName( "div" ) 

        for sAttr in sources
            media = sAttr.getAttribute "media"
            if not media or window.matchMedia and window.matchMedia( media ).matches
                matches.push sAttr
        
        picImg = pic.getElementsByTagName( "img" )[0]
        picImg.className += " Updated"

        if matches.length isnt 0 
            if not picImg
                picImg = document.createElement "img"
                picImg.alt = pic.getAttribute "alt"
                pic.appendChild picImg
            
            srcSets = matches.pop().getAttribute("srcset")

            if deviceRatio and srcSets.indexOf(" 2x") isnt -1
                srcSets = srcSets.split ","
                for src in srcSets
                    src = src.replace(/^\s*/, '').replace(/\s*$/, '').split " "
                    resMatch = parseFloat src[1], 10
                    if deviceRatio >= resMatch
                        correctSrc = src[0]
                        break
            else
                correctSrc = srcSets
            picImg.src = correctSrc
        
        else if picImg then pic.removeChild picImg

if window.addEventListener
    window.addEventListener "resize", pictureTime, false
    window.addEventListener "DOMContentLoaded", ->
        pictureTime()
        window.removeEventListener "load", pictureTime, false
    , false
    window.addEventListener "load", pictureTime, false
else window.attachEvent "onload", pictureTime