"""
# Rendering

This module contains functions that make http responses less annoying to
write.
"""
module Rendering

export template_directory

function template_directory(dir)
  function (app, ctx)
    app(ctx)
  end
end

function render(ctx, template_name, data=Dict())
  error("Render not implemented")
end

function markdown(ctx, file, data=Dict())
  error("Markdown not implemented")
end

end
