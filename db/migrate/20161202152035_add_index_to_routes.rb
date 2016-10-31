# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexToRoutes < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_concurrent_index(:routes, :source_type)
    add_concurrent_index(:routes, :path, unique: true)
    add_concurrent_index(:routes, [:source_id, :source_type], unique: true)
  end
end
