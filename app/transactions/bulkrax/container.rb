module Bulkrax
  class Container
    extend Dry::Container::Mixin

    namespace "work_resource" do |ops|
      ops.register "create_with_bulk_behavior" do
        steps = Ams::WorkCreate::DEFAULT_STEPS.dup
        steps[steps.index("work_resource.add_file_sets")] = "work_resource.add_bulkrax_files"

        Ams::WorkCreate.new(steps: steps)
      end

      ops.register "update_with_bulk_behavior" do
        steps = Ams::WorkUpdate::DEFAULT_STEPS.dup
        steps[steps.index("work_resource.add_file_sets")] = "work_resource.add_bulkrax_files"

        Ams::WorkUpdate.new(steps: steps)
      end

      # TODO: uninitialized constant BulkraxTransactionContainer::InlineUploadHandler
      # ops.register "add_file_sets" do
      #   Hyrax::Transactions::Steps::AddFileSets.new(handler: InlineUploadHandler)
      # end

      ops.register "add_bulkrax_files" do
        Bulkrax::Transactions::Steps::AddFiles.new
      end
    end
  end
end
