class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true

  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id'

  belongs_to :parent_comment, class_name: 'Comment', optional: true

end