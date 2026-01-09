node :reviews do
  @reviews.map do |review|
    {
      id: review.id,
      content: review.content,
      created_at: review.created_at,
      member: review.member ? {
        id: review.member.id,
        username: review.member.user&.username
      } : nil
    }
  end
end