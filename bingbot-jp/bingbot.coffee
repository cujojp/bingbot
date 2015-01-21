irc = require 'irc'
http = require 'http'

sample = (array) ->
  return if !array || !array.length
  array[ Math.floor(array.length * Math.random()) ]

# Return a url for a random image found in bing image search
getImage = (query, callback) ->
  url = "http://www.bing.com/images/search?q=#{query}"

  http.get url, (res)->
    html = ''
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      #console.log(chunk)
      #console.log('xxxxxx')
      html += chunk
    res.on 'end', ->
      #console.log(html)
      matches = html.match(/<img src="http(.*?)"/g)
      #console.log(matches)
      if randomMatch = sample(matches)
        url = randomMatch.split('"')[1]
        url = url.replace(/&amp;/g, '&')
        url += '.jpg' # trick limechat!
        callback(url)
      else
        callback(null)

# GOOOGLE
getImage = (query, callback) ->
  url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q=#{query}"
  http.get url, (res) ->
    html = ''
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      html += chunk
    res.on 'end', ->
      try
        data = JSON.parse(html)
        console.log data
        img = sample(data.responseData?.results)?.url
        callback(img)
      catch e
         console.log html
    
getTumblrImage = (help_mcdondons, callback, src) ->
  key = "nsDbY8ovJgrSGGigNlTXdB1czI8zf6vzRo7hl5KTXi2QSGJxnH"
  tumblr = src
  query = "http://api.tumblr.com/v2/blog/#{tumblr}/posts/photo?api_key=#{key}&"
  total_posts = if src is "maaccas.tumblr.com" then 782 else 90
  limit = if help_mcdondons then 5 else 1
  offset = randInt(0, (total_posts-limit))
  params = "limit=#{limit}&offset=#{offset}"

  http.get query+params, (res) ->
    html = ''
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      html += chunk
    res.on 'end', ->
      try
        data = JSON.parse(html)
        if data.response.posts[0].photos[0]

          if help_mcdondons
            img = []
            #console.log(data.response.posts)
            for post in data.response.posts
              img.push(post.photos[0].original_size.url)

            callback(img)
          else
            img = data.response.posts[0].photos[0].original_size.url
            callback(img)
          
      catch e
         #console.log html


randInt = (low, high) ->
  return Math.floor(Math.random() * (high - low) + low)


#return getImage 'cats', (img) -> console.log img

bot = new irc.Client('irc.freenode.net', 'bingbot', {
  debug: true,
  channels: ['#coolkidsusa']
})

bot.addListener 'error', (message) ->
  console.error 'fuk:', message

bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if /bing\s+(.*)/.test(message)
    query = encodeURIComponent(RegExp.$1)
    url = "http://www.bing.com/search?q=#{query}"
    console.log(url)

    msg = " ( ͡° ͜ʖ ͡°) You asked, I answered!  Heres those results you wanted: "
    msg += "  #{url}"
    bot.say(to, msg)

  else if /camsnap\s+(.*)/.test(message)
    getImage RegExp.$1, (img) ->
      console.log(img)
      #bot.say(to, "http://solutions.3m.com/innovation/assets/logo.png")
      if img
        bot.say(to, img)
      else
        bot.say(to, "soRry bro!  bing must be down")

  else if /campsnap\s*(.*)/.test(message)
    getImage "camp counselor " + RegExp.$1, (img) ->
      console.log(img)
      #bot.say(to, "http://solutions.3m.com/innovation/assets/logo.png")
      if img
        bot.say(to, img)
      else
        bot.say(to, "soRry bro!  bing must be down")

  else if /help mcdondon/.test(message)
    getTumblrImage true ,(img), "maaccas.tumblr.com"  ->
      if img
        console.log(typeof(img))
        if typeof(img) is 'object'
          console.log('fuk')
          img = img.join(",\n ")

        console.log(img)

        bot.say(to, img)
      else
        bot.say(to, "soRry bro!  bing must be down")

  else if /mcdondon/.test(message)
    getTumblrImage null, (img), "maaccas.tumblr.com"  ->
      if img
        
        bot.say(to, img)
      else
        bot.say(to, "soRry bro!  bing must be down")

  else if /roll/.test(message)
    getTumblrImage null, (img), "rrrrrrrroll.tumblr.com"  ->
      if img
        bot.say(to, img)
      else
        bot.say(to, "soRry bro!  bing must be down")

  # talk back
  else if /bingbot/.test(message)
    msg = message.replace(/bingbot/g, from)
    bot.say(to, msg)




  



