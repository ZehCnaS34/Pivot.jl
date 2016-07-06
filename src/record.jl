using Junior.Model

@record immutable Comment
    @int id
    @string content
    @reference author
end

# concurrency primitives

c = Chan(1)

@timeout 80

@go begin
    @get c
    @set c value
    @alt! begin
    end
end

@go begin
end
