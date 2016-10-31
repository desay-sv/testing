# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class FillRoutesTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  #
  # TODO:
  # * Do we need downtime here?
  # * When add uniq index on routes.path: before or after migration
  #
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  def up
    execute <<-EOF
      INSERT INTO routes
      (source_id, source_type, path)
      (SELECT id, 'Namespace', path FROM namespaces)
    EOF
  end

  def down
    Route.delete_all(source_type: 'Namespace')
  end
end
