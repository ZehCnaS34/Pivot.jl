module Rendering
using Mustache
using Base.Markdown

"""
Defines the proper variables for the template home
"""
function template(template_directory)
    function (app, ctx)
        ctx.data[:template_dir] = abspath(template_directory)
        app(ctx)
    end
end

"""
# render

should render a file as a request

later on, I should deff cache this
"""
function render(ctx, filename, data=Dict())
    template_location = ctx.data[:template_dir]
    f = open(joinpath(template_location, filename))
    content = join(readlines(f), "")
    close(f)
    Mustache.render(content, data)
end

"""
# markdown
loads the filename, and runs it through a markdown application
"""
function markdown(ctx, file, data=Dict(); isfile=true)
    template_location = ctx.data[:template_dir]
    f = open(joinpath(template_location, filename))
    content = join(readlines(f), "")
    close(f)
    md = Mustache.render(content, data)
    md |> Markdown.parse |> Markdown.html
end

end
