class Intercode::Import::Intercode1::Table
  attr_reader :connection, :id_map

  def initialize(connection)
    @connection = connection
    @id_map = {}
  end

  def dataset
    connection[self.class.name.demodulize.to_sym]
  end

  def object_name
    @object_name ||= self.class.name.demodulize.singularize
  end

  def import!
    logger.info "Importing #{object_name.pluralize}"
    dataset.each do |row|
      logger.debug "Importing #{object_name} #{row_id(row)}"
      record = build_record(row)
      record.save!

      id_map[row_id(row)] = record
    end
  end

  private
  def build_record(row)
  end

  def row_id(row)
  end

  def logger
    Intercode::Import::Intercode1.logger
  end

  def yn_to_bool(value)
    case value
    when 'Yes' then true
    when 'No' then false
    end
  end
end