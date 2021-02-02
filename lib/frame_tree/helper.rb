require 'terminal-table'

module FrameTree
  module Helper
    class << self
      def fetch_obj(oid)
        ObjectSpace._id2ref oid
      end

      def render
        rows = []
        headings = []
        yield rows, headings
        table = Terminal::Table.new rows: rows
        table.align_column(0, :right)
        table.headings = headings
        table
      end
    end
  end
end
