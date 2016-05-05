"""
# parse the url

might move to a namespace... (module)
"""
module Query

function parser(app, req)
   params = Dict()
   # TODO: Insert params here
   req[:params] = params

   app(req)
end

end

"""
# logger
assumes that the proper engine middleware is included
"""
function logger(ap, rq)
  println("[$(rq[:method])] - $(rq[:path]) - $(rq[:query])")
  ap(rq)
end

error_phrases = ["Looks like someone needs to pay their developers more."
                 "Someone order a thousand more monkeys! And a million more typewriters!"
                 "Maybe it's time for some sleep?"
                 "Don't bother debugging this one – it's almost definitely a quantum thingy."
                 "It probably won't happen again though, right?"
                 "F5! F5! F5!"
                 "F5! F5! FFS!"
                 "On the bright side, nothing has exploded. Yet."
                 "If this error has frustrated you, try clicking <u>here</u>."]
function exception(ap, rq)
  try
    ap(rq)
  catch
    io = IOBuffer()
    println(io, "<h1>Internal Error</h1>")
    println(io, "<p>$(error_phrases[rand(1:length(error_phrases))])</p>")
    println(io, "<pre class=\"box\">")
    showerror(io, e, catch_backtrace())
    return d(:status => 500, :body => takebuf_string(io))
  end

end
