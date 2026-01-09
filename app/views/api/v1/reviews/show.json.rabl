node :review do
  {
    id: @review.id,
    content: @review.content,
    created_at: @review.created_at,
    movie: { id: @review.movie_id, title: @review.movie&.title },
    member: { id: @review.member_id, username: @review.member&.user&.username }
  }
end