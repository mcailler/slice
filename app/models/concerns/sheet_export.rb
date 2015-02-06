module SheetExport
  extend ActiveSupport::Concern

  def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
    sheet_ids = sheet_scope.pluck(:id)
    sheet_scope = nil # Freeing Memory
    generate_csv_sheets_internal(sheet_ids, filename, raw_data, folder)
  end

  private

  def generate_csv_sheets_internal(sheet_ids, filename, raw_data, folder)
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

    CSV.open(export_file, "wb") do |csv|
      variables = all_design_variables_without_grids_using_design_ids(Sheet.where(id: sheet_ids).pluck(:design_id).uniq)

      write_csv_header(csv, variables.collect(&:csv_column).flatten)
      write_csv_body(sheet_ids, csv, raw_data, variables)

      variables = nil # Freeing Memory
    end
    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

  def write_csv_header(csv, column_headers)
    csv << ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Schedule Name", "Event Name"] + column_headers
  end

  def write_csv_body(sheet_ids, csv, raw_data, variables)
    sheet_ids.sort.reverse.each do |sheet_id|
      sheet = Sheet.find_by_id sheet_id
      write_sheet_to_csv(csv, sheet, variables, raw_data) if sheet
      sheet = nil # Freeing Memory
      update_steps(1)
    end
  end

  def write_sheet_to_csv(csv, sheet, variables, raw_data)
    row = [ sheet.id,
            sheet.name,
            sheet.description,
            sheet.created_at.strftime("%Y-%m-%d"),
            sheet.project.name,
            sheet.subject.site.name,
            sheet.subject.name,
            sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
            sheet.subject.status,
            sheet.user ? sheet.user.name : nil,
            sheet.subject_schedule ? sheet.subject_schedule.name : nil,
            sheet.event ? sheet.event.name : nil ]
    variables.each do |variable|
      response = sheet.get_response(variable, (raw_data ? :raw : :name))
      row << (response.kind_of?(Array) ? response.join(',') : response)
      if variable.variable_type == 'checkbox'
        variable.shared_options.each_with_index do |option, index|
          search_string = (raw_data ? option[:value] : "#{option[:value]}: #{option[:name]}")
          if response.include?(search_string)
            row << search_string
          else
            row << nil
          end
        end
      end
    end
    csv << row
    row = nil # Freeing Memory
  end

  def all_design_variables_without_grids_using_design_ids(design_ids)
    Design.where(id: design_ids).collect(&:variables).flatten.uniq.select{|v| v.variable_type != 'grid'}
  end

end