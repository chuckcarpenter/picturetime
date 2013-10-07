# pictureTime polyfill by Chuck Carpenter for National Geographic, 2012

# much observed from the picturefill polyfill by Scott Jehl
# http://github.com/scottjehl/picturefill

# needed to change markup to respect actual picture element and double density photos

# Need to ensure that this variable persists between consecutive executions of
# pictureTime so it is declared in the parent scope.
delayedScrollElements = {}

pictureTime = () ->
    # Reset variables.
    pictures = document.getElementsByTagName "picture"
    deviceRatio = window.devicePixelRatio or 1
    hasDelayedPictures = false

    # Remove the event listeners for every element in the delayedScrollElements
    # object.
    for id of delayedScrollElements
        if id is "window" then window.removeEventListener "scroll", scrollHandler
        else delayedScrollElements[ id ].element.removeEventListener "scroll", scrollHandler

    # Reset variable.
    delayedScrollElements = {}

    for pic in pictures
        matches = []
        sources = pic.getElementsByTagName "source"
        
        # IE8 is not going to let us process srcset attr, return and let the fallback load
        if pic.innerHTML is ""
            if ( img = pic.getElementsByTagName( "img" )[ 0 ] ) and ( src = img.getAttribute "data-src" )
                img.setAttribute "src", src
            return null

        # Check if the loading of the picture element in question should be
        # delayed.
        postpone = pic.getAttribute "postpone"
        if typeof postpone is "string" and postpone isnt "false"
            if hasDelayedPictures isnt true then hasDelayedPictures = true
            # Find the element relative to which the picture's position should
            # be calculated.
            if pic.getAttribute "data-scroll-element"
                scrollElement = document.querySelector pic.getAttribute "data-scroll-element"
                # If the postponed scrollElement does not have an ID, generate
                # one and assign it as an attribute.
                if not id = scrollElement.getAttribute "data-id"
                    scrollElement.setAttribute "data-id", id = new Date().getTime()
            # If the picture does not have a scroll element specified then
            # assume its position should be calculated relative to the window.
            else
                scrollElement = window
                id = "window"

            # If this key already exists, then simply add the current
            # picture to thr array in the value. Otherwise, create a key.
            if delayedScrollElements[ id ]
                delayedScrollElements[ id ].push pic
            else
                delayedScrollElements[ id ] = [ pic ]
                delayedScrollElements[ id ].element = scrollElement

        # Run the polyfill if the picture element is not postponed.
        else
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
                    # once we find a match, we're done here
                    break

            picImg = pic.getElementsByTagName( "img" )[0]

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
                        if deviceRatio is resMatch
                            correctSrc = src[0]
                            break
                else
                    correctSrc = srcSets
                picImg.src = correctSrc

            else if picImg then pic.removeChild picImg

    # Attatch event listeners.
    for id of delayedScrollElements
        if id is "window" then window.addEventListener "scroll", scrollHandler

        else delayedScrollElements[ id ].element.addEventListener "scroll", scrollHandler

scrollHandler = ( e ) ->
    scrollElement = e.srcElement
    pictures = delayedScrollElements[ if scrollElement is window.document then "window" else scrollElement.getAttribute "data-id" ]
    # Boolean to know if a new picture scrolled into view.
    scrolledIntoView = false

    for pic in pictures
        if isVisible pic, scrollElement
            # If a picture is in view then we no longer want to postpone its
            # loading in pictureTime.
            pic.removeAttribute "postpone"
            scrolledIntoView = true

    # Once we have looked at all the pictures associated with this scroll
    # element, if a new image has scrolled into view then call pictureTime.
    if scrolledIntoView then pictureTime()

# Helper function to find the total vertical offset of an element.
offsetTop = ( el ) ->
    temp = el
    o = temp.offsetTop or 0
    # Iterate over all parents of el upto body to find the vertical offset.
    while ( temp = temp.offsetParent ) and temp.tagName.toLowerCase() isnt "body"
        o += temp.offsetTop
    o

# Helper function to determine if an element is visible.
isVisible = ( el, scrollElement ) ->
    # Use clientHeight instead of window.innerHeight for compatability with ie8.
    viewPortHeight = document.documentElement.clientHeight
    top = offsetTop( el )
    scrollHeight = scrollElement.scrollTop + offsetTop( scrollElement )

    viewPortHeight + scrollHeight >= top

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

pictureTime()
