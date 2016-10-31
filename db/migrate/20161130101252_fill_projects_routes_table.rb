# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class FillProjectsRoutesTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  def up
    execute <<-EOF
      INSERT INTO routes
      (source_id, source_type, path)
      (SELECT projects.id, 'Project', concat(namespaces.path, '/', projects.path) FROM projects
      INNER JOIN namespaces ON projects.namespace_id = namespaces.id)
    EOF
  end

  def down
    Route.delete_all(source_type: 'Project')
  end
end
