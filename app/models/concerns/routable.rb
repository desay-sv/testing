# Store object full path in separate table for easy lookup and uniq validation
# Object must have path db field and respond to full_path method.
module Routable
  extend ActiveSupport::Concern

  included do
    has_one :route, as: :source, dependent: :destroy

    validates_associated :route

    before_validation :update_route_path, if: :path_changed?
  end

  private

  def update_route_path
    route || build_route(source: self, path: full_path)
    route.path = full_path
  end
end
