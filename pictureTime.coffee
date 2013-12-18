# pictureTime polyfill by 
# Chuck Carpenter for National Geographic, 2012

# much observed from the picturefill polyfill by Scott Jehl
# http://github.com/scottjehl/picturefill

# needed to change markup to respect actual 
# picture element and double density photos

pictureTime = ->
    pictures = document.getElementsByTagName "picture"
    # if Device Pixel Ratio exists, give us the whole number. 
    # Otherwise, fall back to 1.
    deviceRatio = if window.devicePixelRatio then Math.round window.devicePixelRatio else 1
    if deviceRatio > 2 then deviceRatio is 2

    for pic in pictures
        matches = []
        sources = pic.getElementsByTagName "source"

        # IE8 is not going to let us process srcset attr, 
        # return and let the fallback load
        if pic.innerHTML is ""
            if ( img = pic.getElementsByTagName( "img" )[ 0 ] ) and ( src = img.getAttribute "data-src" )
                img.setAttribute "src", src
            return null

        if not sources.length
            picText =  pic.innerHTML
            frag = document.createElement "div"
            # For IE9, convert the source elements to divs
            srcs = picText.replace( /(<)source([^>]+>)/gmi, "$1div$2" ).match /<div[^>]+>/gmi
            frag.innerHTML = srcs.join ""
            sources = frag.getElementsByTagName "div"

        for sAttr in sources
            media = sAttr.getAttribute "media"
            if not media or window.matchMedia and window.matchMedia( media ).matches
                matches.push sAttr
                # once we find a match, we're done here
                break

        picImg = pic.getElementsByTagName( "img" )[ 0 ]

        if matches.length isnt 0
            if not picImg
                picImg = document.createElement "img"
                picImg.alt = pic.getAttribute "alt"
                pic.appendChild picImg

            srcSets = matches.pop().getAttribute "srcset"

            if srcSets and srcSets.length
                if deviceRatio and srcSets.indexOf( " 2x" ) isnt -1
                    srcSets = srcSets.split ","
                    for src in srcSets
                        src = src.replace( /^\s*/, '' ).replace( /\s*$/, '' ).split " "
                        resMatch = parseFloat src[ 1 ], 10
                        if deviceRatio is resMatch
                            correctSrc = src[ 0 ]
                            break
                else
                    correctSrc = srcSets
                picImg.src = correctSrc

        else if picImg then pic.removeChild picImg

# This method keeps track of the picture elements on the page and runs
# pictureTime() whenever they have updated.
watchPictures = ( lastPictures ) ->
    pictures = stringifyPictures()
    # If the pictures have changed, then call pictureTime()
    if lastPictures and lastPictures isnt pictures
        pictureTime()

    # Check for changes every half second.
    setTimeout () ->
        watchPictures pictures
    , 500

# A helper method to stringify the picture elements. Accepts no arguments
# and returns a string.
stringifyPictures = () ->
    pictures = ""
    for picture in document.getElementsByTagName "picture"
        pictures += picture.outerHTML
    return pictures

if window.addEventListener
    window.addEventListener "resize", pictureTime, false
    window.addEventListener "DOMContentLoaded", ->
        pictureTime()
        window.removeEventListener "load", pictureTime, false
    , false
    window.addEventListener "load", pictureTime, false
else window.attachEvent "onload", pictureTime

if typeof define is 'function'
    define () ->
        return pictureTime

# Call the method to watch for changes in picture elements.
watchPictures()


pictureTime()
